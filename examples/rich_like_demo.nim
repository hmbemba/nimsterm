## nimsterm Rich Demo
##
## Recreates sections from Python Rich's feature demo.
## Run:  nim c -r rich_like_demo.nim

import
    std/[strutils, math]
    ,../src/nimsterm

# ═══════════════════════════════════════════════════════════════════
#  Helpers
# ═══════════════════════════════════════════════════════════════════

proc hueToRgb*(t: float): tuple[r, g, b: int] =
    let sector = t * 6.0
    let f      = sector - floor(sector)
    let q      = (255.0 * (1.0 - f)).int
    let tv     = (255.0 * f).int
    case (sector.int) mod 6
    of 0: result = (r: 255, g: tv,  b: 0)
    of 1: result = (r: q,   g: 255, b: 0)
    of 2: result = (r: 0,   g: 255, b: tv)
    of 3: result = (r: 0,   g: q,   b: 255)
    of 4: result = (r: tv,  g: 0,   b: 255)
    of 5: result = (r: 255, g: 0,   b: q)
    else: result = (r: 255, g: 0,   b: 0)

proc rainbowBar*(width: int): string =
    for i in 0 ..< width:
        let t         = i.float / max(1.0, (width - 1).float)
        let (r, g, b) = hueToRgb(t)
        result &= rgbBg(r, g, b) & " "
    result &= "\x1b[0m"

proc rainbowBarFg*(width: int): string =
    for i in 0 ..< width:
        let t         = i.float / max(1.0, (width - 1).float)
        let (r, g, b) = hueToRgb(t)
        result &= rgb(r, g, b) & "█"
    result &= "\x1b[0m"

proc blendBar*(width: int; r1, g1, b1, r2, g2, b2: int): string =
    for i in 0 ..< width:
        let t = i.float / max(1.0, (width - 1).float)
        let r = (r1.float + (r2 - r1).float * t).int
        let g = (g1.float + (g2 - g1).float * t).int
        let b = (b1.float + (b2 - b1).float * t).int
        result &= rgbBg(r, g, b) & " "
    result &= "\x1b[0m"

# Fix #15: Removed duplicate visLen implementation
# Now uses stripAnsi from nimsterm/util (exported via nimsterm.nim)
proc visLen*(s: string): int =
    ## Calculate visual length by stripping ANSI codes.
    ## Fix #15: Uses stripAnsi from nimsterm/util instead of reimplementing.
    stripAnsi(s).len

const
    LabelWidth = 10   # "Tables" is longest at 6, pad to 10 for alignment
    Gap        = "    "

proc sectionLabel(name: string): string =
    ## Render section label left-padded to LabelWidth, magenta bold.
    let padded = name & " ".repeat(max(0, LabelWidth - name.len))
    $styled(padded).fg(magenta).style(bold)

proc sectionIndent(): string =
    " ".repeat(LabelWidth)

# ═══════════════════════════════════════════════════════════════════
#  Part 1: Color
# ═══════════════════════════════════════════════════════════════════

proc demoColor(tw: int) =
    type CheckItem = object
        label: string
        color: Color

    let items = [
        CheckItem(label: "4-bit color",                color: green),
        CheckItem(label: "8-bit color",                color: green),
        CheckItem(label: "Truecolor (16.7 million)",   color: green),
        CheckItem(label: "Dumb terminals",             color: green),
        CheckItem(label: "Automatic color conversion", color: green),
    ]

    let barGap = " "

    for i, item in items:
        let lbl   = if i == 0: sectionLabel("Colors") else: sectionIndent()
        let check = $styled("✓ ").fg(green) &
                    $styled(item.label).fg(item.color).style(bold)

        let left     = lbl & check & barGap
        let leftVis  = visLen(left)
        let barWidth = max(10, tw - leftVis)

        let bar = case i
            of 0: rainbowBar(barWidth)
            of 1: rainbowBarFg(barWidth)
            of 2: blendBar(barWidth, 0, 0, 0,   255, 0, 255)
            of 3: blendBar(barWidth, 255, 0, 0,  0, 100, 255)
            of 4: rainbowBar(barWidth)
            else: rainbowBar(barWidth)

        echo left & bar

# ═══════════════════════════════════════════════════════════════════
#  Part 2: Text
# ═══════════════════════════════════════════════════════════════════

