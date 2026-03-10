import
    std/strutils
    ,./termio
    ,./control
    ,./util

# Fix #29: NimScript - statusLine uses cursor control which doesn't work in NimScript
proc statusLine*(msg: string; clearRest = true) =
    ## Update status line in-place using carriage return.
    ## In NimScript: echoes message (no in-place update possible)
    when defined(nimscript):
        {.warning: "statusLine() cannot update in-place in NimScript - each call produces new output".}
    termWrite("\r" & msg)
    if clearRest:
        clearToEndOfLine()
    termFlush()

proc hr*(ch = "─"; width = -1): string =
    ## Generate a horizontal rule.
    ## If width is -1 (default), uses terminal width.
    let w = if width <= 0: termWidth() else: width
    ch.repeat(max(0, w))

proc progressBar*(
    current : int
    ,total  : int
    ,width  : int = 30
    ,fill   : string = "█"
    ,empty  : string = "░"
)           : string =
    ## Generate a progress bar string (works in both Nim and NimScript).
    if total <= 0:
        return "[" & empty.repeat(width) & "]"

    let clamped = max(0, min(current, total))
    let filled  = (clamped * width) div total
    "[" & fill.repeat(filled) & empty.repeat(width - filled) & "]"

# Fix #29: NimScript - showProgress uses statusLine which doesn't work well in NimScript
proc showProgress*(
    label   : string
    ,current: int
    ,total  : int
    ,width  : int = 30
) =
    ## Show a progress bar with percentage.
    ## In NimScript: cannot update in-place, each call produces new output
    when defined(nimscript):
        {.warning: "showProgress() cannot update in-place in NimScript - consider using progressBar() to generate string instead".}
    let pct =
        if total <= 0: 0
        else: (max(0, min(current, total)) * 100) div total

    let bar = progressBar(current, total, width = width)
    statusLine(label & " " & bar & " " & $pct & "%")

type
    Spinner* = object
        frames* : seq[string]
        idx*    : int

# =============================================================================
# SPINNER CONSTANTS
# =============================================================================
# Based on research from:
# - sindresorhus/cli-spinners (90+ spinners)
# - sindresorhus/ora
# - FGRibreau/spinners (Rust)
# - ManrajGrover/halo (Python)
# - briandowns/spinner (Go)
# =============================================================================

