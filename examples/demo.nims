import
    ../src/nimsterm

echo styled("nimsterm (nimscript)").fg(cyan).style(bold)
echo hr()
echo styled("Boxed").fg(green).boxed("rounded")

discard """

nim e examples/demo.nims

"""