proc demoText(tw: int) =
    let loremText = "Lorem ipsum dolor sit amet, consectetur " &
                    "adipiscing elit. Quisque in metus sed sapien " &
                    "ultricies pretium a at justo. Maecenas luctus " &
                    "velit et auctor maximus."

    let desc = "Word wrap text. Justify " &
               $styled("left").fg(green) & ", " &
               $styled("center").fg(green) & ", " &
               $styled("right").fg(green) & " or " &
               $styled("full").fg(green) & "."

    echo sectionLabel("Text") & desc
    echo ""

    let contentWidth = max(40, tw - LabelWidth)
    let gutter       = 2
    let colWidth     = max(15, (contentWidth - (gutter * 3)) div 4)

    let leftLines   = wrapLines(loremText, colWidth)
    let centerLines = wrapLines(loremText, colWidth)
    let rightLines  = wrapLines(loremText, colWidth)
    let fullLines   = wrapLines(loremText, colWidth)

    let maxLines = max(@[leftLines.len, centerLines.len, rightLines.len, fullLines.len])

    for row in 0 ..< maxLines:
        var line = ""

        let lText =
            if row < leftLines.len: alignLine(leftLines[row], colWidth, alignLeft)
            else: " ".repeat(colWidth)
        line &= $styled(lText).fg(red)
        line &= " ".repeat(gutter)

        let cText =
            if row < centerLines.len: alignLine(centerLines[row], colWidth, alignCenter)
            else: " ".repeat(colWidth)
        line &= $styled(cText).fg(yellow)
        line &= " ".repeat(gutter)

        let rText =
            if row < rightLines.len: alignLine(rightLines[row], colWidth, alignRight)
            else: " ".repeat(colWidth)
        line &= $styled(rText).fg(green)
        line &= " ".repeat(gutter)

        let fText =
            if row < fullLines.len:
                if row == fullLines.high: alignLine(fullLines[row], colWidth, alignLeft)
                else: justifyLine(fullLines[row], colWidth)
            else: " ".repeat(colWidth)
        line &= $styled(fText).fg(blue)

        echo sectionIndent() & line

# ═══════════════════════════════════════════════════════════════════
#  Part 3: Tables
# ═══════════════════════════════════════════════════════════════════

proc demoTables(tw: int) =
    let cols = [
        richCol("Date",              align = alignLeft,  headerColor = cyan,    cellColor = blue,    cellStyle = bold)
        ,richCol("Title",            align = alignLeft,  headerColor = cyan,    cellColor = green,   cellStyle = italic)
        ,richCol("Production Budget",align = alignRight, headerColor = cyan,    cellColor = magenta, cellStyle = bold)
        ,richCol("Box Office",       align = alignRight, headerColor = cyan,    cellColor = red,     cellStyle = bold)
    ]

    let rows = @[
        @["Dec 20, 2019", "Star Wars: The Rise of Skywalker",       "$275,000,000", "$375,126,118"]
        ,@["May 25, 2018", "Solo: A Star Wars Story",               "$275,000,000", "$393,151,347"]
        ,@["Dec 15, 2017", "Star Wars Ep. VIII: The Last Jedi",     "$262,000,000", "$1,332,539,889"]
        ,@["May 19, 1999", "Star Wars Ep. I: The Phantom Menace",   "$115,000,000", "$1,027,044,677"]
    ]

    let tbl      = richTable(cols, rows, colGap = 4, dimAlternate = true)
    let tblLines = tbl.split('\n')

    for i, line in tblLines:
        if i == 0:
            echo sectionLabel("Tables") & line
        else:
            echo sectionIndent() & line

# ═══════════════════════════════════════════════════════════════════
#  Part 4: Markup
# ═══════════════════════════════════════════════════════════════════

proc demoMarkup(tw: int) =
    # "Rich supports a simple bbcode-like markup for color, style, and emoji! 👍 🍎 👋 🧸 ✏️ 📖"
    let line = "Rich supports a simple " &
               $styled("bbcode").fg(brightBlack).style(italic) &
               "-like " &
               $styled("markup").fg(white).style(bold) &
               " for " &
               $styled("color").fg(red) &
               ", " &
               $styled("style").fg(white).style(underline) &
               ", and emoji! " &
               "👍 🍎 👋 🧸 ✏️  📖"

    echo sectionLabel("Markup") & line

# ═══════════════════════════════════════════════════════════════════
#  Part 5: Styles
# ═══════════════════════════════════════════════════════════════════

proc demoStyles(tw: int) =
    # "All ansi styles: bold, dim, italic, underline, strikethrough, reverse, and even blink."
    let line = "All ansi styles: " &
               $styled("bold").style(bold) &
               ", " &
               $styled("dim").style(dim) &
               ", " &
               $styled("italic").style(italic) &
               ", " &
               $styled("underline").style(underline) &
               ", " &
               $styled("strikethrough").style(strikethrough) &
               ", " &
               $styled("reverse").style(reverse) &
               ", and even " &
               $styled("blink").style(blink) &
               "."

    echo sectionLabel("Styles") & line

# ═══════════════════════════════════════════════════════════════════
#  Main
# ═══════════════════════════════════════════════════════════════════

proc main() =
    let tw = termWidth(80)

    let title    = "Rich features"
    let titlePad = max(0, (tw - title.len) div 2)
    echo ""
    echo " ".repeat(titlePad) & $styled(title).fg(white).style(italic)
    echo ""

    demoColor(tw)
    echo ""
    demoText(tw)
    echo ""
    demoTables(tw)
    echo ""
    demoMarkup(tw)
    echo ""
    demoStyles(tw)
    echo ""

when isMainModule:
    main()
