.macro scanInt(%d)
	li $v0, 5
	syscall
	move %d, $v0
.end_macro 

.macro printInt(%d)
	li $v0, 1
	move $a0, %d
	syscall
.end_macro

.macro push(%des)
	sw %des, ($sp)
	subi $sp, $sp, 4
.end_macro

.macro pop(%src)
	addi $sp, $sp, 4
	lw  %src, ($sp)
.end_macro

.macro printEnter
	li $v0, 11
	la $a0, '\n'
	syscall
.end_macro

.macro end
	li $v0, 10
	syscall
.end_macro

.data
	array:  .space 4000
.text
	scanInt($s0)	# m
	li $t0, 0
	for_1_loop:
		bge $t0, $s0, for_1_end
		sll $t1, $t0, 2
		scanInt(	$t2)
		sw  $t2, array($t1)
		addi $t0, $t0, 1
		j for_1_loop
		nop
	for_1_end:
	scanInt($s1) # n
	li $t0, 0
	for_2_loop:
		bge $t0, $s1, for_2_end
		
		scanInt($a1)
		li    $a2, 0			# res
		move  $t2, $zero		# l
		subi  $t3, $s0, 1	# r
		jal bSearch
		printInt($a2)
		printEnter
		
		addi $t0,$t0,1
		j for_2_loop
		nop
	for_2_end:
	end
	
bSearch:
	push($ra)
	push($t0)	# l
	push($t1)	# r
	push($t2)	# l
	push($t3)	# r
	
	move $t0, $t2
	move $t1, $t3
	
	add  $t4, $t0, $t1
	srl  $t4, $t4, 1		# mid
	sll  $t6, $t4, 2
	lw   $t5, array($t6)
	
	bgt  $t0, $t1, if_0_else
	 
	# equ  array[mid] == target
	bne $t5, $a1, if_1_else_if_1
	nop
		li $a2, 1
		jal bSearchEnd
		nop
	# left, ($t5)array[mid] > target 
	if_1_else_if_1:
	blt $t5, $a1, if_1_else
	nop
		subi $t3, $t4, 1
		jal bSearch
		nop
	# right, ($t5)array[mid] < targe 
	if_1_else:
		addi $t2, $t4, 1
		jal bSearch
	
	if_0_else:
		jal bSearchEnd
		
bSearchEnd:
	pop($t3)
	pop($t2)
	pop($t1)
	pop($t0)
	pop($ra)
	jr $ra














