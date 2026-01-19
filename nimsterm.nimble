# nimsterm.nimble

version       = "0.1.0"
author        = "you"
description   = "Windows-friendly terminal helpers that work in both Nim and NimScript."
license       = "MIT"
srcDir        = "src"
bin           = @[]

requires "nim >= 1.6.0"

task test, "Run tests (native Nim)":
    exec "nim c -r -d:ssl tests/t_all.nim"

task test_nims, "Run NimScript smoke test":
    exec "nim e tests/t_nimscript_smoke.nims"

discard """

nimble test
nimble test_nims

"""
