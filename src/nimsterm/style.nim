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

"""
