# M6x09-I Linux terminal

This is the Linux console and S-record transfer path for the M6x09-I. It uses the board's RS-232 DB9 port, not a TTL serial header.

## Hardware

Use the Eminent/ACT EM1016 USB-to-serial adapter:

* USB-A to the Linux host.
* EM1016 male DB9 to the SBC's DB9 through a null-modem crossover.
* The adapter uses a Prolific PL2303 chipset and is normally exposed by Linux as `/dev/ttyUSB0` or, preferably, a stable `/dev/serial/by-id/...` path.

The HIN232/MAX232-class transceiver converts the ACIA's TTL serial signals to RS-232 voltage levels. It does not cross the data direction.

The schematic wires the board as DTE:

* board DB9 pin 2 = RXD;
* board DB9 pin 3 = TXD;
* board DB9 pin 5 = signal ground.

The EM1016 is also a DTE device. Cross pins 2 and 3 between the two devices, and keep pin 5 straight through. A DB9 female-to-male null-modem adapter is the neatest fit if the board has the documented female DB9; a null-modem cable plus the appropriate gender changer is equivalent. No hardware handshaking lines are needed.

## Link settings

The board's 6850 ACIA uses 19,200 baud, 8 data bits, no parity, one stop bit, and no flow control:

```text
19200 8N1, no handshake
```

## Run

Install Tcl/Tk on Debian or Ubuntu:

```bash
sudo apt-get install tk
```

Find the stable adapter name after connecting the EM1016:

```bash
ls -l /dev/serial/by-id/
```

Launch the terminal:

```bash
wish terminal/m6x09-terminal.tcl -device /dev/serial/by-id/USB-Serial_Controller_...
```

For a quick first connection, `/dev/ttyUSB0` is the default.

The kit monitor is keypad-driven; it does not provide an interactive serial command prompt. Press **DUMP** on the keypad to send a memory dump to the terminal. Press **LOAD** before using **File → Send…** to transfer a Motorola S-record. The terminal sends a line at a time and waits for a carriage-return response, which keeps transfers conservative for the monitor.

## Development loop

1. Assemble an application on Linux.
2. Send its `.s19` file to the monitor.
3. Run and inspect it in RAM.
4. Only burn a ROM image after the RAM build is accepted.

The terminal is deliberately a host-side tool. It does not define the SBC; it gives the SBC a reliable text console and a repeatable loading path.

## Verified bring-up

The EM1016/null-modem connection was verified on 2026-10-05 with the monitor banner and a keypad-driven memory dump. See [EM1016-BRINGUP-2026-10-05.md](EM1016-BRINGUP-2026-10-05.md).

The board LCD was also verified on 2026-10-05. Its initial blank appearance was resolved by adjusting the `R13` contrast trimmer; see [LCD-BRINGUP-2026-10-05.md](LCD-BRINGUP-2026-10-05.md).
