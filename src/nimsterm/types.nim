type
    Color          * = enum
        colDefault   = -1
        black        = 0
        red
        green
        yellow
        blue
        magenta
        cyan
        white
        brightBlack = 60
        brightRed
        brightGreen
        brightYellow
        brightBlue
        brightMagenta
        brightCyan
        brightWhite

    Style          * = enum
        bold          = 1
        dim          = 2
        italic       = 3
        underline    = 4
        blink        = 5
        reverse      = 7
        hidden       = 8
        strikethrough= 9

    StyledText     * = object
        text        * : string
        fg          * : Color
        bg          * : Color
        styles      * : seq[Style]

    MenuResult     * = object
        index       * : int
        value       * : string
        cancelled   * : bool

    Align          * = enum
        alignLeft
        alignCenter
        alignRight

    Column         * = object
        header      * : string
        width       * : int
        align       * : Align

    TermSize       * = object
        w           * : int
        h           * : int

discard """

Core types for nimsterm.

"""
