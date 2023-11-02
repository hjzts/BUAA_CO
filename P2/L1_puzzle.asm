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

.macro push(%src)
	sw %src,  ($sp)
	subi $sp, $sp, 4
.end_macro

.macro pop(%des)
	addi $sp, $sp, 4
	lw %des, ($sp)
.end_macro

.macro getIndex(%ans, %i, %j)
	mul %ans, %i, 8
	add %ans, %ans, %j
	sll %ans, %ans, 2
.end_macro

.macro end
	li $v0, 10
	syscall
.end_macro
.data
	myArray: .space  400 # [10][10]
.text
	scanInt($s0)	# $s0 = n
	scanInt($s1)	# $s1 = m
	
	li $t0,1
	for_1_loop:
		bgt $t0, $s0, for_1_end
		
		li $t1, 1
		for_2_loop:
			bgt $t1, $s1, for_2_end
			
			getIndex($t3, $t0, $t1)
			scanInt($t4)
			sw $t4, myArray($t3)
			
			addi $t1, $t1, 1
			j for_2_loop
		for_2_end:
		addi $t0, $t0, 1
		j for_1_loop
	for_1_end:
	
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	li $t0, 0
	for_3_loop:
		bgt $t0, $s1, for_3_end
		
		li $t2, 1
		getIndex($t1, $zero, $t0)
		sw $t2, myArray($t1)
		getIndex($t1, $s0, $t0)
		sw $t2, myArray($t1)
		
		addi $t0, $t0,1
		j for_3_loop
	for_3_end:
	
	li $t0, 0
	for_4_loop:
		bgt $t0, $s0, for_4_end
		
		li $t2, 1
		getIndex($t1, $t0, $zero)
		sw $t2, myArray($t1)
		getIndex($t1, $t0, $s1)
		sw $t2, myArray($t1)
		
		addi $t0, $t0,1
		j for_4_loop
	for_4_end:
	scanInt($t0)
	scanInt($t1)
	scanInt($s2)
	scanInt($s3)
	move $a0, $t0
	move $a1, $t1
	li $s4, 0 # result
	jal dfs
	printInt($s4)
	end
dfs:
	push($ra)
	push($a0)
	push($a1)
	push($t0)
	push($t1)
	move $a0, $t0
	move $a1, $t1
	
	bne $a0, $s2, if_dfs_1_else
	bne $a1, $s3, if_dfs_1_else
		addi $s4, $s4, 1
		jal dfsEnd
	if_dfs_1_else:
	li $t0, 1
	getIndex($t1, $a0, $a1)
	lw $t2, myArray($t1)
	bne $t2, $t0, if_dfs_2_else
		jal dfsEnd
	if_dfs_2_else:
	sw $t0, myArray($t1)
	
	addi $t0, $a0, 0
	addi $t1, $a1, -1
	getIndex($t2, $t0, $t1)
	lw $t3, myArray($t2)
	bne $t3, $zero, dfs_1_end
		jal dfs
	dfs_1_end:
	
	addi $t0, $a0, 1
	addi $t1, $a1, 0
	getIndex($t2, $t0, $t1)
	lw $t3, myArray($t2)
	bne $t3, $zero, dfs_2_end
		jal dfs
	dfs_2_end:
	
	addi $t0, $a0, 0
	addi $t1, $a1, 1
	getIndex($t2, $t0, $t1)
	lw $t3, myArray($t2)
	bne $t3, $zero, dfs_3_end
		jal dfs
	dfs_3_end:
	
	addi $t0, $a0, -1
	addi $t1, $a1, 0
	getIndex($t2, $t0, $t1)
	lw $t3, myArray($t2)
	bne $t3, $zero, dfs_4_end
		jal dfs
	dfs_4_end:
	
	getIndex($t2, $a0, $a1)
	sw $zero, myArray($t2)
	
	
	
dfsEnd:
	pop($t1)
	pop($t0)
	pop($a1)
	pop($a0)
	pop($ra)
	jr $ra

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
