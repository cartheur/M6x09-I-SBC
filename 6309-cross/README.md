## An Assembler for the 6x09 CPU

A cross-assembler for hosts running Debian Linux. The assembler was developed and tested on a an AMD x64 with debian 11. Using no specific options of the host system, it should run on any computer with a GNU C-compiler

This assembler is a Cross-Assembler, it is run on a host system, but produces code for target machines running a Motorola 6809 or a Hitachi 6309 CPU. These were widely used on the Thomson MO and TO series, Dragon 32/64, Commodore Super PET, and Tandy CoCo.


### Compiling

If the compiler is `gcc`, compile with:

`gcc -o bs9 bs9.c`

If GNU `make` and `su` is installed, use these lines to install the binary to `/usr/local/bin`:

`make`
`su`
`make install`

### Running

If a source code file is named `hello.as9`, run the assembler with:

`bs9 hello`

It will read `hello.as9` as input file and write the listing file with cross reference `hello.lst`. Binary output is controlled within the source file by means
of the pseudo op `STORE`. See below for syntax.

### Case sensitivity

For clarity - mnemonics and pseudo opcodes are insensitive to case:

* `LDA` `lda` `Lda` are all equivalent (Load Accumulator `A`)
* `FCB` `fcb` `Fcb` are all equivalent (define byte data)
* `Label` and named constants are case sensitive by default. The option `-i` switches off the case sensitivity for symbols. Also the pseudo op `CASE +/-` may be used to switch sensitivity.
* `LDA #Cr ` and `LDA #CR`  use different constants.
* `JMP Lab_10` and `JMP LAB_10`  jump to different targets.

### Directives

* `CPU = 6809`    |  allow code for 6809 only
* `CPU = 6309`    |  allow full 6309 instruction set (default)

### Labels and Constants

* `LABEL   LDX  #Value`    |  define `LABEL` for current `PC`
* `TXTPTR  = $21b8`        |  define constant `TXTPTR`
* `OLDPTR  EQU $21ba`      |  define constant `OLDPTR`
* `CURRENT SET 5`          |  define variable `CURRENT`

### Modules (Subroutines)

The pseudo instructions

```
MODULE
...
ENDMOD
```
or the aliases
```
SUBROUTINE
...
ENDSUB
```
define a namespace for local variables. Variables starting with a `.` (dot) have a scope limited to code between `MODULE` and `ENDMOD`. Example:

```
MODULE Delay
.loop  LEAX -1,X
       BNE  .loop
       RTS
ENDMOD

MODULE Strout
.loop  LDA  ,X+
       BEQ  .ret
       JSR  Chrout
       BRA  .loop
.ret   RTS
ENDMOD
```
There is no conflict in using the label `.loop` twice, because they are used in separate modules. Internally the assembler generates the names:

```
Delay.loop
Strout.loop
Strout.ret
```
for these labels.

### Assign addresses to symbols

```
LABEL   ENUM value             define label with value
LABEL   ENUM                   use last ENUM value + 1

& = value                      set start value for BSS segment
TXTPTR  BSS 2                  assign TXTPTR = &, & += 2
CURSOR  BSS 1                  assign CURSOR = &, & += 1
```

Labels and constants can have only one value. Variables, which get their value assigned with `SET`, may change their values. Labels that are defined by their current position must start at the first column.

### Examples of pseudo opcodes (directives):

```
ORG  $E000                                set program counter
STORE START,$2000,"basic.rom"             write binary image file "basic.rom"
STORE START,$2000,"basic.rom",bin,1       write binary image, headed by load address
STORE START,$2000,"basic.s19",s19         write binary file in Motorola S-Record format
STORE START,$2000,"basic.s19",s19,Main    write binary and provide execution start address
LOAD  START,"image.bin"                   load binary file to START and following addresses
LOAD  "image.bin"                         load binary file starting at current address
LIST +                                    switch on  assembler listing
LIST -                                    switch off assembler listing
BITS . . * . * . . .                      stores a byte from 8 bit symbols
BYTE $20,"Example",0                      stores a series of byte data
WORD LAB_10, WriteTape,$0200              stores a series of word data
LONG 1000000                              stores 32 bit long data
REAL  3.1415926                           stores a 32 bit real
FILL  N ($EA)                             fill memory with N bytes containing $EA
FILL  $A000 - * (0)                       fill memory from pc(*) upto $9FFF
INCLUDE "filename"                        includes specified file
END                                       stops assembly
CASE -                                    symbols are not case sensitive
SIZE                                      print code size info
TXTTAB BSS 2                              define TXTTAB and increase address pointer by 2
  * = $E000                               set program counter
  & = $033A                               set BSS address pointer
ORG   $E000                               set program counter
SETDP $20                                 assume content of direct page register
FCB   $20,"Example",0                     stores a series of byte data
FDB   LAB_10, WriteTape,$0200             stores a series of word data
FCC   "Example\n"                         store ASCII string
```

