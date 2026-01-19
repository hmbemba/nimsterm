import
    std/strutils
    ,./types
    ,./termio
    ,./style

proc confirm*(question: string; default = false): bool =
    let hint     = if default: "(Y/n)" else: "(y/N)"
    let promptSt = styled("❓ " & question & " " & hint & ": ").fg(cyan).style(bold)
    termWriteFlush($promptSt)

    let response = readInputLine().toLowerAscii()
    if response.len == 0:
        return default
    response in ["y", "yes"]

proc confirmm*(question: string; default = false): bool =
    confirm(question, default)

template confirmed*(question: string; body: untyped) =
    if confirm(question):
        body
    else:
        echo styled("Cancelled.").fg(red).style(dim)

proc prompt*(question: string; defaultVal = ""): string =
    let defaultHint =
        if defaultVal.len > 0: " [" & defaultVal & "]"
        else: ""

    let promptSt = styled("? " & question & defaultHint & ": ").fg(cyan).style(bold)
    termWriteFlush($promptSt)

    result = readInputLine()
    if result.len == 0 and defaultVal.len > 0:
        result = defaultVal

proc promptInt*(question: string; defaultVal = 0): int =
    while true:
        let response = prompt(question, $defaultVal)
        try:
            return parseInt(response)
        except ValueError:
            echo styled("  Please enter a valid number.").fg(red)

proc promptPassword*(question: string): string =
    let promptSt = styled("🔒 " & question & ": ").fg(cyan).style(bold)
    termWriteFlush($promptSt)
    result = readInputLine()

proc promptChoice*(
    question    : string
    ,choices    : openArray[string]
    ,defaultIdx : int = 0
)               : MenuResult =
    echo styled("? " & question).fg(cyan).style(bold)

    for i, choice in choices:
        let marker = if i == defaultIdx: "●" else: "○"
        let color  = if i == defaultIdx: green else: colDefault
        echo styled("  " & marker & " " & $i & ") " & choice).fg(color)

    termWriteFlush($styled("  Enter choice [" & $defaultIdx & "]: ").fg(cyan))
    let response = readInputLine()

    if response.len == 0 and choices.len > 0 and defaultIdx >= 0 and defaultIdx < choices.len:
        return MenuResult(index: defaultIdx, value: choices[defaultIdx], cancelled: false)

    try:
        let idx = parseInt(response)
        if idx >= 0 and idx < choices.len:
            return MenuResult(index: idx, value: choices[idx], cancelled: false)
    except ValueError:
        discard

    MenuResult(index: -1, value: "", cancelled: true)

proc choose*(
    question      : string
    ,options      : seq[string]
    ,defaultIndex : int = 0
)                 : int =
    echo question
    for i, opt in options:
        echo "  " & $(i + 1) & ") " & opt

    let idx1 = promptInt("Choose", defaultIndex + 1)
    result   = max(0, min(options.len - 1, idx1 - 1))

discard """

Interactive input helpers.

Note:
- promptPassword is a basic version that still echoes input.
  True hidden password entry is platform-specific and can be added later.

"""
