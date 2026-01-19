import
    std/unittest
    ,../src/nimsterm

suite "util":
    test "parseIntOr fallback":
        check parseIntOr("nope", 7) == 7
        check parseIntOr(" 42 ", 7) == 42

    test "stripAnsi removes codes":
        let s = "\x1b[31mRED\x1b[0m"
        check stripAnsi(s) == "RED"

discard """

nim c -r tests/t_util.nim

"""
