import
    std/[unittest, strutils]  # Added strutils for contains
    ,nimsterm

suite "style":
    test "render adds reset when styled":
        let s = styled("hi").fg(green).style(bold)
        let r = s.render()
        check r.contains("\x1b[")
        check r.endsWith("\x1b[0m")

    test "render returns plain text when no styles":
        let s = styled("hi")
        check s.render() == "hi"

    test "boxed contains borders":
        let b = styled("X").boxed("single").toText()
        check b.contains("┌")
        check b.contains("┐")
        check b.contains("└")
        check b.contains("┘")

    # New tests for API fixes
    test "RGB color support via tuple":
        let s = styled("RGB").fg(255, 100, 50)
        check s.useFgRgb == true
        check s.fgR == 255
        check s.fgG == 100
        check s.fgB == 50
        let r = s.render()
        check r.contains("38;2;")

    test "RGB color support via RgbColor":
        let c: RgbColor = (100, 150, 200)
        let s = styled("RGB").fg(c)
        check s.useFgRgb == true
        let r = s.render()
        check r.contains("38;2;")

    test "RGB backward compatibility with Color enum":
        let s = styled("Enum").fg(red)
        check s.useFgRgb == false
        check s.fg == red

    test "hexToRgb converts hex correctly":
        check hexToRgb("#FF0000") == (255, 0, 0)
        check hexToRgb("#00FF00") == (0, 255, 0)
        check hexToRgb("#0000FF") == (0, 0, 255)
        check hexToRgb("F00") == (255, 0, 0)  # Short form
        check hexToRgb("#ABC") == (170, 187, 204)  # Short form with #

    test "boxed uses visual width for ANSI text":
        let styledText = styled("Test").fg(red)
        let boxed = styledText.boxed()
        let text = boxed.toText()
        # The box width should be based on visual width (4) not ANSI length
        check text.contains("│ Test │")

    test "compose prevents reset code":
        let s1 = styled("A").fg(red).compose()
        let s2 = styled("B").fg(blue)
        let combined = $s1 & $s2
        # Should not have double reset
        check not combined.contains("\x1b[0m\x1b[0m")

discard """

nim c -r tests/t_style.nim

"""
