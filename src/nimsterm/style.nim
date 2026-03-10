import
    std/[strutils, sequtils]
    ,./types
    ,./util  # Fix #3, #14: For stripAnsi and alignText, Fix #23: For noColorMode

proc styled*(s: string): StyledText =
    result.text   = s
    result.fg     = colDefault
    result.bg     = colDefault
    result.styles = @[]
    result.useFgRgb = false
    result.useBgRgb = false
    result.noReset = false

proc fg*(s: StyledText; color: Color): StyledText =
    result    = s
    result.fg = color
    result.useFgRgb = false  # Clear RGB when using enum

proc bg*(s: StyledText; color: Color): StyledText =
    result    = s
    result.bg = color
    result.useBgRgb = false  # Clear RGB when using enum

# Fix #1: Add RGB overloads for fg and bg
proc fg*(s: StyledText; rgb: RgbColor): StyledText =
    result    = s
    result.fgR = rgb.r
    result.fgG = rgb.g
    result.fgB = rgb.b
    result.useFgRgb = true

proc fg*(s: StyledText; r, g, b: int): StyledText =
    result    = s
    result.fgR = r
    result.fgG = g
    result.fgB = b
    result.useFgRgb = true

proc bg*(s: StyledText; rgb: RgbColor): StyledText =
    result    = s
    result.bgR = rgb.r
    result.bgG = rgb.g
    result.bgB = rgb.b
    result.useBgRgb = true

proc bg*(s: StyledText; r, g, b: int): StyledText =
    result    = s
    result.bgR = r
    result.bgG = g
    result.bgB = b
    result.useBgRgb = true

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
    result.useFgRgb = false
    result.useBgRgb = false
    # Keep noReset as-is

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
            # Fix #19: Use seq for building line parts instead of repeated concatenation
            currentLine.add(" ")
            currentLine.add(word)
        else:
            lines.add(currentLine)
            currentLine = word

    if currentLine.len > 0:
        lines.add(currentLine)

    result.text = lines.join("\n")

# ─── new: word-wrap + alignment helpers ───────────────────────────

# Fix #7: Explicit ANSI code mapping for Style enum using a procedure
proc styleToAnsiCode(st: Style): int =
    ## Maps Style enum to ANSI SGR code explicitly.
    ## This avoids relying on fragile enum ord values.
    case st
    of bold:          1
    of dim:           2
    of italic:        3
    of underline:     4
    of blink:         5
    of reverse:       7
    of hidden:        8
    of strikethrough: 9

# Fix #9: Helper to break long words
proc breakLongWord(word: string; width: int): seq[string] =
    ## Break a word that's longer than width into chunks.
    ## Uses hyphen at break point for natural breaking.
    if word.len <= width:
        return @[word]
    
    var i = 0
    while i < word.len:
        let remaining = word.len - i
        if remaining <= width:
            # Last chunk - fits entirely
            result.add(word[i ..< word.len])
            break
        else:
            # Break with hyphen (except if width is very small)
            let chunkSize = if width > 1: width - 1 else: width
            result.add(word[i ..< i + chunkSize] & "-")
            i += chunkSize

proc wrapLines*(text: string; width: int): seq[string] =
    ## Word-wrap plain text into lines of at most `width` characters.
    ## Fix #9: Long words are broken with hyphens.
    if width <= 0:
        return @[text]

    var lines       : seq[string] = @[]
    var currentLine = ""

    for word in text.split(' '):
        if word.len == 0:
            continue
        
        # Fix #9: Handle words longer than width
        if word.len > width:
            # Flush current line first if it has content
            if currentLine.len > 0:
                lines.add(currentLine)
                currentLine = ""
            
            # Break the long word into chunks
            let chunks = breakLongWord(word, width)
            for i, chunk in chunks:
                if i < chunks.high:
                    # Intermediate chunk ends with hyphen, add as complete line
                    lines.add(chunk)
                else:
                    # Last chunk - start a new line with it
                    currentLine = chunk
        elif currentLine.len == 0:
            currentLine = word
        elif currentLine.len + 1 + word.len <= width:
            # Fix #19: Use add() instead of &= for better performance
            currentLine.add(" ")
            currentLine.add(word)
        else:
            lines.add(currentLine)
            currentLine = word

    if currentLine.len > 0:
        lines.add(currentLine)

    lines

# Fix #14: alignLine now uses the consolidated alignText from util.nim
proc alignLine*(line: string; width: int; align: Align): string =
    ## Pad a single line to `width` using the given alignment.
    ## Fix #8, #14: Uses consolidated alignText from util.nim
    alignText(line, width, align)

