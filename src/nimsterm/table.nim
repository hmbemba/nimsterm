import
    std/strutils
    ,./types
    ,./style
    ,./util  # Fix #8, #14: Import for stripAnsi and alignText

# Fix #14: alignText is now imported from util.nim
# The alignText function has been consolidated there to eliminate duplication
# between table.nim and style.nim

proc table*(
    headers      : openArray[string]
    ,rows        : openArray[seq[string]]
    ,minWidth    : int = 10
    ,borderStyle : string = "single"
)               : string =
    let numCols = headers.len

    var widths = newSeq[int](numCols)
    for i, h in headers:
        # Fix #8: Use stripAnsi for visual width calculation
        widths[i] = max(minWidth, stripAnsi(h).len + 2)

    for row in rows:
        for i, cell in row:
            if i < numCols:
                # Fix #8: Use stripAnsi for visual width calculation
                widths[i] = max(widths[i], stripAnsi(cell).len + 2)

    let (tl, tr, bl, br, h, v, tj, bj, lj, rj, cross) =
        if borderStyle == "double":
            ("╔", "╗", "╚", "╝", "═", "║", "╦", "╩", "╠", "╣", "╬")
        elif borderStyle == "rounded":
            ("╭", "╮", "╰", "╯", "─", "│", "┬", "┴", "├", "┤", "┼")
        else:
            ("┌", "┐", "└", "┘", "─", "│", "┬", "┴", "├", "┤", "┼")

    var lines: seq[string] = @[]

    # Fix #19: Build top border using seq instead of repeated concatenation
    var topParts: seq[string] = newSeqOfCap[string](numCols * 2 + 1)
    topParts.add(tl)
    for i, w in widths:
        topParts.add(h.repeat(w))
        topParts.add(if i < numCols - 1: tj else: tr)
    lines.add(topParts.join(""))

    # Fix #19: Build header row using seq
    var headerParts: seq[string] = newSeqOfCap[string](numCols * 2 + 1)
    headerParts.add(v)
    for i, hdr in headers:
        headerParts.add(alignText(" " & hdr & " ", widths[i], alignCenter))
        headerParts.add(v)
    lines.add(headerParts.join(""))

    # Fix #19: Build separator using seq
    var sepParts: seq[string] = newSeqOfCap[string](numCols * 2 + 1)
    sepParts.add(lj)
    for i, w in widths:
        sepParts.add(h.repeat(w))
        sepParts.add(if i < numCols - 1: cross else: rj)
    lines.add(sepParts.join(""))

    # Data rows
    for row in rows:
        var rowParts: seq[string] = newSeqOfCap[string](numCols * 2 + 1)
        rowParts.add(v)
        for i in 0 ..< numCols:
            let cell = (if i < row.len: row[i] else: "")
            rowParts.add(alignText(" " & cell & " ", widths[i], alignLeft))
            rowParts.add(v)
        lines.add(rowParts.join(""))

    # Fix #19: Build bottom border using seq
    var bottomParts: seq[string] = newSeqOfCap[string](numCols * 2 + 1)
    bottomParts.add(bl)
    for i, w in widths:
        bottomParts.add(h.repeat(w))
        bottomParts.add(if i < numCols - 1: bj else: br)
    lines.add(bottomParts.join(""))

    lines.join("\n")

proc table*(
    headers      : openArray[string]
    ,rows        : openArray[seq[string]]
    ,aligns      : openArray[Align]  # Fix #13: Accept alignment parameter
    ,borderStyle : string = "single"
)               : string =
    ## Table with explicit column alignments (Fix #13)
    let numCols = headers.len
    var widths = newSeq[int](numCols)
    
    for i, h in headers:
        widths[i] = max(1, stripAnsi(h).len + 2)

    for row in rows:
        for i, cell in row:
            if i < numCols:
                widths[i] = max(widths[i], stripAnsi(cell).len + 2)

    let (tl, tr, bl, br, h, v, tj, bj, lj, rj, cross) =
        if borderStyle == "double":
            ("╔", "╗", "╚", "╝", "═", "║", "╦", "╩", "╠", "╣", "╬")
        elif borderStyle == "rounded":
            ("╭", "╮", "╰", "╯", "─", "│", "┬", "┴", "├", "┤", "┼")
        else:
            ("┌", "┐", "└", "┘", "─", "│", "┬", "┴", "├", "┤", "┼")

    var lines: seq[string] = @[]

    # Fix #19: Build top border using seq
    var topParts: seq[string] = newSeqOfCap[string](numCols * 2 + 1)
    topParts.add(tl)
    for i, w in widths:
        topParts.add(h.repeat(w))
        topParts.add(if i < numCols - 1: tj else: tr)
    lines.add(topParts.join(""))

    # Fix #19: Build header row using seq
    var headerParts: seq[string] = newSeqOfCap[string](numCols * 2 + 1)
    headerParts.add(v)
    for i, hdr in headers:
        headerParts.add(alignText(" " & hdr & " ", widths[i], alignCenter))
        headerParts.add(v)
    lines.add(headerParts.join(""))

    # Fix #19: Build separator using seq
    var sepParts: seq[string] = newSeqOfCap[string](numCols * 2 + 1)
    sepParts.add(lj)
    for i, w in widths:
        sepParts.add(h.repeat(w))
        sepParts.add(if i < numCols - 1: cross else: rj)
    lines.add(sepParts.join(""))

    # Data rows
    for row in rows:
        var rowParts: seq[string] = newSeqOfCap[string](numCols * 2 + 1)
        rowParts.add(v)
        for i in 0 ..< numCols:
            let cell = (if i < row.len: row[i] else: "")
            # Fix #13: Use provided alignment, fallback to left
            let colAlign = if i < aligns.len: aligns[i] else: alignLeft
            rowParts.add(alignText(" " & cell & " ", widths[i], colAlign))
            rowParts.add(v)
        lines.add(rowParts.join(""))

    # Fix #19: Build bottom border using seq
    var bottomParts: seq[string] = newSeqOfCap[string](numCols * 2 + 1)
    bottomParts.add(bl)
    for i, w in widths:
        bottomParts.add(h.repeat(w))
        bottomParts.add(if i < numCols - 1: bj else: br)
    lines.add(bottomParts.join(""))

    lines.join("\n")

