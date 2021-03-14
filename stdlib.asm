; -----------------------------------------------------------------------------
; HARDWARE DEFINITIONS
; Assumes hardware is initialized to default values
; -----------------------------------------------------------------------------
; Video (VDP)
.equ SAT_Y_START $3f00
.equ SAT_XC_START SAT_Y_START+64+64
.equ SPRITE_TERMINATOR $d0
.equ HARDWARE_SPRITES 64
;
.equ NAME_TABLE_START $3800
.equ VISIBLE_NAME_TABLE_SIZE 2*32*24
.equ FULL_NAME_TABLE_SIZE 2*32*28
.equ SPRITE_BANK_START $0000
.equ BACKGROUND_BANK_START $2000
.equ CHARACTER_SIZE 32
;
.equ FIRST_LINE_OF_VBLANK 192
.equ INTERRUPT_TYPE_BIT 7
;
.equ V_COUNTER_PORT $7e
.equ CONTROL_PORT $BF
.equ DATA_PORT $BE
.equ VRAM_WRITE_COMMAND %01000000
.equ VRAM_READ_COMMAND %00000000
.equ REGISTER_WRITE_COMMAND %10000000
.equ CRAM_WRITE_COMMAND %11000000
.equ VRAM_SIZE $4000                  ; 16K
;
.equ HORIZONTAL_SCROLL_REGISTER 8
.equ VERTICAL_SCROLL_REGISTER 9
.equ RASTER_INTERRUPT_REGISTER 10
; 
.equ CRT_LEFT_BORDER 0
.equ CRT_RIGHT_BORDER 255
.equ CRT_TOP_BORDER 0
.equ CRT_BOTTOM_BORDER 191
;
.equ INVISIBLE_AREA_TOP_BORDER 192
.equ INVISIBLE_AREA_BOTTOM_BORDER 224

; Sound (PSG)
.equ PSG_PORT $7f

; Control
.equ INPUT_PORT_1 $dc
.equ INPUT_PORT_2 $dd

; Memory
.equ RAM_START $c000
.equ SET_EXTRAM_BIT %00001000
.equ RESET_EXTRAM_BIT %11110111
.equ EXTRAM_START $8000
.equ EXTRAM_SIZE $4000
.equ SLOT_2_CONTROL $ffff
.equ BANK_CONTROL $fffc

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

  set_border_color:
    ; Entry: A = Palette index.
    out (CONTROL_PORT),a
    ld a,REGISTER_WRITE_COMMAND
    or 7 ; Border color register.
    out (CONTROL_PORT),a
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