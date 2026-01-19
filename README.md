# nimsterm

A Windows-friendly terminal helper library that works in:
- regular Nim programs (`nim c`, `nim r`)
- NimScript programs (`nim e`)

It merges:
- Styled text (ANSI), boxing, wrapping, padding, truncation
- Terminal control (clear, cursor movement, hide/show cursor, scroll)
- Input helpers (prompt, confirm, choice)
- Progress bars + spinners
- Tables (bordered + simple)
- Semantic output helpers (success/warn/error/info/debug/header/divider)
- RGB / truecolor helpers (optional; modern terminals)
- Nim/NimScript-friendly IO + terminal sizing fallbacks + ANSI stripping

## Install

```bash
nimble install
```

