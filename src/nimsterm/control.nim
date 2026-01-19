import
    ./termio

const
    EscPrefix* = "\x1b["

proc esc*(s: string): string =
    EscPrefix & s

proc clearScreen*() =
    termWrite(esc("2J") & esc("H"))
    termFlush()

proc clearLine*() =
    termWrite(esc("2K") & "\r")
    termFlush()

proc clearToEndOfLine*() =
    termWrite(esc("0K"))
    termFlush()

proc moveCursorTo*(row, col: int) =
    let r = max(1, row)
    let c = max(1, col)
    termWrite(esc($r & ";" & $c & "H"))
    termFlush()

proc cursorUp*(n = 1) =
    termWrite(esc($(max(1, n)) & "A"))
    termFlush()

proc cursorDown*(n = 1) =
    termWrite(esc($(max(1, n)) & "B"))
    termFlush()

proc cursorForward*(n = 1) =
    termWrite(esc($(max(1, n)) & "C"))
    termFlush()

proc cursorBack*(n = 1) =
    termWrite(esc($(max(1, n)) & "D"))
    termFlush()

proc hideCursor*() =
    termWrite(esc("?25l"))
    termFlush()

proc showCursor*() =
    termWrite(esc("?25h"))
    termFlush()

proc saveCursor*() =
    termWrite(esc("s"))
    termFlush()

proc restoreCursor*() =
    termWrite(esc("u"))
    termFlush()

proc scrollUp*(n = 1) =
    termWrite(esc($(max(1, n)) & "S"))
    termFlush()

proc scrollDown*(n = 1) =
    termWrite(esc($(max(1, n)) & "T"))
    termFlush()

discard """

Terminal control sequences.

In NimScript:
- output is best-effort (echo newline), but these remain useful when piping to modern terminals.

"""
