# GPIO walk

This is the first physical target test. After loading and running `$0200`, GPIO1 should display a single lit bit walking from bit 0 through bit 7, then clear before returning to the monitor with `SWI`.

It does not use the serial port after loading. A successful run proves S19 load, RAM execution, address `$8000`, and the GPIO1 LEDs.
