import
    std/strutils
    ,./style
    ,./types

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

proc header*(msg: string; ch: string = "═"; width: int = 60) =
    let line = ch.repeat(width)
    echo $styled(line).fg(cyan)
    echo $styled(msg).fg(cyan).style(bold).center(width)
    echo $styled(line).fg(cyan)

proc divider*(ch: string = "─"; width: int = 60; color: Color = brightBlack) =
    echo $styled(ch.repeat(width)).fg(color)

proc bullet*(msg: string; indent: int = 0; marker: string = "•") =
    echo " ".repeat(indent) & $styled(marker & " " & msg).fg(white)

proc numbered*(items: openArray[string]; startNum: int = 1) =
    for i, item in items:
        let n = startNum + i
        echo $styled($n & ". ").fg(cyan) & item

discard """

Semantic output helpers.

"""
