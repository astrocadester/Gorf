# TERSE Verb Glossary — Categorized for Gorf (Runtime vs. Development)

Source: *TERSE Standard Glossary, 9/21/81* (317 verbs). Every verb from the glossary appears exactly once below — either in a **Runtime** category (Part 1, usable by compiled Gorf game code running on the built-in TERSE interpreter) or in the **Excluded / Development-Only** section (Part 2, tools for writing/editing/compiling/debugging TERSE source that would not be present in — or callable by — the shipped game).

Four entries carry an uncertainty marker where the glossary does not by itself establish whether a shipped Gorf runtime exposes the word. The notes at the end identify each classification boundary.

---

# PART 1 — Runtime Verbs (usable in compiled Gorf TERSE code)

## 1. Stack Manipulation

*Runtime — reorders/duplicates/drops values on the parameter or return stack.*

| Verb | Description |
| :--- | :--- |
| `-DUP` | Duplicates the top stack value only if it is non-zero. |
| `2DROP` | Removes the top two 16-bit values from the parameter stack. |
| `2DUP` | Duplicates the top two 16-bit values on the parameter stack. |
| `2SWAP` | Swaps two pairs of 16-bit stack values. |
| `>R` | Moves the top parameter stack item onto the return stack. |
| `DROP` | Discards the top item from the parameter stack. |
| `DUP` | Duplicates the top value on the parameter stack. |
| `OVER` | Copies second item on stack to top (m,n→m,n,m). |
| `PICK` | Copies n-th deep stack item to top of stack. |
| `R>` | Pops value off return stack onto parameter stack. |
| `ROT` | Rotates top three stack values (m,n,p→n,p,m). |
| `RP@` | Returns current return stack pointer address. |
| `SP@` | Returns current parameter stack pointer address. |
| `SWAP` | Exchanges the top two stack values. |

---

## 2. Memory & Pointer Access

*Runtime — fetch/store words or bytes, bit-level access, block moves.*

| Verb | Description |
| :--- | :--- |
| `!` | Stores a 16-bit integer m at memory address p. |
| `+!` | Adds integer m to the 16-bit value stored at address p. |
| `+B!` | Adds the low-order 8 bits of m to the byte stored at address p. |
| `-!` | Subtracts integer m from the 16-bit value at address p. |
| `1+!` | Increments the 16-bit word at address p by 1. |
| `1+B!` | Increments the 8-bit byte at address p by 1. |
| `1-!` | Decrements the 16-bit word at address p by 1. |
| `1-B!` | Decrements the 8-bit byte at address p by 1. |
| `@` | Fetches the 16-bit word stored at memory address p. |
| `B!` | Stores the low-order 8 bits of m into byte-address p. |
| `B@` | Fetches the 8-bit byte stored at byte-address p. |
| `BIT!` | Sets bit position m at address n to value f (0 or 1). |
| `BIT-CALC` | Calculates bit mask and address for a specified bit position. |
| `BIT@` | Reads bit position m from address n. |
| `BMOVE` | Block-transfers n bytes from address p to address q. |
| `BONE` | Stores the byte value 1 at address p. Gorf implements this as `LD (HL),$01`. |
| `BZERO` | Stores an 8-bit byte value of 0 at address p. |
| `MOVE` | Moves n 16-bit word cells from address p to address q. |
| `ONE` | Stores a 16-bit word value of 1 at address p. |
| `S!` | Stores 16-bit word at address p (SWAP !). |
| `SB!` | Stores 8-bit byte at address p (SWAP B!). |
| `U!` | Stores value m into write protected location n and re-protects. |
| `UB!` | Stores byte value m into write protected location n and re-protects. |
| `ZERO` | Set the word at location p to 0. |

---

## 3. Arithmetic, Logic & Comparison

*Runtime — math, bitwise logic, and stack-value comparisons.*

