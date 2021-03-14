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
    ld c,1
    ld b,5
    -:
      push bc
        call count_dice
        cp 3
        jp z, return_true
      pop bc
      inc c
      pop hl
      push hl
    djnz -

    return_false:
      pop hl
      ld a,FALSE
    ret

    return_true:
      pop bc
      pop hl
      ld a,TRUE
    ret
  ret

  count_dice:
    ld b,5
    ld d,0
    -:
      ld a,(hl)
      cp c
      jp nz, +
        inc d
      +:
      inc hl
    djnz -
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