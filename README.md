# nimsterm

A Windows-friendly terminal helper library that works in:
- regular Nim programs (`nim c`, `nim r`)
- NimScript programs (`nim e`)

It merges:
- Styled text (ANSI), boxing, wrapping, padding, truncation
- Terminal control (clear, cursor movement, hide/show cursor, scroll)
- Input helpers (prompt, confirm, choice)
- Progress bars + spinners
- Tables (bordered + simple)
- Semantic output helpers (success/warn/error/info/debug/header/divider)
- RGB / truecolor helpers (optional; modern terminals)
- Nim/NimScript-friendly IO + terminal sizing fallbacks + ANSI stripping


# Install
```bash
nimble install nimsterm
```

## Usage

Import the main module to access all features:

```nim
import nimsterm
```

## Features & Examples

### 1. Styled Text & Colors

Chainable API for ANSI styling. It automatically handles resetting styles.

```nim
# Basic styling
echo styled("Hello").fg(red).style(bold)
echo styled("Backgrounds").bg(blue).fg(white)

# Complex manipulation
echo styled("Centered Text").center(20, '-').fg(yellow)
echo styled("Wrapped text that goes on and on...").wrap(15)

# Boxing text
echo styled("Attention!").boxed(boxStyle="double", padding=2).fg(green)

```

**Available Colors:** `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white` (plus `bright*` variants).
**Available Styles:** `bold`, `dim`, `italic`, `underline`, `blink`, `reverse`, `hidden`, `strikethrough`.

### 2. Semantic Output

Pre-formatted helpers for standard CLI feedback.

```nim
header("Deployment Script")

info("Connecting to server...")
if connect():
    success("Connected successfully")
else:
    error("Connection failed")
    warning("Retrying in 5 seconds...")

debug("Payload size: 24kb")

divider(ch="-", width=40)

```

### 3. User Input

Helpers for interactive scripts.

```nim
# Simple prompt with default
let name = prompt("Project Name", defaultVal="my-app")

# Integer validation
let port = promptInt("Port", defaultVal=8080)

# Confirmation (Y/n)
if confirm("Delete database?", default=false):
    success("Deleted.")
else:
    echo "Cancelled."

# Selection Menus
let framework = choose("Pick a backend:", @["Node", "Python", "Nim"])
echo "You selected index: ", framework

```

### 4. Tables

Auto-calculating column widths and borders.

**Auto-width Table:**

```nim
echo table(
  headers = ["ID", "Name", "Role"],
  rows = [
    @["1", "Alice", "Admin"],
    @["2", "Bob", "Developer"],
    @["3", "Charlie", "Designer"]
  ],
  borderStyle = "rounded" # options: single, double, rounded, heavy
)

```

**Explicit Column Control:**

```nim
echo table(
  cols = [
    Column(header: "Item", width: 20, align: alignLeft),
    Column(header: "Price", width: 10, align: alignRight)
  ],
  rows = [
    @["Laptop", "$1200"],
    @["Mouse", "$25"]
  ]
)

```

### 5. Progress Bars & Spinners

**Progress Bar:**

```nim
for i in 1..100:
    showProgress("Downloading:", i, 100)
    sleep(50)
echo "" # Newline after done

```

**Spinner:**

```nim
var sp = initSpinner(SPINNER_DOTS)
for _ in 1..20:
    sp.tick("Processing items... ")
    sleep(100)
finishLine("Done processing!")

```

### 6. Terminal Control

Direct control over the cursor and screen buffer.

```nim
clearScreen()
moveCursorTo(5, 10)
echo "I am here"
hideCursor()
# ... do work ...
showCursor()

```

### 7. RGB / TrueColor

For modern terminals supporting 24-bit color.

```nim
echo gradient("This is a gradient text", 255, 0, 0, 0, 0, 255)
# Renders text fading from Red to Blue

```

## NimScript Support

`nimsterm` is designed to be **safe for NimScript**. You can use it in your `config.nims` or build scripts (`nim e build.nims`).

* **IO:** It automatically falls back to `echo` instead of `stdout.write` where necessary.
* **Environment:** It reads `COLUMNS` and `LINES` env vars if terminal size syscalls aren't available.

```nim
# build.nims
import nimsterm

task build, "Builds the project":
    header("Building Project")
    if execCmd("nim c src/main.nim") == 0:
        success("Build complete!")
    else:
        error("Build failed.")

```