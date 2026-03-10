## Nimsterm Spinner Demo
## Comprehensive demonstration of all available spinner styles
## Based on research from:
## - sindresorhus/cli-spinners (90+ spinners)
## - sindresorhus/ora
## - FGRibreau/spinners (Rust)
## - ManrajGrover/halo (Python)
## - briandowns/spinner (Go)

import
    std/os
    ,../src/nimsterm
    ,std/strutils

proc sleep(ms: int) =
    ## Cross-platform sleep in milliseconds
    os.sleep(ms)

template withHiddenCursor(body: untyped): untyped =
    ## Executes body with cursor hidden, ensuring cursor is restored even on exception
    hideCursor()
    try:
        body
    finally:
        showCursor()

proc demoSpinner(name: string; frames: openArray[string]; durationMs = 3000; intervalMs = 80) =
    ## Demonstrate a single spinner style with clean cursor handling
    stdout.write(name & ": ")
    stdout.flushFile()
    
    var sp = initSpinner(@frames)
    let iterations = durationMs div intervalMs
    
    withHiddenCursor:
        for i in 0..<iterations:
            sp.tick()
            sleep(intervalMs)
    
    clearLine()
    stdout.write(name)
    echo ": ", styled("✓ ").fg(green).render(), styled("Done").fg(brightGreen).render()

proc demoCategory(name: string) =
    ## Print category header
    echo ""
    echo styled(name).fg(cyan).style(bold).render()
    echo styled("─".repeat(50)).fg(brightBlack).render()

# =============================================================================
# MAIN DEMO
# =============================================================================

clearScreen()
echo styled("╔══════════════════════════════════════════════════════════════╗").fg(blue).style(bold).render()
echo styled("║         Nimsterm Spinner Collection Demo                     ║").fg(blue).style(bold).render()
echo styled("║         60+ Spinner Styles from Popular Libraries            ║").fg(blue).style(bold).render()
echo styled("╚══════════════════════════════════════════════════════════════╝").fg(blue).style(bold).render()
echo ""
echo "This demo showcases spinner styles collected from:"
echo "  • cli-spinners (sindresorhus) - 90+ spinners"
echo "  • ora (sindresorhus) - Elegant terminal spinners"
echo "  • spinners (FGRibreau) - Rust spinner library"
echo "  • halo (ManrajGrover) - Python spinner library"
echo "  • spinner (briandowns) - Go spinner library"
echo ""
echo "Starting demo in 2 seconds..."
sleep(2000)

# =============================================================================
# BASIC SPINNERS
# =============================================================================
demoCategory("Basic Spinners")
demoSpinner("SPINNER_SIMPLE", SPINNER_SIMPLE, durationMs = 1500)
demoSpinner("SPINNER_FRAMES", SPINNER_FRAMES)
demoSpinner("SPINNER_DOTS", SPINNER_DOTS)
demoSpinner("SPINNER_ARROWS", SPINNER_ARROWS)

# =============================================================================
# DOTS VARIATIONS
# =============================================================================
demoCategory("Dots Variations (14 types)")
demoSpinner("SPINNER_DOTS2", SPINNER_DOTS2)
demoSpinner("SPINNER_DOTS3", SPINNER_DOTS3)
demoSpinner("SPINNER_DOTS4", SPINNER_DOTS4)
demoSpinner("SPINNER_DOTS5", SPINNER_DOTS5)
demoSpinner("SPINNER_DOTS6", SPINNER_DOTS6)
demoSpinner("SPINNER_DOTS7", SPINNER_DOTS7)
demoSpinner("SPINNER_DOTS8", SPINNER_DOTS8)
demoSpinner("SPINNER_DOTS9", SPINNER_DOTS9)
demoSpinner("SPINNER_DOTS10", SPINNER_DOTS10)
demoSpinner("SPINNER_DOTS11", SPINNER_DOTS11, durationMs = 4000)
demoSpinner("SPINNER_DOTS12", SPINNER_DOTS12)
demoSpinner("SPINNER_DOTS13", SPINNER_DOTS13)

# =============================================================================
# LINE-BASED SPINNERS
# =============================================================================
demoCategory("Line-Based Spinners")
demoSpinner("SPINNER_LINE", SPINNER_LINE, durationMs = 1500)
demoSpinner("SPINNER_LINE2", SPINNER_LINE2)
demoSpinner("SPINNER_PIPE", SPINNER_PIPE)

# =============================================================================
# ARROW SPINNERS
# =============================================================================
demoCategory("Arrow Spinners")
demoSpinner("SPINNER_ARROW", SPINNER_ARROW)
demoSpinner("SPINNER_ARROW2", SPINNER_ARROW2)
demoSpinner("SPINNER_ARROW3", SPINNER_ARROW3)

# =============================================================================
# BOX & BLOCK SPINNERS
# =============================================================================
demoCategory("Box & Block Spinners")
demoSpinner("SPINNER_BOXBOUNCE", SPINNER_BOXBOUNCE)
demoSpinner("SPINNER_BOXBOUNCE2", SPINNER_BOXBOUNCE2)
demoSpinner("SPINNER_SQUARECORNERS", SPINNER_SQUARECORNERS)

# =============================================================================
# CIRCLE SPINNERS
# =============================================================================
demoCategory("Circle Spinners")
demoSpinner("SPINNER_CIRCLE", SPINNER_CIRCLE, durationMs = 2000)
demoSpinner("SPINNER_CIRCLEHALVES", SPINNER_CIRCLEHALVES)
demoSpinner("SPINNER_CIRCLEQUARTERS", SPINNER_CIRCLEQUARTERS)

