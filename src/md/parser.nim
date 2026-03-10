## Block-level markdown parser.
## Converts raw markdown text into a sequence of MdBlock nodes.

import
    std/strutils
    ,./mdtypes
    ,./inline

# Fix #12: Improved horizontal rule validation per CommonMark spec
proc isHorizontalRule(line: string): bool =
    ## CommonMark spec: A horizontal rule consists of three or more
    ## hyphens, asterisks, or underscores, optionally separated by spaces.
    ## The line must not contain any other characters.
    let s = line.strip()
    if s.len < 3: return false
    
    let ch = s[0]
    if ch notin {'-', '*', '_'}: return false
    
    var count = 0
    for c in s:
        if c == ch:
            inc count
        elif c != ' ':
            # Any character other than the marker char or space invalidates
            return false
    
    # Must have at least 3 marker characters
    count >= 3

proc parseTableAligns(line: string): seq[MdTableAlign] =
    let cells = line.strip().strip(chars = {'|'}).split('|')
    for cell in cells:
        let s = cell.strip()
        if s.startsWith(':') and s.endsWith(':'):
            result.add taCenter
        elif s.endsWith(':'):
            result.add taRight
        else:
            result.add taLeft

proc parseTableRow(line: string): seq[string] =
    let trimmed = line.strip()
    var inner = trimmed
    if inner.startsWith('|'): inner = inner[1 .. ^1]
    if inner.endsWith('|'):   inner = inner[0 .. ^2]
    for cell in inner.split('|'):
        result.add cell.strip()

proc isTableSeparator(line: string): bool =
    let s = line.strip()
    if not s.contains('|'): return false
    let cells = s.strip(chars = {'|'}).split('|')
    for cell in cells:
        let c = cell.strip()
        if c.len == 0: return false
        for ch in c:
            if ch notin {'-', ':'}: return false
    true

proc lineIndent(line: string): int =
    ## Count leading spaces.
    for c in line:
        if c == ' ': inc result
        else: break

proc isUlMarker(trimmed: string): bool =
    trimmed.len >= 2 and trimmed[0] in {'-', '*', '+'} and trimmed[1] == ' '

proc isOlMarker(trimmed: string): tuple[ok: bool; dotIdx: int] =
    let dotIdx = trimmed.find('.')
    if dotIdx > 0 and dotIdx < trimmed.len - 1 and trimmed[dotIdx + 1] == ' ':
        var allDigits = true
        for ci in 0 ..< dotIdx:
            if trimmed[ci] notin {'0'..'9'}:
                allDigits = false
                break
        if allDigits:
            return (ok: true, dotIdx: dotIdx)
    (ok: false, dotIdx: -1)

