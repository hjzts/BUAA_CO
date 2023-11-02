.data
	symbol : .space 28
	array  : .space 28
	space  : .asciiz " "
	enter  : .asciiz "\n"
	
.macro push(%src)
	sw   %src, ($sp)
	subi $sp,  $sp, 4
.end_macro

.macro pop(%des)
	addi $sp,  $sp, 4
	lw   %des, ($sp)
.end_macro

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

.macro printSpace
	li $v0, 4
	la $a0, space
	syscall
.end_macro

.macro printEnter
	li $v0, 4
	la $a0, enter
	syscall
.end_macro

.macro end
	li $v0, 10
	syscall
.end_macro

.text
	scanInt($s0) 	# n
	li $a1, 0 		# index
	jal fullArray
	end
	
fullArray:
	push($a2)
	push($a1)		# index
	push($ra)		# return addr
	push($t0) 		# i
	move $a1, $a2
	
	blt $a1, $s0, if_1_else
		li $t0, 0
		for_1_loop:
			bge $t0, $s0, for_1_end
			sll $t4, $t0, 2
			lw  $t1, array($t4)
			printInt($t1)
			printSpace
			addi $t0, $t0, 1
			j for_1_loop		
		for_1_end:
			printEnter
			jal fullArrayEnd
	if_1_else:
	
	li $t0, 0 		# i
	for_2_loop:
		bge $t0, $s0, for_2_end
		sll $t4, $t0, 2
		lw  $t1, symbol($t4) 
		bne $t1, $zero, if_2_else	# symbol[i] == 0 
			addi $t2, $t0, 1	
			sll  $t4, $a1, 2		
			sw   $t2, array($t4)		# array[index] = i + 1
			addi $t3, $zero, 1
			sll  $t4, $t0, 2
			sw   $t3, symbol($t4)	# symbol[i] = 1
			addi $a2, $a1, 1
			jal fullArray
			sll  $t4, $t0, 2
			sw   $zero, symbol($t4) 	#symbol[i] = 0
		if_2_else:
		
		addi $t0, $t0, 1
		j for_2_loop
	for_2_end:
fullArrayEnd:
	pop($t0)
	pop($ra)
	pop($a1)
	pop($a2)
	jr $ra


















