import
    ../src/nimsterm

echo styled("nimscript smoke").fg(cyan).style(bold)
echo hr()
echo stripAnsi("\x1b[31mX\x1b[0m")

discard """

nim e tests/t_nimscript_smoke.nims

"""
