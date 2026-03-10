## Inline markdown tokenizer.
## Parses: **bold**, *italic*, ***bold+italic***, `code`,
##         ~~strikethrough~~, [links](url), ![images](url)
## Fix #10: Supports backslash escapes (\*, \_ etc)

import
    std/strutils
    ,./mdtypes

# Fix #10: Characters that can be escaped with backslash
const EscapableChars = {'\\', '`', '*', '_', '{', '}', '[', ']', '(', ')', '#', '+', '-', '.', '!', '~'}

proc parseInline*(raw: string): seq[MdToken] =
    var i = 0
    var buf = ""

    template flushBuf() =
        if buf.len > 0:
            result.add MdToken(kind: mkText, text: buf)
            buf = ""

    while i < raw.len:
        # Fix #10: Handle backslash escapes
        if raw[i] == '\\' and i + 1 < raw.len and raw[i + 1] in EscapableChars:
            buf.add raw[i + 1]  # Add the escaped character literally
            i += 2
            continue

        # Image: ![alt](url)
        if i < raw.len - 1 and raw[i] == '!' and raw[i + 1] == '[':
            let altStart = i + 2
            let altEnd   = raw.find(']', altStart)
            if altEnd >= 0 and altEnd + 1 < raw.len and raw[altEnd + 1] == '(':
                let urlStart = altEnd + 2
                let urlEnd   = raw.find(')', urlStart)
                if urlEnd >= 0:
                    flushBuf()
                    result.add MdToken(
                        kind:    mkImage,
                        altText: raw[altStart ..< altEnd],
                        imgUrl:  raw[urlStart ..< urlEnd]
                    )
                    i = urlEnd + 1
                    continue
            buf.add raw[i]
            inc i
            continue

        # Link: [text](url)
        if raw[i] == '[':
            let textStart = i + 1
            let textEnd   = raw.find(']', textStart)
            if textEnd >= 0 and textEnd + 1 < raw.len and raw[textEnd + 1] == '(':
                let urlStart = textEnd + 2
                let urlEnd   = raw.find(')', urlStart)
                if urlEnd >= 0:
                    flushBuf()
                    result.add MdToken(
                        kind:     mkLink,
                        linkText: raw[textStart ..< textEnd],
                        linkUrl:  raw[urlStart ..< urlEnd]
                    )
                    i = urlEnd + 1
                    continue
            buf.add raw[i]
            inc i
            continue

        # Backtick code
        if raw[i] == '`':
            let closeIdx = raw.find('`', i + 1)
            if closeIdx >= 0:
                flushBuf()
                result.add MdToken(kind: mkCode, text: raw[i + 1 ..< closeIdx])
                i = closeIdx + 1
                continue
            buf.add raw[i]
            inc i
            continue

        # Strikethrough ~~text~~
        if i + 1 < raw.len and raw[i] == '~' and raw[i + 1] == '~':
            let closeIdx = raw.find("~~", i + 2)
            if closeIdx >= 0:
                flushBuf()
                result.add MdToken(kind: mkStrikethrough, text: raw[i + 2 ..< closeIdx])
                i = closeIdx + 2
                continue
            buf.add raw[i]
            inc i
            continue

        # Bold/Italic with * or _
        if raw[i] in {'*', '_'}:
            let marker = raw[i]

            # Count consecutive markers
            var count = 0
            var j = i
            while j < raw.len and raw[j] == marker:
                inc count
                inc j

            # Fix #11: Improved bold/italic interleaving logic
            # Process markers from longest to shortest match
            var matched = false
            
            # Try *** (bold+italic) first
            if count >= 3:
                let closeStr = $marker & $marker & $marker
                let closeIdx = raw.find(closeStr, j)
                if closeIdx >= 0:
                    flushBuf()
                    result.add MdToken(kind: mkBoldItalic, text: raw[j ..< closeIdx])
                    i = closeIdx + 3
                    matched = true
            
            # Try ** (bold) 
            if not matched and count >= 2:
                let closeStr = $marker & $marker
                # Search from current position, not from j
                let closeIdx = raw.find(closeStr, i + 2)
                if closeIdx >= i + 2:
                    flushBuf()
                    result.add MdToken(kind: mkBold, text: raw[i + 2 ..< closeIdx])
                    i = closeIdx + 2
                    matched = true
            
            # Try * (italic)
            if not matched and count >= 1:
                let closeIdx = raw.find(marker, i + 1)
                # Make sure we don't match a marker that's part of a larger run
                # by checking that it's a single marker
                if closeIdx >= i + 1:
                    # Check that this is a valid closing marker (single marker or end of different run)
                    var isValidClose = true
                    if closeIdx + 1 < raw.len and raw[closeIdx + 1] == marker:
                        # The closing position has multiple markers - need to be careful
                        # Only valid if it's exactly one marker or we've consumed extra markers
                        isValidClose = false
                    
                    # Fallback: if we can't find a proper single-marker close,
                    # try finding any single marker after position i+2
                    if not isValidClose:
                        # Look for a lone marker (not followed by same marker)
                        var searchPos = i + 1
                        while searchPos < raw.len:
                            if raw[searchPos] == marker:
                                # Check if this is a lone marker
                                if searchPos + 1 >= raw.len or raw[searchPos + 1] != marker:
                                    flushBuf()
                                    result.add MdToken(kind: mkItalic, text: raw[i + 1 ..< searchPos])
                                    i = searchPos + 1
                                    matched = true
                                    break
                            inc searchPos
                    else:
                        flushBuf()
                        result.add MdToken(kind: mkItalic, text: raw[i + 1 ..< closeIdx])
                        i = closeIdx + 1
                        matched = true

            if matched:
                continue

            buf.add raw[i]
            inc i
            continue

        buf.add raw[i]
        inc i

    flushBuf()

discard """

Inline Markdown Parser

Supports:
- **bold**, *italic*, ***bold+italic***
- `code`
- ~~strikethrough~~
- [links](url)
- ![images](url)
- Fix #10: Backslash escapes for: \*, \_, \`, etc.
- Fix #11: Improved handling of interleaved markers like ***text***

"""
