# Applications

This directory is the home for software that runs on the M6x09-I itself.

Each application should contain:

* editable 6809/6309 source;
* a Linux `Makefile` using `../../crosscompiler/bs9` (or a documented installed `bs9`);
* generated `.s19` and listing files excluded from version control unless they are a named release;
* a short README describing the load address, entry point, required hardware, and RAM-to-ROM promotion criteria.

The first applications should be small hardware-facing experiments: GPIO, keypad/display, ACIA, tick/IRQ, and then combinations that become useful standalone ROM programs.
