# M6x09-I applications and experiments

These programs run on the physical M6x09-I. They are deliberately small and build on one another: first prove RAM execution, then prove target-to-host text, then run the first embodied interaction experiment inspired by [cartheur/ideal](https://github.com/cartheur/ideal).

## Build

Build every experiment on Linux:

```bash
make -C applications
```

Each build produces an ignored `.s19` file beside its source. At the kit, press **LOAD**, use the Tcl terminal's **File → Send…** action to send the S19 file, then use the keypad to run its entry point at `$0200`.

The current monitor needs approximately 1 ms of pacing between transmitted characters. The Tcl terminal's 2 ms default is intentionally conservative.

## Experiment sequence

| Directory | Program | What it proves |
| --- | --- | --- |
| `00-gpio-walk/` | `gpio_walk.s19` | S19 loading, RAM execution, and GPIO1 LED output. |
| `01-serial-hello/` | `serial_hello.s19` | The target program can transmit deterministic text through the verified RS-232 link. |
| `02-ideal010/` | `ideal010.s19` | An `ideal` Section 1 interaction loop: initiate an experiment, receive a result, record the pair, anticipate its next result, and change experiment after boredom. |

All programs load at `$0200`, remain in RAM, use no interrupts, and end with `SWI`, returning control to the monitor. They do not alter ROM.

## Shared target contract

The shared include in `common/m6x09_i.inc` defines the verified board addresses:

* GPIO1 output: `$8000`
* ACIA control/status: `$A000`
* ACIA data: `$A001`

The direct ACIA routines deliberately avoid depending on undocumented monitor entry points. They use the same 19,200-baud initialization observed in the 2020 monitor listing.

## Promotion rule

An experiment becomes a ROM candidate only after its source revision, S19 checksum, load/run procedure, observed output, and hardware prerequisites have been recorded. Until then, RAM is the working environment.
