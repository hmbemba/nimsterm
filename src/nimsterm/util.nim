import
    std/[os, strutils]
    ,./types

when not defined(nimscript):
    import std/terminal

proc parseIntOr*(s: string; fallback: int): int =
    try:
        result = s.strip().parseInt()
    except CatchableError:
        result = fallback

proc termSize*(fallbackW = 80; fallbackH = 24): TermSize =
    when defined(nimscript):
        let w = parseIntOr(getEnv("COLUMNS", $fallbackW), fallbackW)
        let h = parseIntOr(getEnv("LINES",   $fallbackH), fallbackH)
        result = TermSize(w: max(1, w), h: max(1, h))
    else:
        try:
            let w = terminalWidth()
            let h = terminalHeight()
            result = TermSize(w: max(1, w), h: max(1, h))
        except CatchableError:
            let w = parseIntOr(getEnv("COLUMNS", $fallbackW), fallbackW)
            let h = parseIntOr(getEnv("LINES",   $fallbackH), fallbackH)
            result = TermSize(w: max(1, w), h: max(1, h))

proc termWidth*(fallbackW = 80): int =
    termSize(fallbackW = fallbackW).w

proc termHeight*(fallbackH = 24): int =
    termSize(fallbackH = fallbackH).h

proc stripAnsi*(s: string): string =
    var i = 0
    while i < s.len:
        if s[i] == '\x1b' and i + 1 < s.len and s[i + 1] == '[':
            i += 2
            while i < s.len and s[i] notin {
                'm'
                ,'K'
                ,'J'
                ,'H'
                ,'A'
                ,'B'
                ,'C'
                ,'D'
                ,'s'
                ,'u'
                ,'S'
                ,'T'
            }:
                inc i
            if i < s.len:
                inc i
        else:
            result.add s[i]
            inc i

discard """

Terminal sizing and ANSI stripping.

termSize:
- Native Nim: uses std/terminal terminalWidth() / terminalHeight()
- NimScript: uses env vars COLUMNS / LINES
- Fallback: 80x24

stripAnsi:
- Removes common ESC[ ... control sequences used by this library

"""