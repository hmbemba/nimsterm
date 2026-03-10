Done! I've added a clean reusable `withHiddenCursor` template that:

1. **Hides the cursor** before executing the spinner animation
2. **Uses a try/finally block** to ensure the cursor is always restored, even if an exception occurs
3. **Wraps the entire spinner loop** to eliminate all cursor flickering

The changes:

```nim
template withHiddenCursor(body: untyped): untyped =
    ## Executes body with cursor hidden, ensuring cursor is restored even on exception
    hideCursor()
    try:
        body
    finally:
        showCursor()
```

And updated `demoSpinner` to use it:

```nim
proc demoSpinner(...) =
    ...
    withHiddenCursor:
        for i in 0..<iterations:
            sp.tick()
            sleep(intervalMs)
    ...
```

Now the spinners will render cleanly without any cursor flashing. The template is reusable - you can use `withHiddenCursor:` anywhere you need cursor-free terminal output!