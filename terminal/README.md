# M6x09-I Linux terminal

This is the Linux console and S-record transfer path for the M6x09-I. It uses the board's RS-232 DB9 port, not a TTL serial header.

## Hardware

Use the Eminent/ACT EM1016 USB-to-serial adapter:

* USB-A to the Linux host.
* EM1016 male DB9 directly to the SBC's female DB9 port.
* The adapter uses a Prolific PL2303 chipset and is normally exposed by Linux as `/dev/ttyUSB0` or, preferably, a stable `/dev/serial/by-id/...` path.

Do not add a null-modem cable unless terminal testing proves this particular board/adapter pairing requires one. The SBC documentation notes that its DB9 was fitted female to match the USB-to-DB9 adapter.

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

Use **File → Send…** to send Motorola S-record files. The terminal sends a line at a time and waits for a carriage-return response, which keeps transfers conservative for the monitor.

## Development loop

1. Assemble an application on Linux.
2. Send its `.s19` file to the monitor.
3. Run and inspect it in RAM.
4. Only burn a ROM image after the RAM build is accepted.

The terminal is deliberately a host-side tool. It does not define the SBC; it gives the SBC a reliable text console and a repeatable loading path.
