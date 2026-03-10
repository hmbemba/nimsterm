## Nimsterm Spinner Quick Demo
## Shows a selection of popular spinners quickly

import
    std/os
    ,../src/nimsterm

proc demo(name: string; frames: openArray[string]; ms = 2000) =
    stdout.write(name & ": ")
    stdout.flushFile()
    var sp = initSpinner(@frames)
    for i in 0..<(ms div 80):
        sp.tick()
        os.sleep(80)
    clearLine()
    stdout.write(name)
    echo ": ", styled("✓ ").fg(green).render(), styled("Done").fg(brightGreen).render()

clearScreen()
echo styled("Nimsterm Spinner Quick Demo").fg(cyan).style(bold).render()
echo ""

demo("Simple", SPINNER_SIMPLE, 1000)
demo("Dots", SPINNER_DOTS)
demo("Frames", SPINNER_FRAMES)
demo("Arrows", SPINNER_ARROWS)
demo("Stars", SPINNER_STAR)
demo("Circle", SPINNER_CIRCLE, 1500)
demo("Pong", SPINNER_PONG, 4000)
demo("Moon", SPINNER_MOON, 3000)
demo("Clock", SPINNER_CLOCK, 3000)

echo ""
echo styled("All demos complete!").fg(green).style(bold).render()
