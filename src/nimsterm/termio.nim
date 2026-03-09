import std/strutils

when defined(nimscript):
    # NimScript version - uses echo for output
    proc termWrite*(s: string) =
        echo s  # NimScript doesn't have stdout access, so we use echo

    proc termFlush*() =
        discard  # No-op in NimScript

    proc termWriteFlush*(s: string) =
        echo s

    proc readInputLine*(): string =
        result = ""  # Cannot read from stdin in NimScript
else:
    # Compiled Nim version - uses std/syncio
    import std/syncio

    proc termWrite*(s: string) =
        stdout.write s

    proc termFlush*() =
        stdout.flushFile()

    proc termWriteFlush*(s: string) =
        stdout.write s
        stdout.flushFile()

    proc readInputLine*(): string =
        result = stdin.readLine().strip()

discard """

Cross-platform terminal IO helpers.
Works on Linux, Windows, and macOS.

Note: In NimScript mode, output uses echo (newlines added).
In compiled mode, uses std/syncio for direct stdout control.

"""