const
    # Basic spinners
    SPINNER_FRAMES*  = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    SPINNER_DOTS*    = ["⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"]
    SPINNER_ARROWS*  = ["←", "↖", "↑", "↗", "→", "↘", "↓", "↙"]
    SPINNER_SIMPLE*  = ["-", "\\", "|", "/"]

    # More dots variations (from cli-spinners)
    SPINNER_DOTS2*   = ["⠋", "⠙", "⠚", "⠞", "⠖", "⠦", "⠴", "⠲", "⠳", "⠓"]
    SPINNER_DOTS3*   = ["⠄", "⠆", "⠇", "⠋", "⠙", "⠸", "⠰", "⠠", "⠰", "⠸", "⠙", "⠋", "⠇", "⠆"]
    SPINNER_DOTS4*   = ["⠋", "⠙", "⠚", "⠒", "⠂", "⠂", "⠒", "⠲", "⠴", "⠦", "⠖", "⠒", "⠐", "⠐", "⠒", "⠓", "⠋"]
    SPINNER_DOTS5*   = ["⠁", "⠉", "⠙", "⠚", "⠒", "⠂", "⠂", "⠒", "⠲", "⠴", "⠤", "⠄", "⠄", "⠤", "⠴", "⠲", "⠒", "⠂", "⠂", "⠒", "⠚", "⠙", "⠉", "⠁"]
    SPINNER_DOTS6*   = ["⠈", "⠉", "⠋", "⠓", "⠒", "⠐", "⠐", "⠒", "⠖", "⠦", "⠤", "⠠", "⠠", "⠤", "⠦", "⠖", "⠒", "⠐", "⠐", "⠒", "⠓", "⠋", "⠉", "⠈"]
    SPINNER_DOTS7*   = ["⠁", "⠁", "⠉", "⠙", "⠚", "⠒", "⠂", "⠂", "⠒", "⠲", "⠴", "⠤", "⠄", "⠄", "⠤", "⠠", "⠠", "⠤", "⠦", "⠖", "⠒", "⠐", "⠐", "⠒", "⠓", "⠋", "⠉", "⠈", "⠈"]
    SPINNER_DOTS8*   = ["⢹", "⢺", "⢼", "⣸", "⣇", "⡧", "⡗", "⡏"]
    SPINNER_DOTS9*   = ["⢄", "⢂", "⢁", "⡁", "⡈", "⡐", "⡠"]
    SPINNER_DOTS10*  = ["⠁", "⠂", "⠄", "⡀", "⢀", "⠠", "⠐", "⠈"]
    SPINNER_DOTS11*  = ["⢀⠀", "⡀⠀", "⠄⠀", "⢂⠀", "⡂⠀", "⠅⠀", "⢃⠀", "⡃⠀", "⠍⠀", "⢋⠀", "⡋⠀", "⠍⠁", "⢋⠁", "⡋⠁", "⠍⠉", "⠋⠉", "⠉⠙", "⠉⠩", "⠈⢙", "⠈⡙", "⢈⠩", "⡀⢙", "⠄⡙", "⢂⠩", "⡂⢘", "⠅⡘", "⢃⠨", "⡃⢐", "⠍⡐", "⢋⠠", "⡋⢀", "⠍⡁", "⢋⠁", "⡋⠁", "⠍⠉", "⠋⠉", "⠉⠙", "⠉⠩", "⠈⢙", "⠈⡙", "⠈⠩", "⠀⢙", "⠀⡙", "⠀⠩", "⠀⢘", "⠀⡘", "⠀⠨", "⠀⢐", "⠀⡐", "⠀⠠", "⠀⢀", "⠀⡀"]
    SPINNER_DOTS12*  = ["⣼", "⣹", "⢻", "⠿", "⡟", "⣏", "⣧", "⣶"]
    SPINNER_DOTS13*  = ["⠉⠉", "⠈⠙", "⠀⠹", "⠀⢸", "⠀⣰", "⢀⣠", "⣀⣀", "⣄⡀", "⣆⠀", "⡇⠀", "⠏⠀", "⠋⠁"]

    # Line-based spinners
    SPINNER_LINE*    = ["-", "\\", "|", "/"]
    SPINNER_LINE2*   = ["⠂", "-", "–", "—", "–", "-"]
    SPINNER_PIPE*    = ["┤", "┘", "┴", "└", "├", "┌", "┬", "┐"]

    # Arrow variations
    SPINNER_ARROW*   = ["←", "↖", "↑", "↗", "→", "↘", "↓", "↙"]
    SPINNER_ARROW2*  = ["▹▹▹▹▹", "▸▹▹▹▹", "▹▸▹▹▹", "▹▹▸▹▹", "▹▹▹▸▹", "▹▹▹▹▸"]
    SPINNER_ARROW3*  = ["↑", "↗", "→", "↘", "↓", "↙", "←", "↖"]

    # Box and block spinners
    SPINNER_BOXBOUNCE*   = ["▖", "▘", "▝", "▗"]
    SPINNER_BOXBOUNCE2*  = ["▌", "▀", "▐", "▄"]
    SPINNER_SQUARECORNERS* = ["◰", "◳", "◲", "◱"]

    # Circle spinners
    SPINNER_CIRCLE*        = ["◡", "⊙", "◠"]
    SPINNER_CIRCLEHALVES*  = ["◐", "◓", "◑", "◒"]
    SPINNER_CIRCLEQUARTERS* = ["◴", "◷", "◶", "◵"]

    # Toggle/switch spinners
    SPINNER_TOGGLE*    = ["⊶", "⊷"]
    SPINNER_TOGGLE2*   = ["▫", "▪"]
    SPINNER_TOGGLE3*   = ["□", "■"]
    SPINNER_TOGGLE4*   = ["☐", "☑"]
    SPINNER_TOGGLE5*   = ["■", "□", "▪", "▫"]

    # Star spinners
    SPINNER_STAR*      = ["✶", "✸", "✹", "✺", "✹", "✷"]
    SPINNER_STAR2*     = ["+", "x", "*"]

    # Geometric shapes
    SPINNER_TRIANGLE*  = ["◢", "◣", "◤", "◥"]
    SPINNER_SQUISH*    = ["╫", "╪"]
    SPINNER_FLIP*      = ["_", "_", "_", "-", "`", "`", "'", "´", "-", "_", "_", "_"]
    SPINNER_LAYER*     = ["-", "=", "≡"]
    SPINNER_NOISE*     = ["▓", "▒", "░"]

    # Fun and themed spinners
    SPINNER_HAMBURGER*  = ["☱", "☲", "☴"]
    SPINNER_DQPB*       = ["d", "q", "p", "b"]
    SPINNER_BALLOON*    = [" ", ".", "o", "O", "@", "*", " "]
    SPINNER_BALLOON2*   = [".", "o", "O", "°", "O", "o", "."]

    # Progress indicators
    SPINNER_POINT*      = ["∙∙∙", "●∙∙", "∙●∙", "∙∙●", "∙∙∙"]
    SPINNER_AESTHETIC*  = ["▰▱▱▱▱▱▱", "▰▰▱▱▱▱▱", "▰▰▰▱▱▱▱", "▰▰▰▰▱▱▱", "▰▰▰▰▰▱▱", "▰▰▰▰▰▰▱", "▰▰▰▰▰▰▰", "▰▱▱▱▱▱▱"]
    SPINNER_GROWHORIZONTAL* = ["▏", "▎", "▍", "▌", "▋", "▊", "▉", "▊", "▋", "▌", "▍", "▎"]
    SPINNER_GROWVERTICAL*   = ["▁", "▃", "▄", "▅", "▆", "▇", "▆", "▅", "▄", "▃"]

    # Game/animation spinners
    SPINNER_PONG* = [
        "▐⠂       ▌", "▐⠈       ▌", "▐ ⠂      ▌", "▐ ⠠      ▌", "▐  ⡀     ▌", "▐  ⠠     ▌", "▐   ⠂    ▌",
        "▐   ⠈    ▌", "▐    ⠂   ▌", "▐    ⠠   ▌", "▐     ⡀  ▌", "▐     ⠠  ▌", "▐      ⠂ ▌", "▐      ⠈ ▌",
        "▐       ⠂▌", "▐       ⠠▌", "▐       ⡀▌", "▐      ⠠ ▌", "▐      ⠂ ▌", "▐     ⠈  ▌", "▐     ⠂  ▌",
        "▐    ⠠   ▌", "▐    ⡀   ▌", "▐   ⠠    ▌", "▐   ⠂    ▌", "▐  ⠈     ▌", "▐  ⠂     ▌", "▐ ⠠      ▌",
        "▐ ⡀      ▌", "▐⠠       ▌"
    ]
    SPINNER_SHARK* = [
        "▐|\\____________▌", "▐_|\\___________▌", "▐__|\\__________▌", "▐___|\\_________▌",
        "▐____|\\________▌", "▐_____|\\_______▌", "▐______|\\______▌", "▐_______|\\_____▌",
        "▐________|\\____▌", "▐_________|\\___▌", "▐__________|\\__▌", "▐___________|\\_▌",
        "▐____________|\\▌", "▐____________/|▌", "▐___________/|_▌", "▐__________/|__▌",
        "▐_________/|___▌", "▐________/|____▌", "▐_______/|_____▌", "▐______/|______▌",
        "▐_____/|_______▌", "▐____/|________▌", "▐___/|_________▌", "▐__/|__________▌",
        "▐_/|___________▌", "▐/|____________▌"
    ]
    SPINNER_RUNNER*     = ["🚶 ", "🏃 "]
    SPINNER_BOUNCINGBALL* = ["( ●    )", "(  ●   )", "(   ●  )", "(    ● )", "(     ●)", "(    ● )", "(   ●  )", "(  ●   )", "( ●    )", "(●     )"]

    # Simple scrolling dots
    SPINNER_SIMPLEDOTS*        = [".  ", ".. ", "...", "   "]
    SPINNER_SIMPLEDOTSSCROLLING* = [".  ", ".. ", "...", " ..", "  .", "   "]

    # Special patterns
    SPINNER_BINARY*    = ["010010", "001100", "100101", "111010", "111101", "010111", "101011", "111000", "110011", "110101"]
    SPINNER_PULSE*     = ["◐", "◓", "◑", "◒", "◐", "◓", "◑", "◒"]

    # Card suits
    SPINNER_CARDS*     = ["♠", "♣", "♥", "♦"]

    # Weather (using safe Unicode)
    SPINNER_MOON*      = ["🌑 ", "🌒 ", "🌓 ", "🌔 ", "🌕 ", "🌖 ", "🌗 ", "🌘 "]
    SPINNER_EARTH*     = ["🌍 ", "🌎 ", "🌏 "]

    # Clock faces
    SPINNER_CLOCK*     = ["🕛 ", "🕐 ", "🕑 ", "🕒 ", "🕓 ", "🕔 ", "🕕 ", "🕖 ", "🕗 ", "🕘 ", "🕙 ", "🕚 "]

