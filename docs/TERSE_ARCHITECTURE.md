# Gorf TERSE Runtime Architecture

Gorf's game program is compiled as direct-threaded TERSE embedded in a Z80 address space. The runtime is small, but it is not a generic bytecode decoder: a thread is a sequence of native entry-point addresses, and the inner interpreter jumps directly to each address.

## Execution registers

| Register | Runtime role |
|---|---|
| BC | Threaded instruction pointer; addresses the next 16-bit execution token or inline operand |
| SP | 16-bit parameter stack; also supports balanced native Z80 calls |
| IX | Downward-growing control stack for colon returns and loop state |
| IY | Fixed address of `DSPATCH` |
| HL, DE, AF | Primitive working registers |

Keeping colon returns on IX separates threaded nesting from values on SP. Native helpers may use ordinary Z80 `CALL` and `RET` provided they restore SP before returning to threaded execution.

## Direct-threaded dispatch

`DSPATCH` reads the next little-endian address from the thread, advances BC, and transfers control to the selected primitive or colon definition:

```z80
DSPATCH:    ld      a,(bc)
            inc     bc
            ld      l,a
            ld      a,(bc)
            inc     bc
            ld      h,a
            jp      (hl)
```

Native primitives resume this cycle with bytes `FD E9`, `JP (IY)`. The source emits those bytes as `DW TERSE_NEXT_OPCODE`, where `TERSE_NEXT_OPCODE EQU $E9FD` accounts for the Z80's little-endian storage.

## Colon calls and returns

A compiled colon definition begins with byte `$CF`, the opcode `RST $08`. The address immediately after that byte is the nested thread. Z80 `RST` pushes that address on SP and jumps to `$0008`.

At `TERSE_COLON_ENTRY`, the runtime saves the caller's BC on IX, pops the nested thread address into BC, and dispatches its first token. `_RETURN`, compiled by TERSE `;`, reverses the operation:

```z80
TERSE_COLON_ENTRY:
            dec     ix
            ld      (ix+0),b
            dec     ix
            ld      (ix+0),c
            pop     bc
            jp      (iy)

_RETURN:    ld      c,(ix+0)
            inc     ix
            ld      b,(ix+0)
            inc     ix
            jp      (iy)
```

The `$CF` byte is therefore a compiled colon-call mechanism. It is not the standard TERSE dictionary word `ENTER`.

## Inline operands

Some execution tokens consume data immediately following their address in the thread. BC always advances past that payload before dispatch continues.

| Primitive | Inline data | Stack result |
|---|---:|---|
| `_LIT` | 16-bit word | pushes the word |
| `_LITbyte` | 8-bit byte | pushes its zero-extended value |
| `_BARRAY` | 16-bit base address | consumes index; pushes `base + index` |
| `_ARRAY` | 16-bit base address | consumes index; pushes `base + 2*index` |

`_LITbyte` is a compact Gorf runtime primitive not listed in the standard 1981 glossary. Its behavior is established by both implementation and call sites.

## Example: a compiled definition

The source transcription gives `XY` as `100 * SWAP 40 * SWAP ;`. Its compiled body makes the runtime format explicit:

```z80
_XY:        DB      TERSE_COLON_OPCODE
            DW      _LIT
            DW      $0100
            DW      _star
            DW      _SWAP
            DW      _LITbyte
            DB      $40
            DW      _star
            DW      _SWAP
            DW      _RETURN
```

Addresses following `_LIT` and `_LITbyte` are operands, not execution tokens. Every other word-sized item in this body is dispatched directly as a native address.

## Compiled words, native primitives, and data

Three forms coexist in the ROM:

- A native primitive is Z80 code entered through an execution token and normally ending in `JP (IY)`.
- A colon definition begins with `RST $08` and contains a thread of execution tokens plus any inline operands.
- Tables, graphics, music scores, and speech records are data and must not be decoded as threaded code merely because a word resembles a valid address.

The surviving TERSE block listings provide strong boundaries and names, but the assembled behavior remains the authority for stack effects, operand widths, and control flow.