| Verb | Description |
| :--- | :--- |
| `*` | Performs a 16-bit signed integer multiplication (p=m×n). |
| `+` | Performs a 16-bit integer addition (q=m+n). |
| `-` | Performs a 16-bit integer subtraction (q=m−n). |
| `->L` | Performs a double-precision logical shift right on m by p bits. |
| `/` | Performs 16-bit signed integer division, discarding the remainder. |
| `/MOD` | Performs 16-bit integer division, leaving quotient on top and remainder beneath. |
| `0` | Pushes a constant value of 0 onto the parameter stack. |
| `0<` | Returns true (1) if m is negative. |
| `0<=` | Returns true (1) if m is negative or zero. |
| `0<>` | Returns true (1) if m is non-zero. |
| `0=` | Returns true (1) if m is zero. |
| `0>` | Returns true (1) if m is positive and non-zero. |
| `0>=` | Returns true (1) if m is positive or zero. |
| `1` | Puts a constant value of 1 onto the parameter stack. |
| `1+` | Increments m by 1 (q=m+1). |
| `1-` | Decrements m by 1 (q=m−1). |
| `2*` | Multiplies m by 2 via a 1-bit arithmetic left shift. |
| `2+` | Increments m by 2. |
| `2-` | Decrements m by 2. |
| `2/` | Divides m by 2 via a 1-bit arithmetic right shift. |
| `<` | Returns true (1) if m<n. |
| `<-L` | Performs a double-precision logical shift left on m by n bits. |
| `<=` | Returns true (1) if m≤n. |
| `<>` | Returns true (1) if m≠n. |
| `=` | Returns true (1) if m=n. |
| `>` | Returns true (1) if m>n. |
| `>=` | Returns true (1) if m≥n. |
| `ABS` | Leaves the absolute value of a signed integer. |
| `AND` | Performs a bitwise logical AND of two 16-bit integers. |
| `COM` | Performs bitwise one's complement inversion on m. |
| `MAX` | Leaves greater of two 16-bit signed integers. |
| `MIN` | Leaves lesser of two 16-bit signed integers. |
| `MINUS` | Negates a signed integer via two's complement. |
| `MOD` | Leaves remainder of m/n division. |
| `NAND` | Bitwise logical AND followed by bitwise complement. |
| `NOR` | Bitwise logical OR followed by bitwise complement. |
| `NOT` | Logical invert; returns true (1) if 0, false (0) otherwise. |
| `OR` | Performs bitwise logical inclusive OR on two numbers. |
| `SWAB` | Exchange the high and low order bytes of value m. |
| `U<` | True if unsigned m<n. |
| `U<=` | True if unsigned m<n or m=n. |
| `U>` | True if unsigned m>n. |
| `U>=` | True if unsigned m>n or m=n. |
| `XOR` | Bitwise logical exclusive OR of m and n. |

---

## 4. Compiled Control Flow (Conditionals & Loops)

*Runtime — IF/CASE/DO-LOOP/BEGIN-family words as they appear *inside already-compiled* definitions. (Marked (C) or (C,X) in the original glossary — usable only inside a colon-definition, which is exactly how compiled Gorf code is structured.)*

| Verb | Description |
| :--- | :--- |
| `+LOOP` | Adds m to the loop index and terminates the loop when the limit is crossed. |
| `<FORK` | Executes the n-th verb in a jump list based on a stack index. |
| `BEGIN` | Marks the start of a BEGIN...WHILE...REPEAT or BEGIN...END loop. |
| `CASE` | Executes matching conditional branch based on stack value. |
| `DO` | Starts a counted loop structure terminated by LOOP or +LOOP. |
| `ELSE` | Marks false branch of IF...ELSE...THEN conditional. |
| `END` | Terminates a BEGIN...END loop based on stack boolean flag. |
| `FORK>` | Terminates multi-way branch sequence begun by <FORK. |
| `I` | Pushes loop index of innermost DO-loop. |
| `I+` | Adds m to loop index of innermost DO-loop. |
| `IF` | Conditional branch executing true branch if stack flag is non-zero. |
| `J` | Pushes loop index of next outer DO-loop. |
| `J+` | Adds m to loop index of next outer DO-loop. |
| `K` | Pushes loop index of second outer DO-loop. |
| `K+` | Adds m to loop index of second outer DO-loop. |
| `LEAVE` | Forces immediate exit from DO-loop on next iteration. |
| `LOOP` | Increments DO-loop index by 1 and checks against limit. |
| `REPEAT` | Unconditional loop jump back to BEGIN in BEGIN...WHILE...REPEAT. |
| `SKIP` | Skips execution of next word in colon definition. |
| `THEN` | Terminate an IF..ELSE..THEN conditional sequence. |
| `WHILE` | Test the value on the stack and if FALSE exit out of a BEGIN..WHILE..REPEAT loop. |

