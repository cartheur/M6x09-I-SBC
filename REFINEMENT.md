# Linux-First Direction

The M6x09-I is a standalone 6809 computer. Linux is its development and operations host, not a substitute for the target.

## Supported path

1. Write an application in `applications/`.
2. Assemble it on Linux with `crosscompiler/bs9`.
3. Use `terminal/m6x09-terminal.tcl` through the EM1016 USB-to-RS-232 adapter to load Motorola S-records into RAM.
4. Exercise the application on the physical SBC.
5. Promote a validated image to an EPROM release and record its checksum, source revision, and programming procedure.

## Boundaries

* The Linux host owns source editing, assembling, serial transfer, logging, and ROM programming.
* The SBC owns target execution, I/O, timing, and the software placed in RAM or ROM.
* `bs9` is the current in-tree Linux assembler.
* The old DOS `cc09` compiler and duplicated tool trees are retired. Git history preserves them; active documentation and builds must not depend on them.

## Near-term work

* Define a small ROM-monitor contract: prompt, S-record loader, RAM execution command, and serial parameters.
* Add applications with a `Makefile` that emits `.s19`, listing, and ROM image artifacts.
* Add a release manifest beside every burnable ROM image.
* Use the [ideal project](https://github.com/cartheur/ideal) as an application-design reference: begin with concrete, observable target experiments and grow functionality through tested interactions.