proc table*(
    cols         : openArray[Column]
    ,rows        : openArray[seq[string]]
    ,borderStyle : string = "single"
)               : string =
    var headers: seq[string] = @[]
    for c in cols:
        headers.add(c.header)

    let numCols = headers.len
    var widths  = newSeq[int](numCols)

    for i, c in cols:
        widths[i] = max(1, c.width)

    for row in rows:
        for i in 0 ..< min(numCols, row.len):
            # Fix #8: Use stripAnsi for visual width calculation
            widths[i] = max(widths[i], stripAnsi(row[i]).len + 2)

    let (tl, tr, bl, br, h, v, tj, bj, lj, rj, cross) =
        if borderStyle == "double":
            ("╔", "╗", "╚", "╝", "═", "║", "╦", "╩", "╠", "╣", "╬")
        elif borderStyle == "rounded":
            ("╭", "╮", "╰", "╯", "─", "│", "┬", "┴", "├", "┤", "┼")
        else:
            ("┌", "┐", "└", "┘", "─", "│", "┬", "┴", "├", "┤", "┼")

    var lines: seq[string] = @[]

    # Fix #19: Build top border using seq
    var topParts: seq[string] = newSeqOfCap[string](numCols * 2 + 1)
    topParts.add(tl)
    for i, w in widths:
        topParts.add(h.repeat(w))
        topParts.add(if i < numCols - 1: tj else: tr)
    lines.add(topParts.join(""))

    # Fix #19: Build header row using seq
    var headerParts: seq[string] = newSeqOfCap[string](numCols * 2 + 1)
    headerParts.add(v)
    for i, hdr in headers:
        headerParts.add(alignText(" " & hdr & " ", widths[i], alignCenter))
        headerParts.add(v)
    lines.add(headerParts.join(""))

    # Fix #19: Build separator using seq
    var sepParts: seq[string] = newSeqOfCap[string](numCols * 2 + 1)
    sepParts.add(lj)
    for i, w in widths:
        sepParts.add(h.repeat(w))
        sepParts.add(if i < numCols - 1: cross else: rj)
    lines.add(sepParts.join(""))

    # Data rows
    for row in rows:
        var rowParts: seq[string] = newSeqOfCap[string](numCols * 2 + 1)
        rowParts.add(v)
        for i in 0 ..< numCols:
            let cell  = (if i < row.len: row[i] else: "")
            let a     = cols[i].align
            rowParts.add(alignText(" " & cell & " ", widths[i], a))
            rowParts.add(v)
        lines.add(rowParts.join(""))

    # Fix #19: Build bottom border using seq
    var bottomParts: seq[string] = newSeqOfCap[string](numCols * 2 + 1)
    bottomParts.add(bl)
    for i, w in widths:
        bottomParts.add(h.repeat(w))
        bottomParts.add(if i < numCols - 1: bj else: br)
    lines.add(bottomParts.join(""))

    lines.join("\n")