---

## 5. Stack Frames, Locals & Parameters

*Runtime — the <FRAME/LOCAL/PARAM family used by compiled definitions for local variables and passed parameters.*

| Verb | Description |
| :--- | :--- |
| `0<FRAME` | Sets up a stack frame with 0 local variables. |
| `0FRAME>` | Clears a 0-local stack frame. |
| `1<FRAME` | Sets up a stack frame with 1 local variable. |
| `1FRAME>` | Clears a 1-local stack frame. |
| `1LOCAL` | Pushes the address of the 1st local variable in the current frame. |
| `1LOCAL@` | Fetches the value of the 1st local variable in the current frame. |
| `1PARAM` | Pushes the address of the 1st parameter passed into the current frame. |
| `1PARAM@` | Fetches the value of the 1st parameter passed into the current frame. |
| `2<FRAME` | Sets up a stack frame with 2 local variables. |
| `2FRAME>` | Clears a 2-local stack frame. |
| `2LOCAL` | Pushes the address of the 2nd local variable. |
| `2LOCAL@` | Fetches the value of the 2nd local variable. |
| `2PARAM` | Pushes the address of the 2nd parameter. |
| `2PARAM@` | Fetches the value of the 2nd parameter. |
| `3<FRAME` | Sets up a stack frame with 3 local variables. |
| `3FRAME>` | Clears a 3-local stack frame. |
| `3LOCAL` | Pushes the address of the 3rd local variable. |
| `3LOCAL@` | Fetches the value of the 3rd local variable. |
| `3PARAM` | Pushes the address of the 3rd parameter. |
| `3PARAM@` | Fetches the value of the 3rd parameter. |
| `4<FRAME` | Sets up a stack frame with 4 local variables. |
| `4FRAME>` | Clears a 4-local stack frame. |
| `4LOCAL` | Pushes the address of the 4th local variable. |
| `4LOCAL@` | Fetches the value of the 4th local variable. |
| `4PARAM` | Pushes the address of the 4th parameter. |
| `4PARAM@` | Fetches the value of the 4th parameter. |
| `<FRAME` | Establishes a stack frame allocating n local variables. |
| `FRAME>` | Removes stack frame established by <FRAME. |
| `LOCAL` | Accesses local variable address within current stack frame. |
| `PARAM` | Pushes address of parameter passed into current stack frame. |
| `PARAM@` | Reads value of parameter passed into current stack frame. |

---

## 6. Character, String & Number I/O

*Runtime — basic text/number output and input primitives a running program would use to print scores, messages, etc., and read input.*

