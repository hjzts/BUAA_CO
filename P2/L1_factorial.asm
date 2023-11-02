.macro scanInt(%d)
	li   $v0, 5
	syscall
	move %d, $v0
.end_macro

.macro printInt(%d)
	li   $v0, 1
	move $a0, %d
	syscall
.end_macro

.macro end
	li $v0, 10
	syscall
.end_macro
.data
	array: .space 4000
.text
	scanInt($s0)
	bne $s0, $zero, if_1_else
		addi $t1, $zero, 1
		printInt($t1)
		end
	if_1_else:
	li $t1, 1
	sw $t1, array
	li $t0, 1	# i
	li $s3, 1	# hi
	for_1_loop:
		bgt $t0, $s0, for_1_end
		li $s1, 0	# carry
		
		li $t1, 0	# j 
		for_2_loop:
			bgt $t1, $s3, for_2_end
			li  $s2, 0 	# temp
			sll $t2, $t1, 2
			lw  $s2, array($t2)
			mul $s2, $s2, $t0
			add $s2, $s2, $s1
			li  $t3, 10
			div $s2, $t3
			mfhi $t4
			sw   $t4, array($t2)
			mflo $s1
			addi $t1, $t1, 1
			beq  $s1, $zero, if_2_else
			bne  $t1, $s3, if_2_else
				addi $s3, $s3, 1
			if_2_else:
			j for_2_loop
		for_2_end:
		
		addi $t0, $t0, 1
		j for_1_loop
	for_1_end:
	
	subi $t0, $s3, 1

	for_3_loop:
		blt $t0, $zero, for_3_end
		
		sll $t1, $t0, 2
		lw  $t2, array($t1)
		printInt($t2)
		subi $t0, $t0, 1 
		j for_3_loop
	for_3_end:
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
