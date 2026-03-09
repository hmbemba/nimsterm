## nimsterm_md - Nim-native terminal markdown renderer
##
## Parses CommonMark-ish markdown and renders it with ANSI styling
## for modern terminals. Built on top of nimsterm.
##
## Usage:
##   import nimsterm_md
##   printMarkdown(readFile("README.md"))
##
## Or for more control:
##   let blocks = parseBlocks(source)
##   let output = renderBlocks(blocks, defaultTheme())
##   echo output

import mdtypes
    ,inline
    ,parser
    ,renderer

export
    mdtypes
    ,inline
    ,parser
    ,renderer