import ../src/md

const testDoc = """
# nimsterm_md — Terminal Markdown Renderer

A full-featured CommonMark-ish renderer built on **nimsterm**.
Parses raw markdown and outputs beautiful **ANSI-styled** terminal text.

---

## Inline Formatting

Mix and match styles freely within any paragraph or list item:

- **Bold text** for emphasis
- *Italic text* for subtle stress
- ***Bold and italic*** when you really mean it
- `inline code` for commands or variables
- ~~Strikethrough~~ for deprecated info
- Combine them: **bold with `code` inside** and *italic with ~~strike~~*

## Links & Images

Here's a [link to Nim](https://nim-lang.org), the language this is built with.
Check out [nimsterm on GitHub](https://github.com/user/nimsterm) for the source.

Images render as labels: ![Nim logo](https://nim-lang.org/assets/img/logo.svg)

---

## Headings (all 6 levels)

# H1 — Page Title
## H2 — Major Section
### H3 — Subsection
#### H4 — Topic
##### H5 — Detail
###### H6 — Fine Print

---

## Code Blocks

### With Language Tag

```nim
import nimsterm

proc greet(name: string) =
    let msg = styled("Hello, " & name & "!").fg(green).style(bold)
    echo $msg

when isMainModule:
    greet("world")
    success("Build complete")
    warning("Deprecated API detected")
```

### Without Language Tag

```
$ nim c -r myapp.nim
Hello, world!
Build complete.
```

### Multi-Language Examples

```python
def fibonacci(n: int) -> list[int]:
    fib = [0, 1]
    for i in range(2, n):
        fib.append(fib[-1] + fib[-2])
    return fib

print(fibonacci(10))
```

```bash
#!/bin/bash
echo "Installing dependencies..."
for pkg in nimsterm nimble; do
    nimble install "$pkg" --accept
done
echo "Done!"
```

---

## Lists

### Unordered — Flat

- First item with **bold emphasis**
- Second item with `inline code`
- Third item with a [link](https://example.com)
- Fourth item with ~~strikethrough~~

### Unordered — Nested

- Top-level item one
  - Nested child A
  - Nested child B
- Top-level item two
  - Another nested item
  - And one more
- Top-level item three (no children)

### Ordered

1. Clone the repository
2. Install dependencies with `nimble install`
3. Run the demo: `nim r examples/demo.nim`
4. Profit!

### Mixed Nesting

- **Setup**
  - Install Nim via `choosenim`
  - Run `nimble init` in your project folder
- **Development**
  - Write your code in `src/`
  - Test with `nimble test`
- **Deployment**
  - Build release: `nim c -d:release src/app.nim`
  - Ship the binary

---

## Blockquotes

> The best way to predict the future is to invent it.
> — **Alan Kay**

> Markdown is intended to be as easy-to-read and easy-to-write
> as is feasible. Readability, however, is emphasized above all else.
> A Markdown-formatted document should be publishable as-is,
> as *plain text*.
> — **John Gruber**

> Single line quote with `code` and **bold**.

---

## Tables

### Star Wars Box Office

| Date             | Title                                  | Budget        | Box Office       |
|------------------|----------------------------------------|:-------------:|-----------------:|
| Dec 20, 2019     | Star Wars: The Rise of Skywalker       | $275,000,000  | $375,126,118     |
| May 25, 2018     | Solo: A Star Wars Story                | $275,000,000  | $393,151,347     |
| Dec 15, 2017     | Star Wars Ep. VIII: The Last Jedi      | $262,000,000  | $1,332,539,889   |
| May 19, 1999     | Star Wars Ep. I: The Phantom Menace    | $115,000,000  | $1,027,044,677   |

### Feature Matrix

| Feature          | Status    | Notes                    |
|------------------|-----------|--------------------------|
| Bold             | ✓         | **text** or __text__     |
| Italic           | ✓         | *text* or _text_         |
| Bold+Italic      | ✓         | ***text***               |
| Inline Code      | ✓         | backtick wrapped         |
| Strikethrough    | ✓         | ~~text~~                 |
| Links            | ✓         | [text](url)              |
| Images           | ✓         | ![alt](url)              |
| Headings 1-6     | ✓         | # through ######         |
| Code Blocks      | ✓         | fenced with backticks    |
| Blockquotes      | ✓         | > prefix                 |
| Unordered Lists  | ✓         | - / * / + markers        |
| Ordered Lists    | ✓         | 1. 2. 3. etc             |
| Nested Lists     | ✓         | indented sub-items       |
| Tables           | ✓         | pipe-delimited           |
| Horizontal Rules | ✓         | --- / *** / ___          |

### Compact Table

| Cmd     | Description          |
|---------|----------------------|
| help    | Show help            |
| version | Display version      |
| run     | Execute program      |
| test    | Run test suite       |
| build   | Compile release      |

---

## Horizontal Rules

Three different styles all produce the same rule:

---

***

___

---

## Edge Cases

Paragraph with no special formatting at all. Just plain text flowing
naturally across multiple lines that get joined into a single paragraph
block by the parser.

A paragraph immediately after another paragraph with no blank line
should still work as expected.

> Blockquote followed immediately by...

A regular paragraph.

- List followed by...

A paragraph right after.

---

## Wrapping Up

That covers the full feature set of **nimsterm_md**:

1. All six heading levels with distinct styling
2. Rich inline formatting — bold, italic, code, links, strikethrough
3. Fenced code blocks with language tags
4. Nested unordered and ordered lists
5. Blockquotes with inner formatting
6. Tables with alignment support
7. Horizontal rules
8. Configurable themes via `MdTheme`

Built on top of **nimsterm** — no duplicated ANSI escape codes.

*Happy terminal rendering!* 🚀
"""

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           nimsterm_md — Terminal Markdown Renderer          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

printMarkdown(testDoc)