| Verb | Description |
| :--- | :--- |
| `.` | Prints the top stack value as a signed integer in the current number base. |
| `."` | Transmits a text string delimited by " to the output device. |
| `?` | Prints the 16-bit value stored at memory address p. |
| `?BELL` | Sends ?, BELL, CR, and LF characters to the output device. |
| `A"` | Compiles a text string and pushes its address onto the stack. |
| `ABORT` ⚠️ | Resets system stacks, outputs an error message, and aborts to the terminal. |
| `BASE` | System variable storing the active numeric conversion base. |
| `BELL` | Transmits an ASCII Bell character ($07) to the terminal. |
| `BKSP` | Transmits an ASCII Backspace character ($08) to the terminal. |
| `COUNT` | Unpacks string header at address p, leaving text address and length. |
| `CR` | Transmits Carriage Return and Linefeed characters to output. |
| `DECIMAL` | Sets numeric conversion base to Decimal (base 10). |
| `FLD` | Variable defining field width for printed numeric output. |
| `GET` | Variable holding address of primary input routine. |
| `GETC` | Fetches an ASCII character from the primary input device. |
| `H.` | Converts and prints number in Hexadecimal format. |
| `HEX` | Sets numeric conversion base to Hexadecimal (base 16). |
| `PAGE` | Sends clear screen or page feed command to output device. |
| `POLLC` | Polls input device for character (returns 0 if none ready). |
| `PUT` | Variable holding address of primary output character routine. |
| `PUTC` | Sends ASCII character n to primary output device. |
| `SPACE` | Outputs a single ASCII space character ($20). |
| `SPACES` | Outputs n ASCII space characters. |
| `STYPE` | Output a string at memory address p (COUNT TYPE). |
| `TYPE` | Send a string of n characters starting at byte address m to output. |

---

## 7. Low-Level Hardware I/O & Compiled Primitives

*Runtime — direct port I/O, interrupt control, and the primitives (LIT/DLIT) the compiler silently inserts before every literal, which therefore execute inside every compiled definition.*

| Verb | Description |
| :--- | :--- |
| `DLIT` | Primitive compiled before 32-bit double literals. |
| `INP` | Reads an 8-bit byte from hardware I/O port m. |
| `LIT` | Compiled primitive to push next 16-bit word literal onto stack. |
| `OUTP` | Writes 8-bit byte m to hardware output port n. |
| `XDI` | Disables hardware interrupts. |

---

# PART 2 — Excluded: Development-Only Verbs (not available in Gorf's runtime)

## A. Dictionary, Compiler & Vocabulary Words

*Excluded — words that create new dictionary entries (colon-definitions, VARIABLE, CONSTANT, ARRAY, tables, RAM allocation) or control the compiler/vocabulary state. These build the dictionary at development time; a shipped/compiled Gorf program doesn't call them.*

