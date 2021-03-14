.macro FILL_MEMORY args value
;  Fills work RAM ($C000 to $DFF0) with the specified value.
  ld    hl, $C000
  ld    de, $C001
  ld    bc, $DFF0
  ld    (hl), value
  ldir
.endm

.macro RESTORE_REGISTERS
  ; Restore all registers, except IX and IY
  pop iy
  pop ix
  pop hl
  pop de
  pop bc
  pop af
.endm

.macro SAVE_REGISTERS
  ; Save all registers, except IX and IY
  push af
  push bc
  push de
  push hl
  push ix
  push iy
.endm

.section "VDP routines" free
  clear_vram:
    ; Write 00 to all vram addresses.
    xor a
    out (CONTROL_PORT),a
    or VRAM_WRITE_COMMAND
    out (CONTROL_PORT),a
    ld bc,VRAM_SIZE
    -:
      xor a
      out (DATA_PORT),a
      dec bc
      ld a,b
      or c
    jp nz,-
  ret

  load_cram:
    ; Consecutively load a number of color values into color ram (CRAM), given a
    ; destination color to write the first value.
    ; Entry: A = Destination color in color ram (0-31)
    ;        B = Number of color values to load
    ;        HL = Base address of source data (color values are bytes = SMS)
    ; Assumes blanked display and interrupts off.
    out (CONTROL_PORT),a
    ld a,CRAM_WRITE_COMMAND
    out (CONTROL_PORT),a
    -:
      ld a,(hl)
      out (DATA_PORT),a
      inc hl
    djnz -
  ret

  load_vram:
    ; Load a number of bytes from a source address into vram.
    ; Entry: BC = Number of bytes to load
    ;        DE = Destination address in vram
    ;        HL = Source address
    ld a,e
    out (CONTROL_PORT),a
    ld a,d
    or VRAM_WRITE_COMMAND
    out (CONTROL_PORT),a
    -:
      ld a,(hl)
      out (DATA_PORT),a
      inc hl
      dec bc
      ld a,c
      or b
    jp nz,-
  ret

  setup_vram_write:
    ; Entry: HL = Address in VRAM.
    ld a,l
    out (CONTROL_PORT),a
    ld a,h
    or VRAM_WRITE_COMMAND
    out (CONTROL_PORT),a
  ret
.ends