import
    std/os
    ,../src/nimsterm

discard """

nim r examples/demo.nim

"""


when isMainModule:
    clearScreen()

    header("NIMSTERM DEMO", ch = "═", width = 50)
    echo ""

    info("Styled Text Examples:")
    echo styled("  Success!").fg(green).bg(black).style(bold, underline)
    echo styled("  Warning!").fg(yellow).style(blink)
    echo styled("  Error").fg(red).style(bold, strikethrough)
    echo styled("  Italic text").fg(magenta).style(italic)
    echo ""

    info("Semantic Output:")
    success("Operation completed successfully")
    warning("This might take a while")
    error("Something went wrong")
    debug("Variable x = 42")
    echo ""

    info("Box Styles:")
    echo styled("Single").fg(cyan).boxed("single")
    echo styled("Double").fg(yellow).boxed("double")
    echo styled("Rounded").fg(green).boxed("rounded")
    echo styled("Heavy").fg(red).boxed("heavy")
    echo ""

    info("Multiline Box:")
    echo styled("Line 1\nLine 2\nLine 3").fg(magenta).boxed("rounded", padding = 2)
    echo ""

    info("Table Demo:")
    let tableOut = table(
        ["Name", "Status", "Score"]
        ,@[
            @["Alice", "Active", "95"]
            ,@["Bob", "Pending", "87"]
            ,@["Charlie", "Complete", "92"]
        ]
        ,borderStyle = "rounded"
    )
    echo tableOut
    echo ""

    info("Simple Table:")
    echo simpleTable(
        ["Command", "Description"]
        ,@[
            @["help", "Show help message"]
            ,@["version", "Display version"]
            ,@["run", "Execute the program"]
        ]
    )
    echo ""

    info("Progress Bar:")
    for i in 0..10:
        showProgress("Loading", i * 10, 100, width = 20)
        sleep(500)
    echo ""
    echo ""

    info("RGB Gradient:")
    echo gradient("Rainbow gradient text!", 255, 0, 0, 0, 0, 255)
    echo ""

    info("Bullet List:")
    bullet("First item")
    bullet("Second item", indent = 2)
    bullet("Third item", indent = 4, marker = "→")
    echo ""

    info("Numbered List:")
    numbered(["Install dependencies", "Configure settings", "Run the app"])
    echo ""

    divider("─", 50)
    echo ""
    success("Demo complete!")

discard """

nim r examples/demo.nim

"""
