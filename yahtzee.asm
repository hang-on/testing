.section "Yahtzee library" free
  score_three_of_a_kind:
    call sum_of_dice

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