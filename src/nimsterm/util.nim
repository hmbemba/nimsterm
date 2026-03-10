import
    std/[os, strutils]
    ,./types

when not defined(nimscript):
    import std/terminal

# Fix #23: NO_COLOR support - check no-color.org standard
proc noColorMode*(): bool =
    ## Check if NO_COLOR environment variable is set.
    ## Per no-color.org: any non-empty value disables color.
    ## Note: This does NOT check for non-TTY (piped output) by default
    ## to allow explicit user control via NO_COLOR. If you want to disable
    ## colors for piped output, check isatty separately.
    let noColor = getEnv("NO_COLOR", "")
    result = noColor.len > 0

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

# ─── Fix #14: Consolidated alignText ──────────────────────────────

proc alignText*(text: string; width: int; align: Align): string =
    ## Align text within a given width, accounting for ANSI codes.
    ## Fix #14: Consolidated from table.nim and style.nim
    let visualLen = stripAnsi(text).len
    case align
    of alignLeft:
        text & " ".repeat(max(0, width - visualLen))
    of alignRight:
        " ".repeat(max(0, width - visualLen)) & text
    of alignCenter:
        let total = max(0, width - visualLen)
        let left  = total div 2
        let right = total - left
        " ".repeat(left) & text & " ".repeat(right)

discard """

Terminal sizing, ANSI stripping, and text alignment utilities.

termSize:
- Native Nim: uses std/terminal terminalWidth() / terminalHeight()
- NimScript: uses env vars COLUMNS / LINES
- Fallback: 80x24

noColorMode: (Fix #23)
- Checks NO_COLOR environment variable per no-color.org standard
- Returns true if set to any non-empty value
- Does NOT automatically disable colors for piped output
  (use explicit NO_COLOR=1 if you want that behavior)

stripAnsi:
- Removes common ESC[ ... control sequences used by this library

alignText:
- Aligns text within a width (left, center, right)
- Properly handles ANSI escape codes
- Fix #14: Consolidated from table.nim and style.nim to eliminate duplication

"""