proc parseBlocks*(source: string): seq[MdBlock] =
    let rawLines = source.replace("\r\n", "\n").replace("\r", "\n").split('\n')
    var i = 0

    while i < rawLines.len:
        let line = rawLines[i]
        let trimmed = line.strip()

        # Empty line
        if trimmed.len == 0:
            result.add MdBlock(kind: mbEmptyLine)
            inc i
            continue

        # Fenced code block ```
        if trimmed.startsWith("```"):
            let lang = trimmed[3 .. ^1].strip()
            inc i
            var codeLines: seq[string] = @[]
            while i < rawLines.len:
                if rawLines[i].strip().startsWith("```"):
                    inc i
                    break
                codeLines.add rawLines[i]
                inc i
            result.add MdBlock(kind: mbCodeBlock, lang: lang, code: codeLines.join("\n"))
            continue

        # Heading # ... ######
        if trimmed.startsWith('#'):
            var level = 0
            var j = 0
            while j < trimmed.len and trimmed[j] == '#':
                inc level
                inc j
            if level <= 6 and j < trimmed.len and trimmed[j] == ' ':
                let content = trimmed[j + 1 .. ^1].strip()
                result.add MdBlock(kind: mbHeading, level: level, headingTokens: parseInline(content))
                inc i
                continue

        # Horizontal rule
        if isHorizontalRule(trimmed):
            result.add MdBlock(kind: mbHorizontalRule)
            inc i
            continue

        # Blockquote >
        if trimmed.startsWith('>'):
            var quoteLines: seq[string] = @[]
            while i < rawLines.len:
                let ql = rawLines[i].strip()
                if ql.startsWith('>'):
                    var content = ql[1 .. ^1]
                    if content.startsWith(' '): content = content[1 .. ^1]
                    quoteLines.add content
                elif ql.len == 0:
                    break
                else:
                    break
                inc i
            let innerMd = quoteLines.join("\n")
            result.add MdBlock(kind: mbBlockquote, quoteBlocks: parseBlocks(innerMd))
            continue

        # Unordered list - / * / +
        if isUlMarker(trimmed):
            var items: seq[MdListItem] = @[]
            let baseIndent = lineIndent(rawLines[i])

            while i < rawLines.len:
                let ul      = rawLines[i]
                let ulTrim  = ul.strip()
                let ulInd   = lineIndent(ul)

                if ulTrim.len == 0:
                    break

                if ulInd == baseIndent and isUlMarker(ulTrim):
                    # Top-level item
                    items.add MdListItem(
                        tokens:   parseInline(ulTrim[2 .. ^1].strip()),
                        children: @[]
                    )
                    inc i
                elif ulInd > baseIndent and items.len > 0:
                    # Indented line — sub-item or continuation
                    if isUlMarker(ulTrim):
                        items[^1].children.add MdListItem(
                            tokens:   parseInline(ulTrim[2 .. ^1].strip()),
                            children: @[]
                        )
                    else:
                        # Continuation text appended to last item
                        items[^1].tokens.add MdToken(kind: mkText, text: " " & ulTrim)
                    inc i
                else:
                    break

            result.add MdBlock(kind: mbUnorderedList, ulItems: items)
            continue

        # Ordered list 1. 2. etc
        block olCheck:
            let (isOl, dotIdx) = isOlMarker(trimmed)
            if isOl:
                let startNum   = parseInt(trimmed[0 ..< dotIdx])
                let baseIndent = lineIndent(rawLines[i])
                var items: seq[MdListItem] = @[]

                while i < rawLines.len:
                    let ol     = rawLines[i]
                    let olTrim = ol.strip()
                    let olInd  = lineIndent(ol)

                    if olTrim.len == 0:
                        break

                    let (subOl, subDot) = isOlMarker(olTrim)

                    if olInd == baseIndent and subOl:
                        items.add MdListItem(
                            tokens:   parseInline(olTrim[subDot + 2 .. ^1].strip()),
                            children: @[]
                        )
                        inc i
                    elif olInd > baseIndent and items.len > 0:
                        if subOl:
                            items[^1].children.add MdListItem(
                                tokens:   parseInline(olTrim[subDot + 2 .. ^1].strip()),
                                children: @[]
                            )
                        elif isUlMarker(olTrim):
                            items[^1].children.add MdListItem(
                                tokens:   parseInline(olTrim[2 .. ^1].strip()),
                                children: @[]
                            )
                        else:
                            items[^1].tokens.add MdToken(kind: mkText, text: " " & olTrim)
                        inc i
                    else:
                        break

                result.add MdBlock(kind: mbOrderedList, olItems: items, olStart: startNum)
                continue

        # Table: look ahead for separator line
        if trimmed.contains('|') and i + 1 < rawLines.len and isTableSeparator(rawLines[i + 1]):
            let headers = parseTableRow(trimmed)
            let aligns  = parseTableAligns(rawLines[i + 1])
            i += 2
            var rows: seq[MdTableRow] = @[]
            while i < rawLines.len:
                let tl = rawLines[i].strip()
                if tl.len == 0 or not tl.contains('|'):
                    break
                rows.add MdTableRow(cells: parseTableRow(tl))
                inc i
            result.add MdBlock(
                kind: mbTable,
                tableHeaders: headers,
                tableAligns: aligns,
                tableRows: rows
            )
            continue

        # Paragraph: collect contiguous non-empty non-special lines
        var paraLines: seq[string] = @[]
        while i < rawLines.len:
            let pl = rawLines[i]
            let pt = pl.strip()
            if pt.len == 0: break
            if pt.startsWith('#') or pt.startsWith("```") or
               pt.startsWith('>') or isHorizontalRule(pt):
                break
            if pt.contains('|') and i + 1 < rawLines.len and isTableSeparator(rawLines[i + 1]):
                break
            paraLines.add pt
            inc i
        if paraLines.len > 0:
            result.add MdBlock(kind: mbParagraph, tokens: parseInline(paraLines.join(" ")))

discard """

Block-level Markdown Parser

Parses:
- Headings (# to ######)
- Paragraphs
- Code blocks (```)
- Blockquotes (>)
- Unordered lists (-, *, +)
- Ordered lists (1., 2., etc)
- Horizontal rules (---, ***, ___)
- Tables (| col | col |)

Fixes:
- Fix #12: Improved horizontal rule validation per CommonMark spec

"""
