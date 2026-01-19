import
    std/strutils

proc termWrite*(s: string) =
    when defined(nimscript):
        echo s
    else:
        stdout.write s

proc termFlush*() =
    when defined(nimscript):
        discard
    else:
        stdout.flushFile()

proc termWriteFlush*(s: string) =
    termWrite(s)
    termFlush()

proc readInputLine*(): string =
    when defined(windows):
        when defined(nimscript):
            result = readLineFromStdIn().strip()
        else:
            result = stdin.readLine.strip()
    else:
        result = readLineFromStdIn().strip()

discard """

Nim + NimScript friendly IO helpers.

NimScript fallback uses echo (newline) for output.
Input uses readLineFromStdIn() where needed.

"""
