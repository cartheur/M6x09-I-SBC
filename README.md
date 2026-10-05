# M6x09-I Linux Development System

This repository develops applications for a Motorola 6809 / Hitachi 6309 single-board computer. Linux is the development host; the SBC is a computer in its own right. The host assembles, transfers, records, and burns images. The board runs those images from RAM or ROM.

_Goal_: build small, understandable `x09` applications that can graduate from a serial-loaded RAM image to a reproducible ROM image.

## Working model

```text
Linux workstation -- USB / EM1016 -- null modem -- RS-232 DB9 -- M6x09-I SBC
       |                                           |
       +-- bs9 assembles applications               +-- RAM: fast iteration
       +-- Tcl/Tk terminal transfers S-records      +-- EPROM: stable releases
       +-- programmer writes accepted ROM images
```

The EM1016 is a Prolific PL2303-based USB-to-RS-232 adapter with a male DB9 connector. The board's HIN232/MAX232-class transceiver provides a real RS-232 interface, not a TTL/FTDI connection. Both ends are DTE, so the connection needs a null-modem crossover for transmit and receive.

## Start here

1. Read [terminal/README.md](terminal/README.md) and establish the 19,200 8N1 console link.
2. Build the Linux assembler with `make -C crosscompiler`.
3. Put new target programs in `applications/`; assemble them into S-records, test them in RAM, and only then make a ROM release.

Serial bring-up is verified: the EM1016/null-modem link delivered the kit monitor banner and a keypad-driven memory dump to Linux at 19,200 8N1. The automatic LCD welcome message is also visible after `R13` contrast calibration. See [the serial bring-up record](terminal/EM1016-BRINGUP-2026-10-05.md) and [the LCD bring-up record](terminal/LCD-BRINGUP-2026-10-05.md).

The monitor is keypad-driven, not a serial command shell. Use **DUMP** on the keypad for terminal output and **LOAD** before transmitting an S19 file. The terminal workflow is documented in [terminal/README.md](terminal/README.md).

## Repository map

* `applications/` — future 6809/6309 applications and their build recipes.
* `crosscompiler/` — Linux-hosted `bs9` assembler source.
* `terminal/` — Tcl/Tk RS-232 terminal and file-transfer workflow.
* `doc/`, `images/`, and `6309/` — hardware and processor reference material.
* `kit/`, `code/`, `cocodev/`, `emulator/`, and `z-archives/` — preserved kit, vendor, emulator, and archival artifacts.

The DOS-specific `cc09` compiler, its duplicated tool trees, and its monitor outputs have been deliberately removed from the working tree. They remain recoverable from Git history, but they are not part of the Linux development path.

Sister repositories:

