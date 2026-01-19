import
    std/strutils

proc rgb*(r, g, b: int): string =
    "\x1b[38;2;" & $r & ";" & $g & ";" & $b & "m"

proc rgbBg*(r, g, b: int): string =
    "\x1b[48;2;" & $r & ";" & $g & ";" & $b & "m"

proc gradient*(
    text  : string
    ,startR, startG, startB : int
    ,endR  ,endG  ,endB     : int
)       : string =
    if text.len == 0:
        return ""

    for i, c in text:
        let t =
            if text.len > 1:
                i.float / (text.len - 1).float
            else:
                0.0

        let rr = int(startR.float + (endR - startR).float * t)
        let gg = int(startG.float + (endG - startG).float * t)
        let bb = int(startB.float + (endB - startB).float * t)

        result &= rgb(rr, gg, bb) & $c

    result &= "\x1b[0m"

discard """

RGB / TrueColor helpers (24-bit).
Works on modern terminals that support ANSI truecolor.

"""