# =============================================================================
# TOGGLE & SWITCH SPINNERS
# =============================================================================
demoCategory("Toggle & Switch Spinners")
demoSpinner("SPINNER_TOGGLE", SPINNER_TOGGLE, intervalMs = 400)
demoSpinner("SPINNER_TOGGLE2", SPINNER_TOGGLE2, intervalMs = 400)
demoSpinner("SPINNER_TOGGLE3", SPINNER_TOGGLE3, intervalMs = 400)
demoSpinner("SPINNER_TOGGLE4", SPINNER_TOGGLE4, intervalMs = 400)
demoSpinner("SPINNER_TOGGLE5", SPINNER_TOGGLE5, intervalMs = 300)

# =============================================================================
# STAR SPINNERS
# =============================================================================
demoCategory("Star Spinners")
demoSpinner("SPINNER_STAR", SPINNER_STAR)
demoSpinner("SPINNER_STAR2", SPINNER_STAR2, durationMs = 2000)

# =============================================================================
# GEOMETRIC SPINNERS
# =============================================================================
demoCategory("Geometric Spinners")
demoSpinner("SPINNER_TRIANGLE", SPINNER_TRIANGLE)
demoSpinner("SPINNER_SQUISH", SPINNER_SQUISH, intervalMs = 200)
demoSpinner("SPINNER_FLIP", SPINNER_FLIP)
demoSpinner("SPINNER_LAYER", SPINNER_LAYER)
demoSpinner("SPINNER_NOISE", SPINNER_NOISE)

# =============================================================================
# FUN & THEMED SPINNERS
# =============================================================================
demoCategory("Fun & Themed Spinners")
demoSpinner("SPINNER_HAMBURGER", SPINNER_HAMBURGER, durationMs = 2000)
demoSpinner("SPINNER_DQPB", SPINNER_DQPB)
demoSpinner("SPINNER_BALLOON", SPINNER_BALLOON)
demoSpinner("SPINNER_BALLOON2", SPINNER_BALLOON2)

# =============================================================================
# PROGRESS INDICATORS
# =============================================================================
demoCategory("Progress Indicators")
demoSpinner("SPINNER_POINT", SPINNER_POINT, durationMs = 2000)
demoSpinner("SPINNER_AESTHETIC", SPINNER_AESTHETIC, durationMs = 4000)
demoSpinner("SPINNER_GROWHORIZONTAL", SPINNER_GROWHORIZONTAL, durationMs = 4000)
demoSpinner("SPINNER_GROWVERTICAL", SPINNER_GROWVERTICAL)

# =============================================================================
# GAME & ANIMATION SPINNERS
# =============================================================================
demoCategory("Game & Animation Spinners")
demoSpinner("SPINNER_PONG", SPINNER_PONG, durationMs = 5000, intervalMs = 120)
demoSpinner("SPINNER_SHARK", SPINNER_SHARK, durationMs = 5000, intervalMs = 120)
demoSpinner("SPINNER_RUNNER", SPINNER_RUNNER, intervalMs = 300)
demoSpinner("SPINNER_BOUNCINGBALL", SPINNER_BOUNCINGBALL)

# =============================================================================
# SIMPLE DOTS
# =============================================================================
demoCategory("Simple Dots")
demoSpinner("SPINNER_SIMPLEDOTS", SPINNER_SIMPLEDOTS, intervalMs = 400)
demoSpinner("SPINNER_SIMPLEDOTSSCROLLING", SPINNER_SIMPLEDOTSSCROLLING, intervalMs = 300)

# =============================================================================
# SPECIAL PATTERNS
# =============================================================================
demoCategory("Special Patterns")
demoSpinner("SPINNER_BINARY", SPINNER_BINARY, durationMs = 4000)
demoSpinner("SPINNER_PULSE", SPINNER_PULSE)
demoSpinner("SPINNER_CARDS", SPINNER_CARDS)

# =============================================================================
# EMOJI SPINNERS
# =============================================================================
demoCategory("Emoji Spinners")
demoSpinner("SPINNER_CLOCK", SPINNER_CLOCK, durationMs = 5000, intervalMs = 200)
demoSpinner("SPINNER_MOON", SPINNER_MOON, durationMs = 4000, intervalMs = 200)
demoSpinner("SPINNER_EARTH", SPINNER_EARTH, intervalMs = 400)

# =============================================================================
# CUSTOM SPINNER EXAMPLE
# =============================================================================
demoCategory("Custom Spinner Example")

# Create a custom spinner
const MY_CUSTOM_SPINNER = ["🌱", "🌿", "🌳", "🌲", "🎄"]
demoSpinner("CUSTOM (Trees)", MY_CUSTOM_SPINNER, intervalMs = 400)

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo styled("═".repeat(64)).fg(green).style(bold).render()
echo styled("  DEMO COMPLETE!").fg(green).style(bold).render()
echo styled("═".repeat(64)).fg(green).style(bold).render()
echo ""
echo "All spinner styles have been demonstrated."
echo ""
echo "Usage in your code:"
echo "  import nimsterm"
echo "  var sp = initSpinner(@SPINNER_PONG)"
echo "  sp.tick()  # Call repeatedly"
echo ""
echo "Or use spinnerFrame for single frames:"
echo "  echo spinnerFrame(0, SPINNER_STARS)"
echo ""