* Multiprocessing [source](https://github.com/cartheur/M6809-ForthWiki)
* Extension SBC [code](https://github.com/cartheur/M6x09-A/tree/main/sbc)
* HD6309 SBC I [project](https://github.com/cartheur/M6x09H1-SBC)
* HD6309 SBC II [project](https://github.com/cartheur/M6x09H2-SBC)
* 6x09-SPL [project](https://github.com/cartheur/M6x09-spl)
* GNU and CodeWarrior [dev](https://github.com/cartheur/M6x09-SBC-GNU)
* TurboNine [pipeline](https://github.com/cartheur/M6x09-pipeline-09)
* Small-C[68](https://github.com/cartheur/M6x09-SBC-Small68)

Notes on the above repos

* The SPL is the ideal place to begin (continuing with _ideal_), however, a SBC with connectivity to a Linux development machine is requisite. The impetus was to follow-on with HC6309 SBC I but it is authored in OrCad (thanks!), so needs another line of thinking.
* Our _original_ trajectory is the one to follow, that is, the impetus contained in this repository.

Operating systems-of-interest:

* [CP/M](http://www.gaby.de/cpm/)
* CP/M [2.2](https://github.com/cartheur/cpmish)

Further documentation:

* The topic of [multiprocessing](https://en.wikipedia.org/wiki/Multiprocessing)
* Differences between [3-and-9](https://retrocomputing.stackexchange.com/questions/25/advantages-of-a-hitachi-hd6309-versus-a-plain-motorola-mc6809)
* Retro [computing](https://retrocomputingforum.com/t/adventures-with-the-6809-and-6309/2795)
* Expanding the [CPU](https://hackaday.io/page/6889-6809-cpu-on-steroids)
* CoCoDEV [remote](http://www.davebiz.com/wiki/CoCoDEV)
* CoCoDEV [local](/cocodev/README.md)
* Retro[Shield](http://www.8bitforce.com/blog/2019/03/12/retroshield-6809-operation/)

## Building a multicomputer experimental station around the `x09` architecture

This project is based on a Motorola 6809 training kit with a 6850 ACIA, keypad, display, RAM, EPROM, and expansion header. Its compact PLD-based address decoding makes it a practical target for direct hardware experiments.

The Linux toolchain uses the `bs9` cross-assembler. The main clock frequency is 4.9152MHz. The UART uses E clock, 4.9152MHz/4, as its TXD/RXD clock. With a prescaler of 64, the serial link is 19,200 bit/s.

The ROM monitor supports direct, keypad-based experimentation as well as Linux-hosted assembly and S-record transfer:

* Enter and test short machine-code programs with the keypad.
* Assemble applications on Linux with `bs9`, press **LOAD**, and send an S19 file into RAM.

## Hardware description

* U5 is the Motorola 6809 CPU. The 4.9152MHz is generated by onchip oscillator with internal frequency 1.228MHz for CPU operations. NMI, HALT, IRQ, FIRQ are pull-up to logic 1 with R2. Only E and R/W and A0,A1, A10-A15 are used for memory decoding.
* U1 is a 27C256, a 32 KiB EPROM. The board decodes its 16 KiB ROM window at `0xC000`–`0xFFFF`; a ROM release must match that mapped window.
* U2 is 32kB static RAM, 62256. The RAM space is located at 0x0000-0x7FFF. Zero page is located at 0x0000-0x00FF. User program can be tested from address 0x0200.
* U4, memory and I/O spaces decoder chip is made with GAL16V8D. It provides chip selected signals for memory and I/O chips.
* U3, the 20-pin 89C2051 microcontroller chip produces 10ms tick. SW1 selects between 10ms tick or manual IRQ button.
* U6 is 6850 ACIA, UART. The shift clock is derived from E clock, 1,228,800Hz. Internal prescaler is 64. Thus the bit rate will be 19,200 bit/s.
* U12, 74HC541 is 8-bit input port (PORT0). Six bits, PA0-PA5 are input signals of the row keypad.
* U10, 74HC573 is 8-bit output port (PORT2). The 8-bit output drives the 7-segment LED directly. No current limit resistor. U11 (PORT1) drives 6-digit common cathode pin. The brightness is controlled by software controlled PWM. PC7 is speaker output for beep signal.
* U13, 74HC573 is 8-bit output port for 8-bit binary number display. D13 lifts the forward biasing for proper brightness. JR1 is 16-pin socket for text LCD interface. U14, HIN232 converts TTL level to RS232 level.
* Q2 is a KIA704x brownout-reset device. The inherited kit documentation names both KIA7042 and KIA7045; verify the fitted marking before replacement.

![Hardware schematic](/images/schematic.png)

### Hardware Features

* CPU: Motorola 68c09, 8-bit Microprocessor with a 1.2288MHz clock
* Memory: 32 KiB RAM; 16 KiB decoded EPROM window populated by a 27C256
* Memory and I/O Decoder chip: Programmable Logic Device GAL16V8D
* Display: high brightness 6-digit 7-segment LED
* Keyboard: 36 keys
* RS232 port: 6850 ACIA 19,200 bit/s 8n1
* Debugging LED: 8-bit GPIO1 LED at location $8000
* Tick: 10ms tick produced by 89C2051 for time trigger experiment
* Text LCD interface: direct CPU bus interface text LCD
* Brownout reset: KIA704x reset device; verify the fitted part number
* Expansion header: 40-pin header

The board's ROM monitor is the stable recovery environment. Develop applications on Linux, load them into RAM over the serial link, and burn a ROM only once an image is accepted.

### Monitor operation

* Simple hex code entering
* Insert and Delete byte
* User registers: `A`, `B`, `X`, `Y`, `S`, `U`, `DP` Condition code registers for storing CPU status after-program execution
* HEX calculator for offset calculation
* Copy block of memory
* Motorola s-record S19 downloading
* Memory dump
* Beep ON/OFF
* TEST 10ms

Serial actions are initiated from the keypad: **DUMP** writes a memory dump to the terminal and **LOAD** receives Motorola S19 records. The monitor banner and DUMP path were verified on 2026-10-05; see [the bring-up record](terminal/EM1016-BRINGUP-2026-10-05.md).

### Keyboard layout

Making key layout sticker is simply done by printing the SVG file to sticker paper.

![Keyboard layout](/images/key.png)

### Test code

![An example](/images/test-code.png)

Simple program that writes accumulator content to `gpio1` LED at `$8000`. It will show 8-bit binary counting. `Delay1` is small delay subroutine that uses `X` register. One can enter the hex code into memory and test run directly.

Can you change the speed to run faster?

Another example of using 10ms tick generator for counting binary at 1Hz rate. Change SW1 to 10ms tick.

![Tick-generator example](/images/tick-generator.png)

The IRQ vector in ROM is pointed to new location in RAM at `$7FF0`. Students can modify where to put IRQ service routine. Above example uses location `$6000` for IRQ service. The main code then inserts JMP to IRQ service instruction, `7E 60 00` to location `7FF0`. Then clear `I` flag and wait for interrupt.

The IRQ service uses location `0` for tick counting. When it reaches `100`, clear it and increment location `1`. We can see 1Hz rate counting of location `1` by sending it to `gpio1` LED at location `8000`.

Can you change from 1Hz to 10Hz counting rate?

![Terminal](/images/terminal1.png)
Example terminal memory dump.

![Terminal](/images/terminal2.png)
S-record file transfer with 1ms character delay setting.

### Program-state output

![With display](/images/6809v1-2s.jpg)

### Parts list

#### Semiconductors

* U1 27C256, 32 KiB EPROM (16 KiB decoded on this board)
* U2 HM62256B, 32kB SRAM
* U3 AT89C2051, 8-bit microcontroller
* U4 GAL16V8D, PLD
* U5 Motorola 68B09, 8-bit microprocessor
* U6 Motorola 6850, ACIA chip
* U7 7805, voltage regulator
* U9,U8 LTC-4727, 7-segment display
* U10,U11,U13 74HC573
* U12 74HC541
* U14 HIN232, RS-232 converter
* Q2 KIA704x brownout-reset device (verify fitted part)
* Q3 BC557 D4 1N4007
* D13 1N5227A
* D14 1N4733A D1,D5,D6,D7,D8,D9,D10, LED
* D11,D12
* D3 POWER LED

#### Resistors (all resistors are 1/8W +/-5%)

* R1 680
* R2 RESISTOR SIP 9
* R3 100
* R13,R4 10k
* R6,R5 1k
* R9,R7 4.7k
* R11,R8 10k RESISTOR SIP 9
* R12,R10 10

#### Capacitors

* C1,C4,C5,C15,C18,C19,C20 10uF
* C3,C2 27pF
* C6 10uF 16V
* C7 1000uF25V
* C8,C9,C10,C11,C12 0.1uF
* C13,C14 0.1uF
* C21,C16 100nF
* C17 10uF 10V

#### Additional parts

* JP1 HEADER 20X2
* JR1 CONN RECT 16
* J1 DC Input
* J2 CON3
* J3 CON4A
* LS1 SPEAKERSW1 ESP switch
* SW2 IRQ
* SW3 RESET
* SW4 FIRQ
* SW5 NMI
* S1,S2,S3,S4,S5,S6,S7,S8
* SW PUSHBUTTON: S9,S10,S11,S12,S13,S14,S15,S16,S17,S18,S19,S20,S21,S22,S23,S24,S25,S26,S27,S28,S29,S30,S31,S32
* TP1,TP2,TP3 TEST POINT
* TP4 +5V
* TP5 GND
* VB1 SUB-D 9; the original kit specifies male and a cross cable. This assembled board uses a female connector and an inline female-to-male null-modem adapter.
* Y1 4.9152MHz XTAL
* PCB double side plate through hole display filter sheet, Amber color, Keyboard sticker printable SVG file

### Files

* [Schematic](/doc/schematic6809.pdf)
* [Monitor listing](/doc/monitorlist.pdf)
* [PLD files](/code/pld6809.rar)
* [Keypad graphic](/images/key6809.svg)
* [Quick-Start Guide](/doc/quickstart.pdf)

* [Programming Book for 6809 Kit = v1.2](/doc/programmingbook.pdf)
* [Programming Book for 6809 Kit = v2.0](/doc/programmingbook2.pdf)
* [User's Manual](/doc/6809usermanual.pdf)
* [Original kit page and bundled assets](/kit/6x09%20Kit.html)

### Keyboard spacer

[Keyboard spacer](/kit/keypad/MICRO09KEY.stl) 3D file for 6809 kit.

### Project updates

* 08.01.2024: 80% of the components soldered. What remains are the reisitors (because I need to measure these tiny things to match their values) the 7805 with thermal paste, and the header for the LCD. Note that I swapped the male 9-pin serial socket for a female, given my USB-to-9-pin is oriented thusly.
* 10.01.2024: Board is completed, cleaned with ethyl alcohol to remove flux and brunished with a brass wheel. Final remnants of dust removed by cotton swab.
* 11.01.2024: Assembly is planned but not scheduled due to other work needing attention.
* 12.01.2024: Cleaning finished but residue from chemical reaction of ethyl alcohol to solder flux seeped into 35% of the socket runs. Used the brass wheel to clean. This does not appear in the v2 SBC boards.
* 13.01.2024: Board awaiting assembly but will firstly organize a memory map indication of the v2 SNC.
* 14.01.2024: The memory-map task is still pending.
* 05.10.2026: The repository was refocused on Linux-hosted development. A female-to-male null-modem adapter was built and the EM1016 serial path was verified at 19,200 8N1: the monitor banner and keypad DUMP output were received in the Tcl/Tk terminal. See [the bring-up record](terminal/EM1016-BRINGUP-2026-10-05.md).
* 05.10.2026: An intermittent numeric-display change from its initial `6809` state was observed while the board was idle. The monitor source indicates this is likely a phantom keypad event rather than intended idle behavior. It is not currently blocking experimentation; record occurrences during RAM runs and inspect the keypad matrix, pull-ups, and associated solder joints only if it becomes repeatable or affects experiment integrity.

### References

* [Grant Searle](http://searle.x10host.com/6809/Simple6809.html)