proc simpleTable*(headers: openArray[string]; rows: openArray[seq[string]]): string =
    let numCols = headers.len
    var widths  = newSeq[int](numCols)

    for i, h in headers:
        # Fix #8: Use stripAnsi for visual width calculation
        widths[i] = stripAnsi(h).len + 2

    for row in rows:
        for i, cell in row:
            if i < numCols:
                # Fix #8: Use stripAnsi for visual width calculation
                widths[i] = max(widths[i], stripAnsi(cell).len + 2)

    var lines: seq[string] = @[]

    # Fix #19: Build header line using seq
    var hdrParts: seq[string] = newSeqOfCap[string](numCols)
    for i, h in headers:
        hdrParts.add(alignText(h, widths[i], alignLeft))
    lines.add($styled(hdrParts.join("")).fg(cyan).style(bold))

    # Fix #19: Build underline using seq
    var ulParts: seq[string] = newSeqOfCap[string](numCols)
    for w in widths:
        ulParts.add("─".repeat(w))
    lines.add($styled(ulParts.join("")).fg(brightBlack))

    # Data rows
    for row in rows:
        var rowParts: seq[string] = newSeqOfCap[string](numCols)
        for i in 0 ..< numCols:
            let cell = if i < row.len: row[i] else: ""
            rowParts.add(alignText(cell, widths[i], alignLeft))
        lines.add(rowParts.join(""))

    lines.join("\n")

# ─── new: Rich-style borderless table ─────────────────────────────

type
    RichColumn* = object
        header*     : string
        align*      : Align
        headerColor*: Color
        cellColor*  : Color
        cellStyle*  : Style
        minWidth*   : int

proc richCol*(
    header      : string
    ,align      : Align  = alignLeft
    ,headerColor: Color  = cyan
    ,cellColor  : Color  = colDefault
    ,cellStyle  : Style  = bold
    ,minWidth   : int    = 0
)               : RichColumn =
    RichColumn(
        header      : header
        ,align      : align
        ,headerColor: headerColor
        ,cellColor  : cellColor
        ,cellStyle  : cellStyle
        ,minWidth   : minWidth
    )

proc richTable*(
    cols            : openArray[RichColumn]
    ,rows           : openArray[seq[string]]
    ,colGap         : int    = 4
    ,dimAlternate   : bool   = true
    ,headerUnderline: bool   = false
): string =
    ## Borderless Rich-style table with colored headers and styled cells.
    let numCols = cols.len

    # Calculate column widths
    var widths = newSeq[int](numCols)
    for i, c in cols:
        # Fix #8: Use stripAnsi for visual width calculation
        widths[i] = max(c.minWidth, stripAnsi(c.header).len)

    for row in rows:
        for i in 0 ..< min(numCols, row.len):
            # Fix #8: Use stripAnsi for visual width calculation
            widths[i] = max(widths[i], stripAnsi(row[i]).len)

    var lines: seq[string] = @[]

    # Fix #19: Build header row using seq
    var hdrParts: seq[string] = newSeqOfCap[string](numCols * 2 - 1)
    for i, c in cols:
        let cell = alignText(c.header, widths[i], c.align)
        hdrParts.add($styled(cell).fg(c.headerColor).style(bold))
        if i < numCols - 1:
            hdrParts.add(" ".repeat(colGap))
    lines.add(hdrParts.join(""))

    # Optional underline
    if headerUnderline:
        var ulParts: seq[string] = newSeqOfCap[string](numCols * 2 - 1)
        for i, w in widths:
            ulParts.add("─".repeat(w))
            if i < numCols - 1:
                ulParts.add(" ".repeat(colGap))
        lines.add($styled(ulParts.join("")).fg(brightBlack))

    # Data rows
    for rowIdx, row in rows:
        let isDim = dimAlternate and (rowIdx mod 2 == 1)

        var lineParts: seq[string] = newSeqOfCap[string](numCols * 2 - 1)
        for i in 0 ..< numCols:
            let cellText = if i < row.len: row[i] else: ""
            let aligned  = alignText(cellText, widths[i], cols[i].align)

            var st = styled(aligned)

            # Apply column cell color
            if cols[i].cellColor != colDefault:
                st = st.fg(cols[i].cellColor)

            # Apply dim on alternating rows
            if isDim:
                st = st.style(dim)
            else:
                st = st.style(cols[i].cellStyle)

            lineParts.add($st)
            if i < numCols - 1:
                lineParts.add(" ".repeat(colGap))
        lines.add(lineParts.join(""))

    lines.join("\n")

discard """

Tables:
- table(headers, rows, ...)         : auto width + borders
- table(headers, rows, aligns, ...) : with explicit column alignments (Fix #13)
- table(cols, rows, ...)            : explicit column width + alignment
- simpleTable(headers, rows)        : header styled, no box borders
- richTable(cols, rows, ...)        : Rich-style borderless with colors and alternating rows

Fixes:
- Fix #8: All width calculations use stripAnsi for visual width
- Fix #13: Markdown table alignment can be passed to table renderer
- Fix #14: alignText consolidated into util.nim (DRY principle)
- Fix #19: String concatenation in loops optimized (seq + join pattern)

"""
