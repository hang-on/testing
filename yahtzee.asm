.equ TRUE 1
.equ FALSE 0

.section "Yahtzee library" free
  score_three_of_a_kind:
    call have_three_of_a_kind
    cp TRUE
    jp z,return_sum
  return_zero:
    ld a,0
    ret
  return_sum:
    call sum_of_dice
  ret

  have_three_of_a_kind:
    push hl
    pop ix
    ld c,1
    ld b,6
    -:
      push bc
        call count_dice
        cp 3
        jp z, return_true
      pop bc
      inc c
    djnz -

    return_false:
      ld a,FALSE
    ret

    return_true:
      pop bc
      ld a,TRUE
    ret
  ret

  count_dice:
    ld d,0
    ld a,(ix+0)
    cp c
    jp nz, +
      inc d
    +:
    ld a,(ix+1)
    cp c
    jp nz, +
      inc d
    +:
    ld a,(ix+2)
    cp c
    jp nz, +
      inc d
    +:
    ld a,(ix+3)
    cp c
    jp nz, +
      inc d
    +:
    ld a,(ix+4)
    cp c
    jp nz, +
      inc d
    +:
    ld a,d
  ret

  sum_of_dice:
    ld b,5
    ld a,0
    -:
      add a,(hl)
      inc hl
    djnz -
  ret
.ends