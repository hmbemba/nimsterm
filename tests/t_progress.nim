import
    std/unittest
    ,../src/nimsterm

suite "progress":
    test "progressBar width":
        let bar = progressBar(5, 10, width = 10)
        check bar.len >= 2 + 10

    test "spinnerFrame cycles":
        let f0 = spinnerFrame(0, SPINNER_SIMPLE)
        let f3 = spinnerFrame(3, SPINNER_SIMPLE)
        check f0.len > 0
        check f3.len > 0

discard """

nim c -r tests/t_progress.nim

"""