proc spinnerFrame*(frameIdx: int; frames: openArray[string] = SPINNER_FRAMES): string =
    ## Get a single spinner frame (works in both Nim and NimScript).
    if frames.len == 0:
        return ""
    frames[frameIdx mod frames.len]

proc initSpinner*(frames: seq[string] = @["|", "/", "-", "\\"]): Spinner =
    ## Initialize a spinner with custom frames.
    Spinner(frames: frames, idx: 0)

# Fix #29: NimScript - tick uses statusLine which doesn't work well in NimScript
proc tick*(sp: var Spinner; prefix = "") =
    ## Advance spinner to next frame.
    ## In NimScript: cannot update in-place, each call produces new output
    when defined(nimscript):
        {.warning: "tick() cannot update in-place in NimScript - consider using spinnerFrame() to get string instead".}
    if sp.frames.len == 0:
        return
    statusLine(prefix & sp.frames[sp.idx mod sp.frames.len] & " ")
    inc sp.idx

# Fix #29: NimScript - finishLine uses clearLine which doesn't work in NimScript
proc finishLine*(msg: string) =
    ## Clear line and print final message.
    ## In NimScript: just echoes the message
    when defined(nimscript):
        {.warning: "finishLine() cannot clear line in NimScript - just echoes message".}
    clearLine()
    echo msg

