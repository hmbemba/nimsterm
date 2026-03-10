import
    ./termio

const
    EscPrefix* = "\x1b["

proc esc*(s: string): string =
    EscPrefix & s

# Fix #29: NimScript silent degradation - add compile-time warnings for cursor control
# These procs have no effect in NimScript since there's no real terminal to control

proc clearScreen*() =
    ## Clear the terminal screen.
    ## In NimScript: no-op (echoes ANSI codes but terminal may not interpret them)
    when defined(nimscript):
        {.warning: "clearScreen() has no effect in NimScript - no terminal control available".}
    termWrite(esc("2J") & esc("H"))
    termFlush()

proc clearLine*() =
    ## Clear the current line.
    ## In NimScript: no-op (echoes ANSI codes but terminal may not interpret them)
    when defined(nimscript):
        {.warning: "clearLine() has no effect in NimScript - no terminal control available".}
    termWrite(esc("2K") & "\r")
    termFlush()

proc clearToEndOfLine*() =
    ## Clear from cursor to end of line.
    ## In NimScript: no-op (echoes ANSI codes but terminal may not interpret them)
    when defined(nimscript):
        {.warning: "clearToEndOfLine() has no effect in NimScript - no terminal control available".}
    termWrite(esc("0K"))
    termFlush()

proc moveCursorTo*(row, col: int) =
    ## Move cursor to specific row and column (1-indexed).
    ## In NimScript: no-op (echoes ANSI codes but terminal may not interpret them)
    when defined(nimscript):
        {.warning: "moveCursorTo() has no effect in NimScript - no terminal control available".}
    let r = max(1, row)
    let c = max(1, col)
    termWrite(esc($r & ";" & $c & "H"))
    termFlush()

proc cursorUp*(n = 1) =
    ## Move cursor up n lines.
    ## In NimScript: no-op (echoes ANSI codes but terminal may not interpret them)
    when defined(nimscript):
        {.warning: "cursorUp() has no effect in NimScript - no terminal control available".}
    termWrite(esc($(max(1, n)) & "A"))
    termFlush()

proc cursorDown*(n = 1) =
    ## Move cursor down n lines.
    ## In NimScript: no-op (echoes ANSI codes but terminal may not interpret them)
    when defined(nimscript):
        {.warning: "cursorDown() has no effect in NimScript - no terminal control available".}
    termWrite(esc($(max(1, n)) & "B"))
    termFlush()

proc cursorForward*(n = 1) =
    ## Move cursor forward n columns.
    ## In NimScript: no-op (echoes ANSI codes but terminal may not interpret them)
    when defined(nimscript):
        {.warning: "cursorForward() has no effect in NimScript - no terminal control available".}
    termWrite(esc($(max(1, n)) & "C"))
    termFlush()

proc cursorBack*(n = 1) =
    ## Move cursor back n columns.
    ## In NimScript: no-op (echoes ANSI codes but terminal may not interpret them)
    when defined(nimscript):
        {.warning: "cursorBack() has no effect in NimScript - no terminal control available".}
    termWrite(esc($(max(1, n)) & "D"))
    termFlush()

proc hideCursor*() =
    ## Hide the cursor.
    ## In NimScript: no-op (echoes ANSI codes but terminal may not interpret them)
    when defined(nimscript):
        {.warning: "hideCursor() has no effect in NimScript - no terminal control available".}
    termWrite(esc("?25l"))
    termFlush()

proc showCursor*() =
    ## Show the cursor.
    ## In NimScript: no-op (echoes ANSI codes but terminal may not interpret them)
    when defined(nimscript):
        {.warning: "showCursor() has no effect in NimScript - no terminal control available".}
    termWrite(esc("?25h"))
    termFlush()

proc saveCursor*() =
    ## Save cursor position.
    ## In NimScript: no-op (echoes ANSI codes but terminal may not interpret them)
    when defined(nimscript):
        {.warning: "saveCursor() has no effect in NimScript - no terminal control available".}
    termWrite(esc("s"))
    termFlush()

proc restoreCursor*() =
    ## Restore cursor position.
    ## In NimScript: no-op (echoes ANSI codes but terminal may not interpret them)
    when defined(nimscript):
        {.warning: "restoreCursor() has no effect in NimScript - no terminal control available".}
    termWrite(esc("u"))
    termFlush()

proc scrollUp*(n = 1) =
    ## Scroll up n lines.
    ## In NimScript: no-op (echoes ANSI codes but terminal may not interpret them)
    when defined(nimscript):
        {.warning: "scrollUp() has no effect in NimScript - no terminal control available".}
    termWrite(esc($(max(1, n)) & "S"))
    termFlush()

proc scrollDown*(n = 1) =
    ## Scroll down n lines.
    ## In NimScript: no-op (echoes ANSI codes but terminal may not interpret them)
    when defined(nimscript):
        {.warning: "scrollDown() has no effect in NimScript - no terminal control available".}
    termWrite(esc($(max(1, n)) & "T"))
    termFlush()

discard """

Terminal control sequences.

NimScript Limitations (Fix #29):
- Cursor control procs (moveCursorTo, cursorUp/Down/Forward/Back, etc.) have no effect in NimScript
- They will produce compile-time warnings when used in NimScript
- The ANSI codes are still echoed, but the NimScript execution environment doesn't have
  a real terminal to interpret them
- Safe to call - they degrade gracefully by doing nothing useful

Recommended alternatives for NimScript:
- Use simple echo/print statements instead of cursor movement
- Use progressBar() string function instead of interactive progress
- Avoid clearScreen(), clearLine() - use multiple newlines instead

Native Nim (compiled):
- All control sequences work as expected
- Full terminal control available

"""
