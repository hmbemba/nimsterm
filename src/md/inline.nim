## Inline markdown tokenizer.
## Parses: **bold**, *italic*, ***bold+italic***, `code`,
##         ~~strikethrough~~, [links](url), ![images](url)

import
    std/strutils
    ,./mdtypes

proc parseInline*(raw: string): seq[MdToken] =
    var i = 0
    var buf = ""

    template flushBuf() =
        if buf.len > 0:
            result.add MdToken(kind: mkText, text: buf)
            buf = ""

    while i < raw.len:
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

            if count >= 3:
                # Bold+Italic ***text***
                let closeStr = $marker & $marker & $marker
                let closeIdx = raw.find(closeStr, j)
                if closeIdx >= 0:
                    flushBuf()
                    result.add MdToken(kind: mkBoldItalic, text: raw[j ..< closeIdx])
                    i = closeIdx + 3
                    continue

            if count >= 2:
                # Bold **text**
                let closeStr = $marker & $marker
                let closeIdx = raw.find(closeStr, j - (count - 2))
                let startPos = i + 2
                if closeIdx >= startPos:
                    flushBuf()
                    result.add MdToken(kind: mkBold, text: raw[startPos ..< closeIdx])
                    i = closeIdx + 2
                    continue

            if count >= 1:
                # Italic *text*
                let startPos = i + 1
                let closeIdx = raw.find(marker, startPos)
                if closeIdx >= startPos:
                    flushBuf()
                    result.add MdToken(kind: mkItalic, text: raw[startPos ..< closeIdx])
                    i = closeIdx + 1
                    continue

            buf.add raw[i]
            inc i
            continue

        buf.add raw[i]
        inc i

    flushBuf()