| Verb | Description |
| :--- | :--- |
| `'` | Leaves the code field address of the specified verb on the stack as a literal. |
| `,` | Stores m into the next available dictionary word and advances the dictionary pointer. |
| `,"` | Stores a string delimited by " into the dictionary with its length byte first. |
| `:` | Creates a new dictionary entry defining a high-level TERSE word. |
| `;` | Terminates a colon definition and resets STATE to immediate mode. |
| `<STK` | Marks the stack pointer at compilation time for balance validation. |
| `<STKD` | Executes <STK and sets base to DECIMAL. |
| `<STKH` | Executes <STK and sets base to HEX. |
| `A=` | Alias declaration for word arrays (ARRAY). |
| `ARRAY` | Allocates m 16-bit word elements in RAM or dictionary. |
| `B,` | Stores the low-order 8 bits of m as a byte into the next dictionary cell. |
| `BA=` | Alias declaration for byte arrays (BARRAY). |
| `BARRAY` | Allocates m 8-bit byte elements in RAM or dictionary. |
| `BR=` | Alias declaration for RAM allocation (BRAMALLOT). |
| `BRAMALLOT` | Allocates m contiguous bytes of RAM returning starting address. |
| `BTABLE` | Define the beginning of a table of bytes. |
| `BV=` | Creates a 0-initialized byte variable (BVARIABLE). |
| `BVARIABLE` | Allocates an 8-bit byte variable initialized to m. |
| `C=` | Alias declaration for constant values (CONSTANT). |
| `CCALC` | Converts a link field address to its corresponding code field address. |
| `CONSTANT` | Creates a named word that pushes a constant 16-bit value. |
| `CONTEXT` | System variable pointing to vocabulary searched first. |
| `CURRENT` | System variable pointing to vocabulary where new words are compiled. |
| `DATA` | Defines the start of a raw data field in memory. |
| `DEFINITIONS` | Sets CURRENT vocabulary equal to CONTEXT vocabulary. |
| `DP` | Variable holding dictionary allocation pointer. |
| `DP+!` | Advances dictionary pointer DP by n bytes. |
| `EXEC` ⚠️ | Executes or compiles word address q based on STATE. |
| `FCALC` | Returns code address of named verb. |
| `FIX` | Redefines existing verb so higher-level words use new version. |
| `FORGET` | Removes named word and all subsequent definitions from dictionary. |
| `HERE` | Returns address of next available memory cell in dictionary. |
| `IMMED` | Sets immediate bit on most recent definition to run at compile time. |
| `LAST` | System variable holding address of latest dictionary entry. |
| `LITERAL` | Compiles top stack value as a literal in current definition. |
| `NEWVOCAB` | Creates a new vocabulary and appends it to dictionary. |
| `R=` | Alias declaration for RAM allocation (RAMALLOT). |
| `RAMALLOT` | Allocates m contiguous 16-bit RAM words. |
| `RAMLEN` | Returns amount of variable space allocated since last RAMMARK. |
| `RAMMARK` | Saves current variable allocation pointer. |
| `REPLACE` | Redirects all calls from an old verb to a new definition. |
| `STATE` | A variable whose value is set to compile mode or immediate mode. |
| `STK>` | Checks top of stack to verify compiler alignment. |
| `TABLE` | Define the beginning of a table of words. |
| `TERSE` | Brings in the TERSE vocabulary, making all TERSE verbs accessible. |
| `V=` | Executes a 0 VARIABLE. |
| `VARHERE` | Returns the address of the next available variable location. |
| `VARIABLE` | Create a word which when executed pushes address of a 16-bit variable. |
| `VOCABULARY` | Create a new vocabulary named nnnn that will append to current vocabulary. |
| `VPTR` | Variable similar to DP that points to the next available variable location. |
| `XC?` | Returns false if cross-compiling, true otherwise. |
| `[` | Stop compilation; following words in colon definition are executed. |
| `[COMPILE]` | Forces the compilation of the immediate mode verb. |
| `]` | Start compilation; following words are compiled into dictionary. |
| `{` | Puts value of CONTEXT on return stack and sets context vocabulary to TERSE. |
| `}` | Restores the context vocabulary to what it was before {. |

---

## B. Assembler, Machine-Code & Emulator/Hardware-Debug Words

*Excluded — CODE/ASM machine-code definition tools, vocabulary/RAM bank-switching for the EDIT/DEBUG/ASM vocabularies, the ICEbox in-circuit emulator, and GAS-Terse-only hardware words (LED display, memory-map registers).*

| Verb | Description |
| :--- | :--- |
| `ASM` | Sets CONTEXT vocabulary pointer to the Assembler. |
| `CODE` | Begins inline Z80 machine assembly definition. |
| `ICE` | Enters hardware ICEbox monitor/debugger. |
| `LITES` | Writes value m to hardware LED diagnostic display. |
| `MAP` | Maps out EDIT/ASM vocabularies and maps in Screen RAM. |
| `MEMAP!` | Sets hardware memory mapping register to value m. |
| `MEMAP@` | Returns current hardware memory mapping register value. |
| `NEXT` | Returns control from machine code routine back to inner interpreter. |
| `PIMODE` | Returns ICE interrupt control port number. |
| `PROT` | Enables ICEbox hardware memory write protection below $4000. |
| `UNMAP` | Maps in EDIT, DEBUG, and ASM vocabularies, mapping out Screen RAM. |
| `UNPROT` | Makes it possible to write to locations below 4000h in colon definitions. |
| `UNX` | Executes the UNMAP verb and disables interrupts. |

---

## C. Editor, Debugger & REPL Utilities

*Excluded — interactive-session tools: entering EDIT/DEBUG vocabularies, dictionary/memory dumps, help listings, the OK prompt, abort-status reporting, and exiting to the monitor.*

| Verb | Description |
| :--- | :--- |
| `BASE?` | Prints the current number base minus 1 on the terminal. |
| `BYE` | Exits the TERSE system to the hardware monitor. |
| `DEBUG` | Switches context vocabulary to the interactive Debugger. |
| `DED` | Convenience shortcut executing DECIMAL and EDIT. |
| `DLIST` | Displays all words in context vocabulary with link and code addresses. |
| `DUMP` | Displays a 64-byte hexadecimal memory dump from address m. |
| `EDIT` | Sets context vocabulary to the Editor. |
| `HABORT` | Displays string at HERE and enters abort sequence. |
| `HELP` | Displays dictionary word listing from active context vocabulary. |
| `OK` | Outputs carriage return, linefeed, and OK prompt. |
| `WHERE` | Output information about system status after an error abort. |

---

## D. Interactive-Only Conditionals (Interpretation-Time)

*Excluded — the glossary explicitly documents these as slower, interpreter-only conditionals for use at the keyboard (not compiled into a definition).*

| Verb | Description |
| :--- | :--- |
| `<<` | Begins an interpreter-level conditional block. |
| `>>` | Terminates an interpreter-level conditional block begun by <<. |
| `IFEND` | Ends interpreter-level conditional block started by IFTRUE. |
| `IFTRUE` | Interpreter-level conditional construct. |
| `OTHERWISE` | False branch of interpreter-level IFTRUE conditional. |
| `[[` | Conditional loop structure usable during interpretation mode. |
| `]]` | Terminates a conditional interpretation sequence begun by [[. |

---

## E. Block Listing & Source/Printer Output Control

*Excluded — directory/listing of source blocks, hex/ASCII block dumps, and switching the listing output device (CRT/printer).*

| Verb | Description |
| :--- | :--- |
| `.BLK#` | Enables printing of each screen block number as it loads. |
| `.HOU` | Sets the system output device to the Houston Instruments printer driver. |
| `.LIST` | Directs output to the line printer device. |
| `.NBLK#` | Disables the .BLK# display option. |
| `.NLIST` | Directs output to the CRT terminal. |
| `.NSCR` | Disables the .SCR screen display option. |
| `.SCR` | Causes each screen block to be listed as it loads. |
| `DIR` | Displays block titles (lines starting with '(') between n and m. |
| `HEXLIST` | Displays block contents in ASCII and hexadecimal side-by-side. |
| `HEXSHOW` | Interactively browses block contents in hex and ASCII. |
| `LIST` | Displays full ASCII text content of block b. |
| `PRINTOUT` | Prints formatted directory and text for block range. |
| `SHOW` | Displays block text; pressing space bar advances to next block. |
| `SPACES?` | Unpacks string header and strips trailing spaces. |

---

## F. Disk & File System Operations

*Excluded — loading/saving/copying blocks and files, disk buffer management, and the system variables that track drive/track/sector/side/block position.*

| Verb | Description |
| :--- | :--- |
| `#DRVS` | Returns the address of the variable containing the number of disk drives in the system. |
| `+BLOCK` | Returns the sum of m plus the current block number being interpreted. |
| `-->` | Continues block interpretation at the next sequential block. |
| `;S` | Stops interpretation of the current symbolic source block. |
| `B:` | Converts block number m to drive B (q=m+308). |
| `BLK` | System variable holding the block number being processed. |
| `BLK/DISK` | Returns the total number of blocks per disk. |
| `BLK/SIDE` | Returns the number of blocks on a single disk side. |
| `BLKMOVE` | Copies n physical disk blocks from block p to block q. |
| `BLKSHIFT` | Shifts physical disk blocks m through n by offset q. |
| `BLOCK` | Loads disk block b into a memory buffer and returns its address. |
| `BPTR` | System variable holding a pointer to the active block buffer. |
| `BUFFER` | Obtain a core buffer for Block b, leaving the first buffer cell address. |
| `BUFFER1` | Returns memory address of disk buffer 1. |
| `BUFFER2` | Returns memory address of disk buffer 2. |
| `CONTINUED` | Transfers symbolic interpretation to block b. |
| `COPY` | Copies physical block m directly to block n. |
| `CYL` | System variable holding the active disk cylinder/track number. |
| `CYL/DISK` | Returns total number of cylinders/tracks per disk. |
| `DISKCOPY` | Clones all disk blocks from drive A to drive B. |
| `DRIVE` | System variable containing the active disk drive ID. |
| `E-C` | Marks all disk buffers empty without writing updated contents. |
| `EX` | Alias command for FLUSH. |
| `FILECOPY` | Copies blocks n through m from drive A to drive B. |
| `FILES` | Enables file-system mode instead of physical block mode. |
| `FLOAD` | Loads and executes named source file. |
| `FLUSH` | Writes all modified block buffers out to disk. |
| `FSLD` | Loads system dictionary image from named file. |
| `FSYSAVE` | Saves complete dictionary image into named file. |
| `LINE` | Returns word address for beginning of line m in current block. |
| `LINELOAD` | Starts interpreting source at line m of block b. |
| `LOAD` | Loads and interprets source block b. |
| `NOFILES` | Disables file mode and switches to physical disk block mode. |
| `SCR` | System variable holding block number currently being interpreted. |
| `SEC/TRK` | Returns number of sectors per disk track. |
| `SECTOR` | System variable holding selected disk sector. |
| `SIDE` | System variable holding selected disk side. |
| `SIDE/DISK` | Returns total number of disk sides. |
| `SYSAVE` | Save complete dictionary image starting at block m. |
| `SYSCOPY` | Copies blocks 1 through 44 from drive A to drive B. |
| `TRACK` | Returns address of variable holding active track number. |
| `UPDATE` | Flag the most recently referenced block as updated. |

---

## G. Disk/Printer/Terminal Hardware Port Constants

*Excluded — raw I/O port-number words for the development system's disk controller, printer, and terminal UART.*

| Verb | Description |
| :--- | :--- |
| `PDCMD` | Returns Disk Command Port number. |
| `PDDATA` | Returns Disk Data Port number. |
| `PDSECT` | Returns Disk Sector Select Port number. |
| `PDSEL` | Returns Disk Select Port number. |
| `PDSTAT` | Returns Disk Status Port number. |
| `PDTRK` | Returns Disk Track Select Port number. |
| `PLDATA` | Returns Printer Data Port number. |
| `PLSTAT` | Returns Printer Status Port number. |
| `PTDATA` ⚠️ | Returns Terminal Data Port number. |
| `PTSTAT` ⚠️ | Returns Terminal Status Port number. |

---

# Flagged for your review ⚠️

| Verb | Where I placed it | Why it's uncertain |
| :--- | :--- | :--- |
| `ABORT` | Runtime — Character, String & Number I/O | It resets the stacks, prints an error message, and *"returns control to the terminal."* That last part implies an interactive session. I kept it as runtime because stack-reset-plus-error-message is a completely standard thing for compiled Forth-family code to call on a fatal error, but the "return to terminal" phrasing may mean it only makes sense in the development environment. |
| `EXEC` | Excluded — Dictionary, Compiler & Vocabulary Words | Its behavior branches on the `STATE` variable (compile vs. interpret), which is why the glossary groups it with compiler machinery. But mechanically it can also act as a plain "jump to the address on the stack" — which is exactly the kind of indirect-call primitive a game might use for jump tables (e.g., enemy AI state dispatch). If Gorf's code uses function-pointer dispatch, this one likely belongs in Runtime instead. |
| `PTDATA` / `PTSTAT` | Excluded — Hardware Port Constants | Labeled "Terminal Data/Status Port." I grouped these with the disk and printer port words since they read as development-terminal (UART) ports, distinct from whatever I/O hardware the Gorf cabinet itself uses for controls/display. If Gorf's actual input hardware is wired through this same UART, these should move to Runtime (Low-Level Hardware I/O). |
