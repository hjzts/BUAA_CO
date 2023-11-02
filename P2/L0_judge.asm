.macro scanInt(%d)
    li $v0, 5
    syscall
    move %d, $v0
.end_macro
.macro scanChar(%c)
    li $v0, 12
    syscall
    move %c, $v0
.end_macro
.macro print(%d)
	li $v0, 1
	move $a0, %d
	syscall
.end_macro
.macro end
	li $v0, 10
	syscall
.end_macro
.data
	str:  .space 20
.text
    scanInt($s0)
	li $t0, 0
    for_1_loop:
        beq $t0, $s0, for_1_end
        scanChar($t1)
        sb  $t1, str($t0)
        addi $t0, $t0, 1
        j for_1_loop
	for_1_end:
	
	li   $t0, 0
	subi $t1, $s0, 1
	li   $t2, 1 # flag
	for_2_loop:
	    bge $t0, $t1, for_2_end
	    lb  $t3, str($t0)
	    lb  $t4, str($t1)
	    beq $t3, $t4, if_else
	         li $t2, 0
	         j for_2_end
	    if_else:
	    addi $t0, $t0, 1
	    subi $t1, $t1, 1
	    j for_2_loop
	for_2_end:
	print($t2)
	end
