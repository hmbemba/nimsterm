## Terminal renderer for parsed markdown blocks.
## Uses nimsterm's styled text, tables, and semantic helpers
## instead of raw ANSI escape codes.

import
    std/strutils
    ,./mdtypes
    ,./parser
    ,../nimsterm

# ── Theme ────────────────────────────────────────────────────────

type
    MdTheme* = object
        h1Prefix*       : string
        h2Prefix*       : string
        h3Prefix*       : string
        h4Prefix*       : string
        h5Prefix*       : string
        h6Prefix*       : string
        bulletMarker*   : string
        quotePrefix*    : string
        hrChar*         : string
        hrWidth*        : int
        codeBlockBg*    : bool
        indentWidth*    : int
        blockSpacing*   : int     ## blank lines between blocks (0 = compact)

proc defaultTheme*(): MdTheme =
    MdTheme(
        h1Prefix:     "█ ",
        h2Prefix:     "▌ ",
        h3Prefix:     "▎ ",
        h4Prefix:     "  ",
        h5Prefix:     "  ",
        h6Prefix:     "  ",
        bulletMarker: "•",
        quotePrefix:  "▐ ",
        hrChar:       "─",
        hrWidth:      60,
        codeBlockBg:  true,
        indentWidth:  2,
        blockSpacing: 1,
    )

# ── Inline rendering ─────────────────────────────────────────────

proc renderToken*(tok: MdToken): string =
    case tok.kind
    of mkText:
        tok.text
    of mkBold:
        $styled(tok.text).style(bold)
    of mkItalic:
        $styled(tok.text).style(italic)
    of mkBoldItalic:
        $styled(tok.text).style(bold, italic)
    of mkCode:
        $styled(" " & tok.text & " ").fg(cyan).bg(brightBlack)
    of mkStrikethrough:
        $styled(tok.text).style(strikethrough, dim)
    of mkLink:
        $styled(tok.linkText).fg(cyan).style(underline) &
        $styled(" (" & tok.linkUrl & ")").fg(brightBlack)
    of mkImage:
        $styled("🖼  " & tok.altText).fg(magenta) &
        $styled(" [" & tok.imgUrl & "]").fg(brightBlack)

proc renderTokens*(tokens: seq[MdToken]): string =
    for tok in tokens:
        result &= renderToken(tok)

# ── Block rendering ──────────────────────────────────────────────

proc renderBlock*(blk: MdBlock; theme: MdTheme; indent: int = 0): string

proc renderBlocks*(blocks: seq[MdBlock]; theme: MdTheme; indent: int = 0): string =
    var parts: seq[string] = @[]
    let spacer = "\n".repeat(theme.blockSpacing)
    for blk in blocks:
        let r = renderBlock(blk, theme, indent)
        if r.len > 0:
            parts.add r
    parts.join("\n" & spacer)