proc justifyLine*(line: string; width: int): string =
    ## Full-justify a single line by distributing extra spaces between words.
    ## Fix #8: Use stripAnsi for visual width calculation
    let words = line.splitWhitespace()
    if words.len <= 1:
        let visualLen = stripAnsi(line).len
        return line & " ".repeat(max(0, width - visualLen))

    let totalChars = words.foldl(a + stripAnsi(b).len, 0)
    let totalGaps  = words.len - 1
    let extraSpace = max(0, width - totalChars)
    let baseGap    = extraSpace div totalGaps
    let remainder  = extraSpace mod totalGaps

    # Fix #19: Use seq for building result instead of repeated concatenation
    var parts: seq[string] = newSeqOfCap[string](words.len + totalGaps)
    for i, word in words:
        parts.add(word)
        if i < totalGaps:
            let gap = baseGap + (if i < remainder: 1 else: 0)
            parts.add(" ".repeat(gap))
    result = parts.join("")

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
            let visualLen = stripAnsi(line).len
            justified.add(line & " ".repeat(max(0, width - visualLen)))
        else:
            justified.add(justifyLine(line, width))
    justified.join("\n")

# ─── end new procs ────────────────────────────────────────────────

proc boxed*(s: StyledText; boxStyle: string = "single"; padding: int = 1): StyledText =
    let lines   = s.text.split('\n')
    var maxLen  = 0
    # Fix #3: Use stripAnsi for visual width calculation
    for line in lines:
        let visualLen = stripAnsi(line).len
        maxLen = max(maxLen, visualLen)

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
        let visualLen = stripAnsi(line).len
        let padded =
            " ".repeat(padding) &
            line &
            " ".repeat(max(0, maxLen - visualLen + padding))
        output.add(v & padded & v)

    output.add(bl & h.repeat(contentWidth) & br)

    result      = s
    result.text = output.join("\n")

proc toText*(s: StyledText): string =
    s.text

proc len*(s: StyledText): int =
    s.text.len

proc ansiCode*(s: StyledText): string =
    # Fix #23: NO_COLOR support - return empty string if colors disabled
    if noColorMode():
        return ""
    
    var codes: seq[string] = @[]

    # Fix #7: Use explicit Style to ANSI code mapping instead of ord(st)
    for st in s.styles:
        codes.add($styleToAnsiCode(st))

    # Fix #1: Support RGB foreground
    if s.useFgRgb:
        codes.add("38;2;" & $s.fgR & ";" & $s.fgG & ";" & $s.fgB)
    elif s.fg != colDefault:
        let base = if ord(s.fg) >= 60: 90 else: 30
        codes.add($(base + (ord(s.fg) mod 10)))

    # Fix #1: Support RGB background
    if s.useBgRgb:
        codes.add("48;2;" & $s.bgR & ";" & $s.bgG & ";" & $s.bgB)
    elif s.bg != colDefault:
        let base = if ord(s.bg) >= 60: 100 else: 40
        codes.add($(base + (ord(s.bg) mod 10)))

    if codes.len == 0:
        return ""

    "\x1b[" & codes.join(";") & "m"

proc render*(s: StyledText): string =
    # Fix #23: NO_COLOR support - return plain text if colors disabled
    if noColorMode():
        return s.text
    
    let code = ansiCode(s)
    if code.len == 0:
        return s.text
    # Fix #6: Respect noReset flag for composition
    let resetCode = if s.noReset: "" else: "\x1b[0m"
    code & s.text & resetCode

# Fix #6: Add compose helper for nested styling
proc compose*(s: StyledText): StyledText =
    ## Mark this StyledText for composition - it won't add reset at the end.
    ## Use this when combining multiple styled texts.
    result = s
    result.noReset = true

proc `$`*(s: StyledText): string =
    s.render()

discard """

Styled text builder.

Key behavior:
- render() returns "ESC[...m" + text + "ESC[0m" (if any style/color set)
- reset() clears styles/colors but keeps the same text
- RGB colors via fg(rgb) or fg(r, g, b) overloads (Fix #1)
- compose() prevents adding reset code for nested styling (Fix #6)
- NO_COLOR support: returns plain text when NO_COLOR env var is set (Fix #23)

Word-wrap + alignment:
- wrapLines(text, width)              : split into lines of at most width
- alignLine(line, width, align)       : pad a single line left/center/right
- justifyLine(line, width)            : full-justify a single line
- wrapAlign(text, width, align)       : wrap then align all lines
- wrapJustify(text, width)            : wrap then full-justify (last line left)

Fixes:
- Fix #7: Explicit Style to ANSI code mapping (not relying on enum ord)
- Fix #8: stripAnsi for visual width calculation
- Fix #9: Long words are broken with hyphens in wrapLines
- Fix #14: alignLine uses consolidated alignText from util.nim
- Fix #19: String concatenation in loops optimized (seq + join pattern)
- Fix #23: NO_COLOR support per no-color.org standard

"""
