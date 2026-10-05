# LCD Bring-Up — 2026-10-05

## Result

The M6x09-I text LCD is working with the installed monitor ROM. The automatic power-on message became visible after adjusting the `R13` contrast trimmer.

This confirms the complete LCD path:

```text
monitor ROM → 6809 bus → $9000–$9003 LCD interface → JR1 → HD44780-compatible LCD
```

No firmware, bus, or LCD-module repair was required. The initial blank appearance was a contrast-calibration issue.

## Operational notes

* Set `R13` for crisp text with a clear background.
* The monitor initializes and writes its welcome text automatically at reset.
* Power the kit off before inserting or removing the LCD module, as required by the original kit documentation.

## Readiness status

The pre-experimental platform is now verified:

* 6809 monitor boots and displays its serial banner.
* Linux communicates through the EM1016 and null-modem crossover at 19,200 8N1.
* The keypad **DUMP** path produces a memory dump in the Linux terminal.
* The LCD monitor output is visible after contrast adjustment.

The next step is the application sequence in [applications/README.md](../applications/README.md), beginning with the GPIO walk RAM test.
