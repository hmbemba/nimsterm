import
    std/[strutils, unicode]  # Fix #2: Import unicode for rune iteration
    ,./types  # For RgbColor type

proc rgb*(r, g, b: int): string =
    "\x1b[38;2;" & $r & ";" & $g & ";" & $b & "m"

proc rgbBg*(r, g, b: int): string =
    "\x1b[48;2;" & $r & ";" & $g & ";" & $b & "m"

proc hexToRgb*(hex: string): RgbColor =
    ## Convert hex color (e.g., "#FF5733" or "FF5733") to RGB tuple
    var h = hex
    if h.startswith("#"):
        h = h[1..^1]
    if h.len == 3:
        # Short form like "F57" -> "FF5577"
        h = $h[0] & $h[0] & $h[1] & $h[1] & $h[2] & $h[2]
    if h.len == 6:
        try:
            let r = parseHexInt(h[0..1])
            let g = parseHexInt(h[2..3])
            let b = parseHexInt(h[4..5])
            return (r.int, g.int, b.int)
        except ValueError:
            discard
    # Return default (white) on error
    return (255, 255, 255)

proc gradient*(
    text  : string
    ,startR, startG, startB : int
    ,endR  ,endG  ,endB     : int
)       : string =
    if text.len == 0:
        return ""

    # Fix #2: Use rune iteration for proper UTF-8 support
    let runes = text.toRunes()
    let totalRunes = runes.len

    for i, r in runes:
        let t =
            if totalRunes > 1:
                i.float / (totalRunes - 1).float
            else:
                0.0

        let rr = int(startR.float + (endR - startR).float * t)
        let gg = int(startG.float + (endG - startG).float * t)
        let bb = int(startB.float + (endB - startB).float * t)

        result &= rgb(rr, gg, bb) & $r

    result &= "\x1b[0m"

discard """

RGB / TrueColor helpers (24-bit).
Works on modern terminals that support ANSI truecolor.

- hexToRgb: Convert hex colors like "#FF5733" to RGB tuples
- gradient: Now supports UTF-8 text properly using rune iteration (Fix #2)

"""
