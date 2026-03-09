import
    std/[strutils, sequtils]
    ,./types

proc styled*(s: string): StyledText =
    result.text   = s
    result.fg     = colDefault
    result.bg     = colDefault
    result.styles = @[]

proc fg*(s: StyledText; color: Color): StyledText =
    result    = s
    result.fg = color

proc bg*(s: StyledText; color: Color): StyledText =
    result    = s
    result.bg = color

proc style*(s: StyledText; styles: varargs[Style]): StyledText =
    result = s
    for st in styles:
        if st notin result.styles:
            result.styles.add(st)

proc reset*(s: StyledText): StyledText =
    result        = s
    result.fg     = colDefault
    result.bg     = colDefault
    result.styles = @[]

proc append*(s: StyledText; more: string): StyledText =
    result      = s
    result.text &= more

proc repeat*(s: StyledText; n: int): StyledText =
    result      = s
    result.text = s.text.repeat(n)

proc padLeft*(s: StyledText; n: int; pad: char = ' '): StyledText =
    result      = s
    result.text = ($pad).repeat(max(0, n - s.text.len)) & s.text

proc padRight*(s: StyledText; n: int; pad: char = ' '): StyledText =
    result      = s
    result.text = s.text & ($pad).repeat(max(0, n - s.text.len))

proc center*(s: StyledText; width: int; pad: char = ' '): StyledText =
    result           = s
    let totalPad     = max(0, width - s.text.len)
    let leftPad      = totalPad div 2
    let rightPad     = totalPad - leftPad
    result.text      = ($pad).repeat(leftPad) & s.text & ($pad).repeat(rightPad)

proc truncate*(s: StyledText; maxLen: int; suffix: string = "..."): StyledText =
    result = s
    if s.text.len > maxLen and maxLen >= suffix.len:
        result.text = s.text[0 ..< (maxLen - suffix.len)] & suffix

proc wrap*(s: StyledText; width: int): StyledText =
    result              = s
    if width <= 0:
        return

    var lines           : seq[string] = @[]
    var currentLine     = ""

    for word in s.text.split(' '):
        if currentLine.len == 0:
            currentLine = word
        elif currentLine.len + 1 + word.len <= width:
            currentLine &= " " & word
        else:
            lines.add(currentLine)
            currentLine = word

    if currentLine.len > 0:
        lines.add(currentLine)

    result.text = lines.join("\n")

# ─── new: word-wrap + alignment helpers ───────────────────────────

proc wrapLines*(text: string; width: int): seq[string] =
    ## Word-wrap plain text into lines of at most `width` characters.
    if width <= 0:
        return @[text]

    var lines       : seq[string] = @[]
    var currentLine = ""

    for word in text.split(' '):
        if word.len == 0:
            continue
        if currentLine.len == 0:
            currentLine = word
        elif currentLine.len + 1 + word.len <= width:
            currentLine &= " " & word
        else:
            lines.add(currentLine)
            currentLine = word

    if currentLine.len > 0:
        lines.add(currentLine)

    lines

proc alignLine*(line: string; width: int; align: Align): string =
    ## Pad a single line to `width` using the given alignment.
    case align
    of alignLeft:
        line & " ".repeat(max(0, width - line.len))
    of alignRight:
        " ".repeat(max(0, width - line.len)) & line
    of alignCenter:
        let total = max(0, width - line.len)
        let left  = total div 2
        let right = total - left
        " ".repeat(left) & line & " ".repeat(right)

proc justifyLine*(line: string; width: int): string =
    ## Full-justify a single line by distributing extra spaces between words.
    let words = line.splitWhitespace()
    if words.len <= 1:
        return line & " ".repeat(max(0, width - line.len))

    let totalChars = words.foldl(a + b.len, 0)
    let totalGaps  = words.len - 1
    let extraSpace = max(0, width - totalChars)
    let baseGap    = extraSpace div totalGaps
    let remainder  = extraSpace mod totalGaps

    for i, word in words:
        result &= word
        if i < totalGaps:
            let gap = baseGap + (if i < remainder: 1 else: 0)
            result &= " ".repeat(gap)

proc wrapAlign*(text: string; width: int; align: Align): string =
    ## Word-wrap text, then align each line (left / center / right).
    let lines = wrapLines(text, width)
    var aligned: seq[string] = @[]
    for line in lines:
        aligned.add(alignLine(line, width, align))
    aligned.join("\n")

proc wrapJustify*(text: string; width: int): string =
    ## Word-wrap text with full justification.
    ## Last line is left-aligned (standard typographic convention).
    let lines = wrapLines(text, width)
    if lines.len == 0:
        return ""

    var justified: seq[string] = @[]
    for i, line in lines:
        if i == lines.high:
            # last line: left-align
            justified.add(line & " ".repeat(max(0, width - line.len)))
        else:
            justified.add(justifyLine(line, width))
    justified.join("\n")

# ─── end new procs ────────────────────────────────────────────────

proc boxed*(s: StyledText; boxStyle: string = "single"; padding: int = 1): StyledText =
    let lines   = s.text.split('\n')
    var maxLen  = 0
    for line in lines:
        maxLen = max(maxLen, line.len)

    let contentWidth = maxLen + (padding * 2)

    let (tl, tr, bl, br, h, v) =
        if boxStyle == "double":
            ("╔", "╗", "╚", "╝", "═", "║")
        elif boxStyle == "rounded":
            ("╭", "╮", "╰", "╯", "─", "│")
        elif boxStyle == "heavy":
            ("┏", "┓", "┗", "┛", "━", "┃")
        else:
            ("┌", "┐", "└", "┘", "─", "│")

    var output  : seq[string] = @[]
    output.add(tl & h.repeat(contentWidth) & tr)

    for line in lines:
        let padded =
            " ".repeat(padding) &
            line &
            " ".repeat(max(0, maxLen - line.len + padding))
        output.add(v & padded & v)

    output.add(bl & h.repeat(contentWidth) & br)

    result      = s
    result.text = output.join("\n")

proc toText*(s: StyledText): string =
    s.text

proc len*(s: StyledText): int =
    s.text.len

proc ansiCode*(s: StyledText): string =
    var codes: seq[string] = @[]

    for st in s.styles:
        codes.add($ord(st))

    if s.fg != colDefault:
        let base = if ord(s.fg) >= 60: 90 else: 30
        codes.add($(base + (ord(s.fg) mod 10)))

    if s.bg != colDefault:
        let base = if ord(s.bg) >= 60: 100 else: 40
        codes.add($(base + (ord(s.bg) mod 10)))

    if codes.len == 0:
        return ""

    "\x1b[" & codes.join(";") & "m"

proc render*(s: StyledText): string =
    let code = ansiCode(s)
    if code.len == 0:
        return s.text
    code & s.text & "\x1b[0m"

proc `$`*(s: StyledText): string =
    s.render()

discard """

Styled text builder.

Key behavior:
- render() returns "ESC[...m" + text + "ESC[0m" (if any style/color set)
- reset() clears styles/colors but keeps the same text

Word-wrap + alignment:
- wrapLines(text, width)              : split into lines of at most width
- alignLine(line, width, align)       : pad a single line left/center/right
- justifyLine(line, width)            : full-justify a single line
- wrapAlign(text, width, align)       : wrap then align all lines
- wrapJustify(text, width)            : wrap then full-justify (last line left)

"""