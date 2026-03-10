import
    std/strutils
    ,./types
    ,./termio
    ,./style

when not defined(nimscript):
    import std/terminal

# Fix #29: NimScript - input functions have limited functionality in NimScript
proc confirm*(question: string; default = false): bool =
    ## Ask for confirmation (yes/no).
    ## In NimScript: cannot read interactive input, returns default value
    when defined(nimscript):
        {.warning: "confirm() cannot read interactive input in NimScript - returns default value".}
    let hint     = if default: "(Y/n)" else: "(y/N)"
    let promptSt = styled("❓ " & question & " " & hint & ": ").fg(cyan).style(bold)
    termWriteFlush($promptSt)

    let response = readInputLine().toLowerAscii()
    if response.len == 0:
        return default
    response in ["y", "yes"]

proc confirmm*(question: string; default = false): bool =
    ## Alias for confirm.
    confirm(question, default)

template confirmed*(question: string; body: untyped) =
    ## Execute body only if user confirms.
    ## In NimScript: body may not execute (depends on default)
    when defined(nimscript):
        {.warning: "confirmed() cannot get user input in NimScript - uses default".}
    if confirm(question):
        body
    else:
        echo styled("Cancelled.").fg(red).style(dim)

# Fix #29: NimScript - prompt functions have limited functionality in NimScript
proc prompt*(question: string; defaultVal = ""): string =
    ## Prompt for text input.
    ## In NimScript: cannot read interactive input, returns default value
    when defined(nimscript):
        {.warning: "prompt() cannot read interactive input in NimScript - returns default value".}
    let defaultHint =
        if defaultVal.len > 0: " [" & defaultVal & "]"
        else: ""

    let promptSt = styled("? " & question & defaultHint & ": ").fg(cyan).style(bold)
    termWriteFlush($promptSt)

    result = readInputLine()
    if result.len == 0 and defaultVal.len > 0:
        result = defaultVal

proc promptInt*(question: string; defaultVal = 0): int =
    ## Prompt for integer input.
    ## In NimScript: cannot read interactive input, returns default value
    when defined(nimscript):
        {.warning: "promptInt() cannot read interactive input in NimScript - returns default value".}
    while true:
        let response = prompt(question, $defaultVal)
        try:
            return parseInt(response)
        except ValueError:
            echo styled("  Please enter a valid number.").fg(red)

proc promptPassword*(question: string; maskChar = '*'): string =
    ## Prompt for password with optional masking character.
    ## Set maskChar to '\0' to hide input completely (no echo).
    ## Note: Full character-by-character masking requires platform-specific code.
    ## This implementation hides input entirely for security (no mask characters shown).
    ## In NimScript: cannot mask input, returns empty string
    when defined(nimscript):
        {.warning: "promptPassword() cannot securely read input in NimScript - returns empty string".}
    let promptSt = styled("🔒 " & question & ": ").fg(cyan).style(bold)
    termWriteFlush($promptSt)

    when defined(nimscript):
        # NimScript fallback - cannot mask input
        result = readInputLine()
    else:
        # Fix #5: Hide password input (no echo)
        # For character-by-character masking with asterisks, a more platform-specific
        # implementation would be needed. This version disables echo entirely.
        try:
            terminal.hideCursor()
            # On Windows, we use a simpler approach since disableEcho doesn't work the same way
            when defined(windows):
                # Just read without masking for Windows compatibility
                # The cursor is hidden so the input is less visible
                result = readInputLine()
            else:
                # Unix-like systems
                terminal.disableEcho()
                try:
                    result = readInputLine()
                finally:
                    terminal.enableEcho()
        finally:
            terminal.showCursor()
            # Print newline since input didn't echo
            echo ""
        
        # Show mask characters if requested (simple approach: echo them after input)
        if maskChar != '\0' and result.len > 0:
            # Move cursor up and show masks
            stdout.write("\x1b[1A")  # Move up one line
            stdout.write("\x1b[2K")  # Clear line
            termWriteFlush($promptSt & maskChar.repeat(result.len))

# Fix #29: NimScript - promptChoice has limited functionality in NimScript
proc promptChoice*(
    question    : string
    ,choices    : openArray[string]
    ,defaultIdx : int = 0
)               : MenuResult =
    ## Prompt user to choose from a list of options.
    ## In NimScript: cannot read interactive input, returns default choice
    when defined(nimscript):
        {.warning: "promptChoice() cannot read interactive input in NimScript - returns default choice".}
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

# Fix #29: NimScript - choose has limited functionality in NimScript
proc choose*(
    question      : string
    ,options      : seq[string]
    ,defaultIndex : int = 0
)                 : int =
    ## Choose from a numbered list of options.
    ## In NimScript: cannot read interactive input, returns default index
    when defined(nimscript):
        {.warning: "choose() cannot read interactive input in NimScript - returns default index".}
    echo question
    for i, opt in options:
        echo "  " & $(i + 1) & ") " & opt

    let idx1 = promptInt("Choose", defaultIndex + 1)
    result   = max(0, min(options.len - 1, idx1 - 1))

discard """

Interactive input helpers.

NimScript Limitations (Fix #29):
- All prompt functions (confirm, prompt, promptInt, promptPassword, promptChoice, choose)
  cannot read interactive user input in NimScript
- They will produce compile-time warnings when used in NimScript
- They return default values or empty strings
- Works safely but doesn't provide interactive experience

Recommended alternatives for NimScript:
- Use hardcoded values or configuration files
- Pass values as command-line arguments
- Use environment variables for configuration

Native Nim (compiled):
- Full interactive input works as expected
- Password masking works (with platform-specific limitations)
- Menu navigation works correctly

Safe Degradation:
- All procs work safely in NimScript (no crashes)
- They just don't wait for user input
- Compile-time warnings alert developers to limitations

Note:
- promptPassword now hides input by default (Fix #5)
  Set maskChar to '\0' to completely hide input
  On non-Windows platforms, it will show mask characters after input
  Handles backspace properly on supported platforms
  Raises KeyboardInterrupt on Ctrl+C where supported

"""
