.macro ASSERT_A_EQUALS
  cp \1
  jp nz,exit_with_failure
  nop
.endm

.macro EVALUATE_DICE
  jp +
    dice\@:
      .db \2 \3 \4 \5 \6
  +:
  ld hl,dice\@
  call \1
.endm

.include "stdlib.asm"
.include "yahtzee.asm"
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
    ld a,16
    ld b,3
    ld hl,yellow_red_green
    call load_cram
    jp +
      yellow_red_green:
      .db $2f $17 $1c
      .equ YELLOW 0
      .equ RED 1
      .equ GREEN 2
    +:
    ; -------------------------------------------------------------------------
    EVALUATE_DICE score_three_of_a_kind 1 1 1 2 2
    ASSERT_A_EQUALS 7

    EVALUATE_DICE score_three_of_a_kind 1 1 1 3 4
    ASSERT_A_EQUALS 10

    EVALUATE_DICE score_three_of_a_kind 1 2 3 4 5
    ASSERT_A_EQUALS 0

    EVALUATE_DICE score_three_of_a_kind 5 3 5 5 2
    ASSERT_A_EQUALS 20

    EVALUATE_DICE score_three_of_a_kind 1 1 6 6 6
    ASSERT_A_EQUALS 20

    EVALUATE_DICE score_three_of_a_kind 6 1 6 6 6
    ASSERT_A_EQUALS 25


    jp exit_with_succes
    ; -------------------------------------------------------------------------
    ei
    halt
    halt
  jp main_loop

  exit_with_failure:
    ld a,RED
    call set_border_color
  -:
    nop
  jp -

  exit_with_succes:
    ld a,GREEN
    call set_border_color
  -:
    nop
  jp -


  main_loop:
    nop
  jp main_loop
.ends
