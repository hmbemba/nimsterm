import
    std/unittest
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

discard """

nim c -r tests/t_style.nim

"""
