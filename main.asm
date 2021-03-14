.include "sms_constants.asm"
.include "stdlib.asm"
.memorymap
  defaultslot 0
  slotsize $4000
  slot 0 $0000
  slot 1 $4000
  slot 2 $8000
  slotsize $2000
  slot 3 $c000
.endme
.rombankmap ; 128K rom
  bankstotal 8
  banksize $4000
  banks 8
.endro
.org 0
.bank 0 slot 0

.section "Boot" force
  boot:
    di
    im 1
    FILL_MEMORY $00
    ld sp,$dff0
    ld de,$fffc
    ld hl,initial_memory_control_register_values
    ld bc,4
    ldir
    call clear_vram
  jp init
  
  initial_memory_control_register_values:
    .db $00,$00,$01,$02
.ends

.org $0038
.section "!VDP interrupt" force
  push af
    in a,CONTROL_PORT
  pop af
  ei
  reti
.ends

.org $0066
.section "!Pause interrupt" force
  nop
  retn
.ends

.section "main" free
  init:
  ; Run this function once (on game load/reset). 
    ei
    halt
    halt
  jp main_loop

  main_loop:
    nop
  jp main_loop
.ends
