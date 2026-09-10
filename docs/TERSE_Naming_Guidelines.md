# TERSE Symbol and Naming Guidelines

These rules keep the Gorf reconstruction readable without overstating what has been proven. zmac v1.3 treats symbols case-insensitively, so prefixes and spelling—not case alone—carry semantic meaning.

## Evidence levels

Use a canonical TERSE name when at least one of these conditions holds:

1. the surviving Gorf TERSE source names the word at that address;
2. the implementation and calling contract uniquely match a documented standard verb; or
3. an independently reconstructed DNA implementation matches both behavior and role.

Use a descriptive game-specific label when behavior is understood but the historical name is not established. Retain a neutral address label when neither identity nor behavior is secure. Do not convert a plausible interpretation into a canonical name merely because it resembles Forth or another DNA game.

## Symbol classes

| Class | Form | Examples |
|---|---|---|
| Native or compiled TERSE word | leading underscore, canonical spelling | `_DROP`, `_LIT`, `_BARRAY` |
| Punctuation-bearing TERSE word | readable identifier suffix | `_Bat` for `B@`, `_Bplus` for `B+` |
| Compiled colon-definition opcode | explicit runtime term | `TERSE_COLON_OPCODE` |
| Inner-interpreter continuation encoding | explicit runtime term | `TERSE_NEXT_OPCODE` |
| Native support routine | lowercase descriptive name | `clear1k`, `snap_code` |
| Game entry point, table, or variable | descriptive uppercase | `COLDSTRT`, `PLAYER_SHOT_SOUND` |
| Routine-local branch | lowercase stem plus number or role | `max1`, `loop_end` |

`TERSE_COLON_OPCODE` is byte `$CF`, the Z80 encoding of `RST $08`. It must not be labeled `ENTER`: standard TERSE `ENTER` is a dictionary/compiler operation, while Gorf's byte is a compiled call into the resident colon-entry runtime at `$0008`.

`TERSE_NEXT_OPCODE` is word `$E9FD`, which emits bytes `FD E9` (`JP (IY)`). It is an assembler encoding used at the end of native primitives, not a claim that a separately callable resident verb named `NEXT` occupies that address.

## Source transcription and reconstruction

Historical block text remains in comments with its original TERSE spelling. Labels in executable assembly express the compiled runtime identity. When a source word compiles to an internal primitive with a different role, document both rather than forcing one label to serve as compiler vocabulary and runtime entry point.

Keep labels concise when that improves listings, but do not impose an arbitrary length limit at the expense of a precise hardware or runtime name. Comments should state established behavior directly and isolate unresolved interpretation in development notes, not in release-facing executable documentation.
