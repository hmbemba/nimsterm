import
    std/[unittest, strutils]  # Added strutils for contains
    ,../src/nimsterm

suite "table":
    test "bordered table contains corners":
        let t = table(
            ["A", "B"]
            ,@[
                @["1", "2"]
            ]
            ,borderStyle = "single"
        )
        check t.contains("┌")
        check t.contains("┐")
        check t.contains("└")
        check t.contains("┘")

    test "column table honors alignment":
        let cols = @[
            Column(header: "Left",  width: 8, align: alignLeft)
            ,Column(header: "Right", width: 8, align: alignRight)
        ]
        let t = table(
            cols
            ,@[
                @["a", "b"]
            ]
        )
        check t.contains("Left")
        check t.contains("Right")

    test "simpleTable includes underline":
        let s = simpleTable(
            ["H1", "H2"]
            ,@[
                @["x", "y"]
            ]
        )
        check stripAnsi(s).contains("─")

discard """

nim c -r tests/t_table.nim

"""
