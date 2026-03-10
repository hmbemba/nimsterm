# Nimsterm Spinner Collection

A comprehensive collection of **60+ spinner styles** for terminal applications, collected from popular open-source spinner libraries across multiple programming languages.

## Source Libraries

This collection includes spinners from:

| Library | Language | Spinners |
|---------|----------|----------|
| [cli-spinners](https://github.com/sindresorhus/cli-spinners) | JavaScript | 90+ |
| [ora](https://github.com/sindresorhus/ora) | JavaScript | 10+ |
| [spinners](https://github.com/FGRibreau/spinners) | Rust | 50+ |
| [halo](https://github.com/ManrajGrover/halo) | Python | Uses cli-spinners |
| [spinner](https://github.com/briandowns/spinner) | Go | 70+ |

## Categories

### Basic Spinners
```nim
SPINNER_SIMPLE   # ["-", "\\", "|", "/"] - Classic ASCII
SPINNER_FRAMES   # ["⠋", "⠙", "⠹", ...] - Braille dots
SPINNER_DOTS     # ["⣾", "⣽", "⣻", ...] - Filled braille
SPINNER_ARROWS   # ["←", "↖", "↑", ...] - Rotating arrows
```

### Dots Variations (14 types)
```nim
SPINNER_DOTS2    # ["⠋", "⠙", "⠚", ...]
SPINNER_DOTS3    # ["⠄", "⠆", "⠇", ...]
SPINNER_DOTS4    # ["⠋", "⠙", "⠚", ...]
SPINNER_DOTS5    # ["⠁", "⠉", "⠙", ...]
SPINNER_DOTS6    # ["⠈", "⠉", "⠋", ...]
SPINNER_DOTS7    # ["⠁", "⠁", "⠉", ...]
SPINNER_DOTS8    # ["⢹", "⢺", "⢼", ...]
SPINNER_DOTS9    # ["⢄", "⢂", "⢁", ...]
SPINNER_DOTS10   # ["⠁", "⠂", "⠄", ...]
SPINNER_DOTS11   # Double-width snake pattern
SPINNER_DOTS12   # ["⣼", "⣹", "⢻", ...]
SPINNER_DOTS13   # ["⠉⠉", "⠈⠙", "⠀⠹", ...]
```

### Line-Based
```nim
SPINNER_LINE     # ["-", "\\", "|", "/"]
SPINNER_LINE2    # ["⠂", "-", "–", "—", "–", "-"]
SPINNER_PIPE     # ["┤", "┘", "┴", "└", "├", "┌", "┬", "┐"]
```

### Arrows
```nim
SPINNER_ARROW    # ["←", "↖", "↑", "↗", "→", "↘", "↓", "↙"]
SPINNER_ARROW2   # ["▹▹▹▹▹", "▸▹▹▹▹", ...] - Progress arrows
SPINNER_ARROW3   # ["↑", "↗", "→", ...] - Rotating arrows
```

### Box & Block
```nim
SPINNER_BOXBOUNCE     # ["▖", "▘", "▝", "▗"]
SPINNER_BOXBOUNCE2    # ["▌", "▀", "▐", "▄"]
SPINNER_SQUARECORNERS # ["◰", "◳", "◲", "◱"]
```

### Circles
```nim
SPINNER_CIRCLE         # ["◡", "⊙", "◠"]
SPINNER_CIRCLEHALVES   # ["◐", "◓", "◑", "◒"]
SPINNER_CIRCLEQUARTERS # ["◴", "◷", "◶", "◵"]
```

### Toggle & Switch
```nim
SPINNER_TOGGLE   # ["⊶", "⊷"]
SPINNER_TOGGLE2  # ["▫", "▪"]
SPINNER_TOGGLE3  # ["□", "■"]
SPINNER_TOGGLE4  # ["☐", "☑"]
SPINNER_TOGGLE5  # ["■", "□", "▪", "▫"]
```

### Stars
```nim
SPINNER_STAR     # ["✶", "✸", "✹", "✺", "✹", "✷"]
SPINNER_STAR2    # ["+", "x", "*"]
```

### Geometric
```nim
SPINNER_TRIANGLE # ["◢", "◣", "◤", "◥"]
SPINNER_SQUISH   # ["╫", "╪"]
SPINNER_FLIP     # ["_", "_", "_", "-", "`", "`", ...]
SPINNER_LAYER    # ["-", "=", "≡"]
SPINNER_NOISE    # ["▓", "▒", "░"]
```

### Fun & Themed
```nim
SPINNER_HAMBURGER  # ["☱", "☲", "☴"]
SPINNER_DQPB       # ["d", "q", "p", "b"] - Rotating letters
SPINNER_BALLOON    # [" ", ".", "o", "O", "@", "*", " "]
SPINNER_BALLOON2   # [".", "o", "O", "°", "O", "o", "."]
```

### Progress Indicators
```nim
SPINNER_POINT          # ["∙∙∙", "●∙∙", "∙●∙", "∙∙●", "∙∙∙"]
SPINNER_AESTHETIC      # Block progression pattern
SPINNER_GROWHORIZONTAL # ["▏", "▎", "▍", ...]
SPINNER_GROWVERTICAL   # ["▁", "▃", "▄", ...]
```

### Games & Animation
```nim
SPINNER_PONG          # Classic Pong animation
SPINNER_SHARK         # Swimming shark
SPINNER_RUNNER        # ["🚶 ", "🏃 "] - Running person
SPINNER_BOUNCINGBALL  # Bouncing ball in brackets
```

### Simple Dots
```nim
SPINNER_SIMPLEDOTS          # [".  ", ".. ", "...", "   "]
SPINNER_SIMPLEDOTSSCROLLING # Scrolling dots pattern
```

### Special Patterns
```nim
SPINNER_BINARY  # Binary numbers animation
SPINNER_PULSE   # ["◐", "◓", "◑", "◒", ...]
SPINNER_CARDS   # ["♠", "♣", "♥", "♦"]
```

### Emoji Spinners
```nim
SPINNER_CLOCK   # 🕛 🕐 🕑 🕒 ... (Clock faces)
SPINNER_MOON    # 🌑 🌒 🌓 🌔 ... (Moon phases)
SPINNER_EARTH   # 🌍 🌎 🌏 (Rotating Earth)
```

## Usage

### Basic Usage
```nim
import nimsterm
import std/os

var sp = initSpinner(@SPINNER_FRAMES)

for i in 0..<100:
    sp.tick()
    sleep(80)

finishLine("Done!")
```

### With Custom Message
```nim
var sp = initSpinner(@SPINNER_DOTS)

for i in 0..<100:
    sp.tick("Loading... ")
    sleep(80)
```

### Single Frame
```nim
# Get a specific frame without state
let frame = spinnerFrame(5, SPINNER_ARROWS)
echo frame
```

### Custom Spinner
```nim
const MY_SPINNER = ["🌱", "🌿", "🌳", "🌲"]
var sp = initSpinner(@MY_SPINNER)
```

### Using withLoader Template
```nim
withLoader("Processing..."):
    # Your long-running code here
    sleep(2000)
```

## Running the Demo

```bash
# Run the comprehensive spinner demo
nim c -r examples/spinner_demo.nim
```

## Creating Your Own

Creating a custom spinner is easy:

```nim
const MY_SPINNER = [
    "Frame 1",
    "Frame 2", 
    "Frame 3",
    "Frame 4"
]

var sp = initSpinner(@MY_SPINNER)
```

Tips:
- Use Unicode characters for visual appeal
- Keep frames roughly the same width
- 4-12 frames is a good range
- Consider frame rate (80ms is typical)

## Browser Compatibility

All spinners work in:
- ✅ Modern terminals with Unicode support
- ✅ Windows Terminal
- ✅ macOS Terminal
- ✅ Linux terminals
- ⚠️ Some spinners may not render correctly in older terminals

For maximum compatibility, use ASCII-only spinners:
- `SPINNER_SIMPLE`
- `SPINNER_LINE`
- `SPINNER_DQPB`