proc renderBlock*(blk: MdBlock; theme: MdTheme; indent: int = 0): string =
    let pad = " ".repeat(indent)

    case blk.kind

    of mbEmptyLine:
        return ""

    of mbHeading:
        let content = renderTokens(blk.headingTokens)
        case blk.level
        of 1:
            let bar = $styled(theme.hrChar.repeat(theme.hrWidth)).fg(cyan).style(bold)
            return pad & bar & "\n" &
                   pad & $styled(theme.h1Prefix & content).fg(cyan).style(bold) & "\n" &
                   pad & bar
        of 2:
            return pad & $styled(theme.h2Prefix & content).fg(green).style(bold) & "\n" &
                   pad & $styled("─".repeat(min(theme.hrWidth, content.len + 4))).fg(brightBlack)
        of 3:
            return pad & $styled(theme.h3Prefix & content).fg(yellow).style(bold)
        of 4:
            return pad & $styled(theme.h4Prefix & content).fg(blue).style(bold)
        of 5:
            return pad & $styled(theme.h5Prefix & content).fg(magenta).style(dim)
        of 6:
            return pad & $styled(theme.h6Prefix & content).fg(brightBlack).style(bold)
        else:
            return pad & $styled(content).style(bold)

    of mbParagraph:
        return pad & renderTokens(blk.tokens)

    of mbCodeBlock:
        var lines: seq[string] = @[]
        let codeLines  = blk.code.split('\n')
        let innerWidth = theme.hrWidth - 2  # space between │ and │

        # ── top border with optional lang tab ──
        if blk.lang.len > 0:
            let langTag  = " " & blk.lang & " "
            let restLen  = max(0, innerWidth - langTag.len)
            lines.add pad &
                $styled("╭").fg(brightBlack) &
                $styled(langTag).fg(cyan).bg(brightBlack).style(bold) &
                $styled("─".repeat(restLen) & "╮").fg(brightBlack)
        else:
            lines.add pad &
                $styled("╭" & "─".repeat(innerWidth) & "╮").fg(brightBlack)

        # ── code lines ──
        for codeLine in codeLines:
            let content  = " " & codeLine
            let fillLen  = max(0, innerWidth - content.len)
            let filled   = content & " ".repeat(fillLen)

            if theme.codeBlockBg:
                lines.add pad &
                    $styled("│").fg(brightBlack) &
                    $styled(filled).fg(green).bg(brightBlack) &
                    $styled("│").fg(brightBlack)
            else:
                lines.add pad &
                    $styled("│").fg(brightBlack) &
                    $styled(filled).fg(green) &
                    $styled("│").fg(brightBlack)

        # ── bottom border ──
        lines.add pad &
            $styled("╰" & "─".repeat(innerWidth) & "╯").fg(brightBlack)

        return lines.join("\n")

    of mbBlockquote:
        var lines: seq[string] = @[]
        let inner = renderBlocks(blk.quoteBlocks, theme, indent + theme.indentWidth)
        for line in inner.split('\n'):
            lines.add pad & $styled(theme.quotePrefix).fg(brightBlack).style(italic) &
                       $styled(line.strip()).style(dim, italic)
        return lines.join("\n")

    of mbUnorderedList:
        var lines: seq[string] = @[]
        for item in blk.ulItems:
            lines.add pad & $styled("  " & theme.bulletMarker & " ").fg(cyan) &
                       renderTokens(item.tokens)
            for child in item.children:
                lines.add pad & $styled("    " & theme.bulletMarker & " ").fg(brightBlack) &
                           renderTokens(child.tokens)
        return lines.join("\n")

    of mbOrderedList:
        var lines: seq[string] = @[]
        for idx, item in blk.olItems:
            let num = blk.olStart + idx
            lines.add pad & $styled("  " & $num & ". ").fg(cyan) &
                       renderTokens(item.tokens)
            for ci, child in item.children:
                let subMarker = $styled("    " & theme.bulletMarker & " ").fg(brightBlack)
                lines.add pad & subMarker & renderTokens(child.tokens)
        return lines.join("\n")

    of mbHorizontalRule:
        return pad & $styled(theme.hrChar.repeat(theme.hrWidth)).fg(brightBlack)

    of mbTable:
        # Use nimsterm's table() with rounded borders
        let numCols = blk.tableHeaders.len
        var rows: seq[seq[string]] = @[]
        for row in blk.tableRows:
            var cells: seq[string] = @[]
            for i in 0 ..< numCols:
                cells.add(if i < row.cells.len: row.cells[i] else: "")
            rows.add cells

        let tbl = table(
            blk.tableHeaders,
            rows,
            borderStyle = "rounded"
        )

        # Apply indent to each line
        if indent > 0:
            var lines: seq[string] = @[]
            for line in tbl.split('\n'):
                lines.add pad & line
            return lines.join("\n")
        else:
            return tbl

# ── Public API ───────────────────────────────────────────────────

proc renderMarkdown*(source: string; theme: MdTheme = defaultTheme()): string =
    ## Parse and render markdown to ANSI-styled terminal output.
    let blocks = parseBlocks(source)
    renderBlocks(blocks, theme)

proc printMarkdown*(source: string; theme: MdTheme = defaultTheme()) =
    ## Parse, render, and print markdown to stdout.
    echo renderMarkdown(source, theme)