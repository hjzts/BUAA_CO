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
	lw  $src, ($sp)
.end_macro

.macro end
	li $v0, 10
	syscall
.end_macro

.macro printEnter
	li $v0, 11
	li $a0, '\n'
	syscall
.end_macro

.macro printSpace
	li $v0, 11
	li $a0, ' '
	syscall
.end_macro

.data

.text
	scanInt($s0)
	li $t0, 0
	for_1_begin:
		beq $t0, $s0, for_1_end
		
		printInt($t0)
		printSpace
		
		addi $t0, $t0, 1
		j for_1_begin
		nop
	for_1_end:
	printEnter
	end