# Fix #29: NimScript - withLoader template may not work as expected in NimScript
template withLoader*(message: string; body: untyped): untyped =
    ## Execute body with a loader message.
    ## In NimScript: body executes but no visual feedback during execution
    when defined(nimscript):
        {.warning: "withLoader() has limited effect in NimScript - body executes but no visual progress".}
    echo message
    body
    echo "Done"

discard """

Progress bars and spinners.

NimScript Limitations (Fix #29):
- statusLine(), showProgress(), tick(), finishLine() cannot update in-place
- They will produce compile-time warnings when used in NimScript
- Each call produces new output (no carriage return/update possible)
- Works safely but not as pretty as in compiled Nim

Recommended alternatives for NimScript:
- Use progressBar() to generate string, then echo it
- Use spinnerFrame() to get a single frame string
- Simple print statements for progress indication

Native Nim (compiled):
- Full in-place updates work as expected
- Interactive progress bars and spinners work correctly

Safe Degradation:
- All procs work safely in NimScript (no crashes)
- They just don't provide the interactive experience
- Compile-time warnings alert developers to limitations

SPINNER COLLECTION:
==================
Basic Spinners:
  SPINNER_FRAMES, SPINNER_DOTS, SPINNER_ARROWS, SPINNER_SIMPLE

Dots Variations (14 types):
  SPINNER_DOTS2 through SPINNER_DOTS13

Line-Based:
  SPINNER_LINE, SPINNER_LINE2, SPINNER_PIPE

Arrows (3 types):
  SPINNER_ARROW, SPINNER_ARROW2, SPINNER_ARROW3

Box/Block:
  SPINNER_BOXBOUNCE, SPINNER_BOXBOUNCE2, SPINNER_SQUARECORNERS

Circles (3 types):
  SPINNER_CIRCLE, SPINNER_CIRCLEHALVES, SPINNER_CIRCLEQUARTERS

Toggle/Switch (5 types):
  SPINNER_TOGGLE through SPINNER_TOGGLE5

Stars (2 types):
  SPINNER_STAR, SPINNER_STAR2

Geometric:
  SPINNER_TRIANGLE, SPINNER_SQUISH, SPINNER_FLIP, SPINNER_LAYER, SPINNER_NOISE

Fun/Themed:
  SPINNER_HAMBURGER, SPINNER_DQPB, SPINNER_BALLOON, SPINNER_BALLOON2

Progress:
  SPINNER_POINT, SPINNER_AESTHETIC, SPINNER_GROWHORIZONTAL, SPINNER_GROWVERTICAL

Games/Animation:
  SPINNER_PONG, SPINNER_SHARK, SPINNER_RUNNER, SPINNER_BOUNCINGBALL

Simple Dots:
  SPINNER_SIMPLEDOTS, SPINNER_SIMPLEDOTSSCROLLING

Special:
  SPINNER_BINARY, SPINNER_PULSE, SPINNER_CARDS, SPINNER_MOON, SPINNER_EARTH, SPINNER_CLOCK

"""
