## Markdown token and AST types for nimsterm_md.

type
    MdTokenKind* = enum
        mkText
        mkBold
        mkItalic
        mkBoldItalic
        mkCode
        mkStrikethrough
        mkLink
        mkImage

    MdToken* = object
        case kind*: MdTokenKind
        of mkLink:
            linkText*: string
            linkUrl*:  string
        of mkImage:
            altText*:  string
            imgUrl*:   string
        else:
            text*:     string

    MdBlockKind* = enum
        mbParagraph
        mbHeading
        mbCodeBlock
        mbBlockquote
        mbUnorderedList
        mbOrderedList
        mbHorizontalRule
        mbTable
        mbEmptyLine

    MdListItem* = object
        tokens*:   seq[MdToken]
        children*: seq[MdListItem]   ## nested sub-items

    MdTableRow* = object
        cells*: seq[string]

    MdTableAlign* = enum
        taLeft
        taCenter
        taRight

    MdBlock* = object
        case kind*: MdBlockKind
        of mbHeading:
            level*:       int
            headingTokens*: seq[MdToken]
        of mbParagraph:
            tokens*:      seq[MdToken]
        of mbCodeBlock:
            lang*:        string
            code*:        string
        of mbBlockquote:
            quoteBlocks*: seq[MdBlock]
        of mbUnorderedList:
            ulItems*:     seq[MdListItem]
        of mbOrderedList:
            olItems*:     seq[MdListItem]
            olStart*:     int
        of mbHorizontalRule:
            discard
        of mbTable:
            tableHeaders*: seq[string]
            tableAligns*:  seq[MdTableAlign]
            tableRows*:    seq[MdTableRow]
        of mbEmptyLine:
            discard