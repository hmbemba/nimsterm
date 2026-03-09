import
    std/os
    ,../src/nimsterm
    ,strutils
    ,std/syncio

discard """
nim r examples/demo.nim
"""

when isMainModule:
    let tw = termWidth(80)

    clearScreen()

    header("NIMSTERM DEMO", ch = "═", width = tw)
    echo ""

    info("Styled Text Examples:")
    echo styled("  Success!").fg(green).bg(black).style(bold, underline)
    echo styled("  Warning!").fg(yellow).style(blink)
    echo styled("  Error").fg(red).style(bold, strikethrough)
    echo styled("  Italic text").fg(magenta).style(italic)
    echo ""

    divider("─", tw)
    echo ""

    info("Semantic Output:")
    success("Operation completed successfully")
    warning("This might take a while")
    error("Something went wrong")
    debug("Variable x = 42")
    echo ""

    divider("─", tw)
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

    divider("─", tw)
    echo ""

    info("Table Demo:")
    let tableOut = table(
        ["Name", "Status", "Score"]
        ,@[
            @["Alice",   "Active",   "95"]
            ,@["Bob",    "Pending",  "87"]
            ,@["Charlie","Complete", "92"]
        ]
        ,borderStyle = "rounded"
    )
    echo tableOut
    echo ""

    info("Simple Table:")
    echo simpleTable(
        ["Command", "Description"]
        ,@[
            @["help",    "Show help message"]
            ,@["version","Display version"]
            ,@["run",    "Execute the program"]
        ]
    )
    echo ""

    info("Rich Table:")
    let richCols = [
        richCol("Name",   align = alignLeft,  headerColor = cyan,  cellColor = green,   cellStyle = bold)
        ,richCol("Status",align = alignCenter,headerColor = cyan,  cellColor = yellow,  cellStyle = bold)
        ,richCol("Score", align = alignRight, headerColor = cyan,  cellColor = magenta, cellStyle = bold)
    ]
    let richRows = @[
        @["Alice",   "Active",   "95"]
        ,@["Bob",    "Pending",  "87"]
        ,@["Charlie","Complete", "92"]
    ]
    echo richTable(richCols, richRows, colGap = 4, dimAlternate = true)
    echo ""

    divider("─", tw)
    echo ""

    info("Progress Bar:")
    for i in 0 .. 10:
        showProgress("Loading", i * 10, 100, width = max(20, tw - 20))
        sleep(200)
    echo ""
    echo ""

    divider("─", tw)
    echo ""

    info("RGB Gradient:")
    let gradText = "Rainbow gradient text across the full terminal width!"
    echo gradient(gradText, 255, 0, 0, 0, 0, 255)
    echo ""

    info("Full-width Rainbow Bar:")
    for i in 0 ..< tw:
        let t  = i.float / max(1.0, (tw - 1).float)
        let ht = t * 6.0
        var r, g, b: int
        let sector = int(ht) mod 6
        let f      = ht - ht.int.float
        case sector
        of 0: r = 255; g = int(255.0 * f);       b = 0
        of 1: r = int(255.0 * (1.0 - f)); g = 255; b = 0
        of 2: r = 0;   g = 255; b = int(255.0 * f)
        of 3: r = 0;   g = int(255.0 * (1.0 - f)); b = 255
        of 4: r = int(255.0 * f); g = 0;          b = 255
        of 5: r = 255; g = 0;   b = int(255.0 * (1.0 - f))
        else: r = 255; g = 0;   b = 0
        stdout.write rgbBg(r, g, b) & " "
    echo "\x1b[0m"
    echo ""

    divider("─", tw)
    echo ""

    info("Text Wrapping & Justification:")
    let loremText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " &
                    "Quisque in metus sed sapien ultricies pretium a at justo. " &
                    "Maecenas luctus velit et auctor maximus."

    let wrapWidth = max(30, (tw - 4) div 2)

    echo $styled("  Left:").fg(cyan).style(bold)
    let leftWrapped = wrapAlign(loremText, wrapWidth, alignLeft)
    for line in leftWrapped.split('\n'):
        echo $styled("    " & line).fg(white)
    echo ""

    echo $styled("  Center:").fg(cyan).style(bold)
    let centerWrapped = wrapAlign(loremText, wrapWidth, alignCenter)
    for line in centerWrapped.split('\n'):
        echo $styled("    " & line).fg(yellow)
    echo ""

    echo $styled("  Right:").fg(cyan).style(bold)
    let rightWrapped = wrapAlign(loremText, wrapWidth, alignRight)
    for line in rightWrapped.split('\n'):
        echo $styled("    " & line).fg(green)
    echo ""

    echo $styled("  Full Justify:").fg(cyan).style(bold)
    let fullWrapped = wrapJustify(loremText, wrapWidth)
    for line in fullWrapped.split('\n'):
        echo $styled("    " & line).fg(blue)
    echo ""

    divider("─", tw)
    echo ""

    info("Bullet List:")
    bullet("First item")
    bullet("Second item", indent = 2)
    bullet("Third item", indent = 4, marker = "→")
    echo ""

    info("Numbered List:")
    numbered(["Install dependencies", "Configure settings", "Run the app"])
    echo ""

    divider("─", tw)
    echo ""

    info("All ANSI Styles:")
    echo "  " &
         $styled("bold").style(bold) & "  " &
         $styled("dim").style(dim) & "  " &
         $styled("italic").style(italic) & "  " &
         $styled("underline").style(underline) & "  " &
         $styled("strikethrough").style(strikethrough) & "  " &
         $styled("reverse").style(reverse) & "  " &
         $styled("blink").style(blink)
    echo ""

    header("DEMO COMPLETE", ch = "═", width = tw)
    echo ""
    success("Demo complete!")

discard """
nim r examples/demo.nim
"""
