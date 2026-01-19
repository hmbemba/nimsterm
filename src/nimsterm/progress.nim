import
    std/strutils
    ,./termio
    ,./control
    ,./util

proc statusLine*(msg: string; clearRest = true) =
    termWrite("\r" & msg)
    if clearRest:
        clearToEndOfLine()
    termFlush()

proc hr*(ch = "─"; width = -1): string =
    let w = if width <= 0: termWidth() else: width
    ch.repeat(max(0, w))

proc progressBar*(
    current : int
    ,total  : int
    ,width  : int = 30
    ,fill   : string = "█"
    ,empty  : string = "░"
)           : string =
    if total <= 0:
        return "[" & empty.repeat(width) & "]"

    let clamped = max(0, min(current, total))
    let filled  = (clamped * width) div total
    "[" & fill.repeat(filled) & empty.repeat(width - filled) & "]"

proc showProgress*(
    label   : string
    ,current: int
    ,total  : int
    ,width  : int = 30
) =
    let pct =
        if total <= 0: 0
        else: (max(0, min(current, total)) * 100) div total

    let bar = progressBar(current, total, width = width)
    statusLine(label & " " & bar & " " & $pct & "%")

type
    Spinner* = object
        frames* : seq[string]
        idx*    : int

const
    SPINNER_FRAMES*  = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    SPINNER_DOTS*    = ["⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"]
    SPINNER_ARROWS*  = ["←", "↖", "↑", "↗", "→", "↘", "↓", "↙"]
    SPINNER_SIMPLE*  = ["-", "\\", "|", "/"]

proc spinnerFrame*(frameIdx: int; frames: openArray[string] = SPINNER_FRAMES): string =
    if frames.len == 0:
        return ""
    frames[frameIdx mod frames.len]

proc initSpinner*(frames: seq[string] = @["|", "/", "-", "\\"]): Spinner =
    Spinner(frames: frames, idx: 0)

proc tick*(sp: var Spinner; prefix = "") =
    if sp.frames.len == 0:
        return
    statusLine(prefix & sp.frames[sp.idx mod sp.frames.len] & " ")
    inc sp.idx

proc finishLine*(msg: string) =
    clearLine()
    echo msg

template withLoader*(message: string; body: untyped): untyped =
    echo message
    body
    echo "Done"

discard """

Progress bars and spinners.

statusLine tries to update in-place using carriage return.
In NimScript, output will be best-effort (echo adds newline).

"""
