## Compiling tools, monitor, and cc09

Here you can find how to build and optimize the sources in this folder.

### CC09 (MSDOS) C COMPILER

The Small C Compiler for 6809 running on FLEX (CUG 221) has been ported to MSDOS, and changed to allow creation of embedded target software. It supports the ASxxx group of assemblers (CUG 292) available from the C users Group, as well as the Motorola AS9 assembler.

A host of routines is supplied. These work with particular boards used by our students. The system we have is,

6809 Processor card, 32k StaticRAM `0000` to `7FFF`

* Addresses `9000-93ff` are port mapped to `000` to `3ff` for PC type boards
* Addresses `8000 to 8fff` are mapped to `B0000` for PC monochrome cards
* On board ACIA, MC6850 at `A000` (ControlReg) `A001` (DataReg)
* OnBoard EPROM or StaticRAM `C000` to `FFFF`

The processor card drives an IBM-PC backplane with four expansion sockets, thus can talk directly to standard PC cards. The routines for this board are `ACIA.H`, `MEMORY.H`, `STRINGS.H`.

* Standard PC Serial Card (`SERIAL.H`)
* Standard Hercs/Monochrome card (`HERCS.H`, `PRINTER.H`)

32-bit Digital I/O card, plus 8-channel A/D (0808 chip). The mapping arrangment of this board is,
* Port `220h`  A/D Channel register
* Port `221h`  A/D Data register
* `222h`  A/D End Of Conversion signal
* `223h`  Simple latched I/O
* `224h`  8255 PPI Port A
* `225h`  8255 PPI Port B
* `226h`  8255 PPI Port C
* `227h`  Intel 8255 PPI control register

In conjunction with this board, a panel comprising,
* 1 x 7 segment display
* 1 x 8 LEDS 
* 1 x 8 Digital Switches
* 1 x 16 hexidecimal keypad

is used to allow students to write software routines: `DIOBOARD.H`, `MCRDRV.H` - A magnetic card swipe reader attaches to port C of the DIOBoard.

The DIOBoards address is configurable via DIP, and the A/D convertor can be
   - strapped for auto restart, `EOC` signal restarts ADC
   - software polled via `EOC` bit status
   - Interrupt driven, by staps which connect `EOC` to `IRQ2` to `IRQ7`

The POD SOFTWARE is a simple board MC6821 which has a 40-PIN DIP which plugs across the 6809 target processor. By writing to the MC6821 (which connects to DIOBoard) and setting certain pins, it is possible to alter the processor state (ie, `RESET`, `HALT`) and perform `READ`/`WRITE` cycles (by emulating bus cycles asserting pins mapped to processors pins in correct sequence).

IF YOU RE-COMPILE THE SOURCE, USE A MEDIUM MEMORY MODEL!! AND TURN OFF WARNINGS.

### Note

This will be changed substantially as the project progresses.
