import
    std/strutils
    ,./style
    ,./types
    ,./util  # Fix #26: For termWidth

proc success*(msg: string) =
    echo $styled("✓ " & msg).fg(green).style(bold)

proc error*(msg: string) =
    echo $styled("✗ " & msg).fg(red).style(bold)

proc warning*(msg: string) =
    echo $styled("⚠ " & msg).fg(yellow).style(bold)

proc info*(msg: string) =
    echo $styled("ℹ " & msg).fg(cyan)

proc debug*(msg: string) =
    echo $styled("● " & msg).fg(brightBlack).style(dim)

# Fix #26: Use termWidth() instead of hardcoded 60
proc header*(msg: string; ch: string = "═"; width: int = -1) =
    ## Print a header with a horizontal rule.
    ## If width is -1 (default), uses terminal width.
    let w = if width <= 0: termWidth() else: width
    let line = ch.repeat(w)
    echo $styled(line).fg(cyan)
    echo $styled(msg).fg(cyan).style(bold).center(w)
    echo $styled(line).fg(cyan)

# Fix #26: Use termWidth() instead of hardcoded 60
proc divider*(ch: string = "─"; width: int = -1; color: Color = brightBlack) =
    ## Print a divider line.
    ## If width is -1 (default), uses terminal width.
    let w = if width <= 0: termWidth() else: width
    echo $styled(ch.repeat(w)).fg(color)

proc bullet*(msg: string; indent: int = 0; marker: string = "•") =
    echo " ".repeat(indent) & $styled(marker & " " & msg).fg(white)

proc numbered*(items: openArray[string]; startNum: int = 1) =
    for i, item in items:
        let n = startNum + i
        echo $styled($n & ". ").fg(cyan) & item

discard """

Semantic output helpers.

header() and divider() now use terminal width by default (Fix #26):
- Pass explicit width to override
- Automatically detects terminal width using termWidth()
- Falls back to 80 columns if detection fails

NO_COLOR support (Fix #23):
- All styled output respects NO_COLOR environment variable
- Set NO_COLOR to any non-empty value to disable colors

"""