### Examples of Operands

```
    6                      = decimal constant
 $A12                      = hex constant
MURX                       = label or constant
"hello\r"                  = ASCII string with CR at end
Table_Offset + 2 * [LEN-1] = address
```

### Constants

```
'A'         char constant
%1111 0000  bytet constant
?           length of BYTE data line
$ffd2       hex constant
```

### Unary  operators in address calculations

```
<    low byte
>    extended address (override DP mode)
(    parenthesis
)    parenthesis
+    positive sign
-    negative sign
!    logical NOT
~    bitwise NOT
```

### Binary operators in address calculations

```
+     addition
-     subtraction
*     multiplication or program counter (context sensitive)
/     division
&     bitwise and
|     bitwise or
^     bitwise xor
```

### Relational operators

```
==    equal
!=    not equal
>     greater than
<     less than
>=    greater than or equal to
<=    less than or equal to
<<    left shift
>>    right shift
&&    and
||    or
```

Relational operators return the integer 0 (false) or 1 (true).

### User macros

Example:

```
MACRO PrintString(Message)
   LDX   #Message    ; address of message
   LDB   #?Message   ; length of message
   JMP   [SWI1PT]    ; jump through vector
ENDM
```

defines a `MACRO` for loading a 16-bit word into `X` and `Y`.

Call:

```
OK     .BYTE "\nOK\n"

PrintString(OK)
```

Generated Code:

```
   LDX #OK
   LDB #4
   JMP   [SWI1PT]
```

Macros accept up to 10 parameters and may have any length.

### Conditional assembly

Example: Assemble first part if `C64` has a non zero value

```
if MO5
   STA $D000
else
   STA $9000
endif
```

Example: Assemble first part if `MO5` is defined (`$0000 `- `$ffff`), undefined symbols are set to `UNDEF` (`$00ff0000`)

```
ifdef MO5
   STA $D000
else
   STA $9000
endif
```

assembles the first statement if `MO5` is not zero and the second if zero.

Example: Assemble if symbol is undefined

```
ifndef TO9
   STA $D000 ; Code for MO5 and TO8
endif
```

Another example:

```
if MO5 | TO9          ; true if either MO5 or TO9 is true (not zero)
   LDA #MASK
if MO5
   STA ICR_REG
else
   STA TO9_ICR_REG
endif                   ; finishes inner if
endif                   ; finishes outer if
```

Example: check and force error

```
if (MAXLEN & $ff00)
   #error This code is 8 bit only, MAXLEN too large!
endif
```

The maximum nesting depth is 10.

### Listing

The program listings lists the original source code preceded by the generated code in form of hexadecimal bigendian word or byte values. For example:

```
  27 9ff6   b6    fe30         LDA     IO_SDCARD
  28 9ff9 1034 8e              ANDR    A,E       ; test IO_INCD#
  29 9ffc   27      06         BEQ     +
  30 9ffe   8e    a096         LDX     #Msg_NOT  ; " not"
  ^  ^    ^    ^  ^            ^       ^         ^
  |  |    |    |  |            |       |         \- Comment
  |  |    |    |  |            |       \----------- Operand
  |  |    |    |  |            \------------------- Mnemonic
  |  |    |    |  \----- Address/Value Operand (Word or Byte)
  |  |    |    \-------- Postbyte (Byte)
  |  |    \------------- Opcode (Word or Byte)
  |  \------------------ Program address
  \--------------------- Line number
```
