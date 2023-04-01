# $t0 = a, $t1 = b

main:   beq $t1, $t2, if
        addi $t2, $t2, -1
        j end
if:     addi $t1, $t1, 1
end:    add $t2, $t2, $t1
        jr $ra
