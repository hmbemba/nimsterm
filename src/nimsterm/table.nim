import
    std/strutils
    ,./types
    ,./style
    ,./rgb

proc alignText*(text: string; width: int; align: Align): string =
    case align
    of alignLeft:
        text & " ".repeat(max(0, width - text.len))
    of alignRight:
        " ".repeat(max(0, width - text.len)) & text
    of alignCenter:
        let total = max(0, width - text.len)
        let left  = total div 2
        let right = total - left
        " ".repeat(left) & text & " ".repeat(right)

proc table*(
    headers      : openArray[string]
    ,rows        : openArray[seq[string]]
    ,minWidth    : int = 10
    ,borderStyle : string = "single"
)               : string =
    let numCols = headers.len

    var widths = newSeq[int](numCols)
    for i, h in headers:
        widths[i] = max(minWidth, h.len + 2)

    for row in rows:
        for i, cell in row:
            if i < numCols:
                widths[i] = max(widths[i], cell.len + 2)

    let (tl, tr, bl, br, h, v, tj, bj, lj, rj, cross) =
        if borderStyle == "double":
            ("╔", "╗", "╚", "╝", "═", "║", "╦", "╩", "╠", "╣", "╬")
        elif borderStyle == "rounded":
            ("╭", "╮", "╰", "╯", "─", "│", "┬", "┴", "├", "┤", "┼")
        else:
            ("┌", "┐", "└", "┘", "─", "│", "┬", "┴", "├", "┤", "┼")

    var lines: seq[string] = @[]

    var top = tl
    for i, w in widths:
        top &= h.repeat(w)
        top &= (if i < numCols - 1: tj else: tr)
    lines.add(top)

    var headerRow = v
    for i, hdr in headers:
        headerRow &= alignText(" " & hdr & " ", widths[i], alignCenter)
        headerRow &= v
    lines.add(headerRow)

    var sep = lj
    for i, w in widths:
        sep &= h.repeat(w)
        sep &= (if i < numCols - 1: cross else: rj)
    lines.add(sep)

    for row in rows:
        var dataRow = v
        for i in 0 ..< numCols:
            let cell = (if i < row.len: row[i] else: "")
            dataRow &= alignText(" " & cell & " ", widths[i], alignLeft)
            dataRow &= v
        lines.add(dataRow)

    var bottom = bl
    for i, w in widths:
        bottom &= h.repeat(w)
        bottom &= (if i < numCols - 1: bj else: br)
    lines.add(bottom)

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
            widths[i] = max(widths[i], row[i].len + 2)

    let (tl, tr, bl, br, h, v, tj, bj, lj, rj, cross) =
        if borderStyle == "double":
            ("╔", "╗", "╚", "╝", "═", "║", "╦", "╩", "╠", "╣", "╬")
        elif borderStyle == "rounded":
            ("╭", "╮", "╰", "╯", "─", "│", "┬", "┴", "├", "┤", "┼")
        else:
            ("┌", "┐", "└", "┘", "─", "│", "┬", "┴", "├", "┤", "┼")

    var lines: seq[string] = @[]

    var top = tl
    for i, w in widths:
        top &= h.repeat(w)
        top &= (if i < numCols - 1: tj else: tr)
    lines.add(top)

    var headerRow = v
    for i, hdr in headers:
        headerRow &= alignText(" " & hdr & " ", widths[i], alignCenter)
        headerRow &= v
    lines.add(headerRow)

    var sep = lj
    for i, w in widths:
        sep &= h.repeat(w)
        sep &= (if i < numCols - 1: cross else: rj)
    lines.add(sep)

    for row in rows:
        var dataRow = v
        for i in 0 ..< numCols:
            let cell  = (if i < row.len: row[i] else: "")
            let a     = cols[i].align
            dataRow  &= alignText(" " & cell & " ", widths[i], a)
            dataRow  &= v
        lines.add(dataRow)

    var bottom = bl
    for i, w in widths:
        bottom &= h.repeat(w)
        bottom &= (if i < numCols - 1: bj else: br)
    lines.add(bottom)

    lines.join("\n")

proc simpleTable*(headers: openArray[string]; rows: openArray[seq[string]]): string =
    let numCols = headers.len
    var widths  = newSeq[int](numCols)

    for i, h in headers:
        widths[i] = h.len + 2

    for row in rows:
        for i, cell in row:
            if i < numCols:
                widths[i] = max(widths[i], cell.len + 2)

    var lines: seq[string] = @[]

    var hdrLine = ""
    for i, h in headers:
        hdrLine &= alignText(h, widths[i], alignLeft)
    lines.add($styled(hdrLine).fg(cyan).style(bold))

    var underline = ""
    for w in widths:
        underline &= "─".repeat(w)
    lines.add($styled(underline).fg(brightBlack))

    for row in rows:
        var dataLine = ""
        for i in 0 ..< numCols:
            let cell = if i < row.len: row[i] else: ""
            dataLine &= alignText(cell, widths[i], alignLeft)
        lines.add(dataLine)

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
        widths[i] = max(c.minWidth, c.header.len)

    for row in rows:
        for i in 0 ..< min(numCols, row.len):
            widths[i] = max(widths[i], row[i].len)

    var lines: seq[string] = @[]

    # Header row
    var hdr = ""
    for i, c in cols:
        let cell = alignText(c.header, widths[i], c.align)
        hdr &= $styled(cell).fg(c.headerColor).style(bold)
        if i < numCols - 1:
            hdr &= " ".repeat(colGap)
    lines.add(hdr)

    # Optional underline
    if headerUnderline:
        var ul = ""
        for i, w in widths:
            ul &= "─".repeat(w)
            if i < numCols - 1:
                ul &= " ".repeat(colGap)
        lines.add($styled(ul).fg(brightBlack))

    # Data rows
    for rowIdx, row in rows:
        var line = ""
        let isDim = dimAlternate and (rowIdx mod 2 == 1)

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

            line &= $st
            if i < numCols - 1:
                line &= " ".repeat(colGap)
        lines.add(line)

    lines.join("\n")

discard """

Tables:
- table(headers, rows, ...)         : auto width + borders
- table(cols, rows, ...)            : explicit column width + alignment
- simpleTable(headers, rows)        : header styled, no box borders
- richTable(cols, rows, ...)        : Rich-style borderless with colors and alternating rows

"""