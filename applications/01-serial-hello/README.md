# Serial hello

After the S19 file is loaded and `$0200` is run, the Tcl terminal should show:

```text
M6x09-I: serial application path is alive
```

This is stronger than the monitor DUMP test: the text is transmitted by RAM-resident application code that initializes and drives the ACIA directly.
