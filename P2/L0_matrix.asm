.macro scan(%d)
    li $v0, 5
    syscall
    move %d, $v0
.end_macro    
.macro scanMatrix(%n, %addr)
	li  $t0, 0
	mul $t3, %n, %n
	for_loop:
	    beq $t0, $t3, for_end
	    scan($t4)
	    sll $t5, $t0, 2
	    add $t5, %addr, $t5
	    sw  $t4, ($t5)
	    addi $t0, $t0, 1
	    j for_loop
    for_end:   
.end_macro
.macro getAddr(%ans, %n, %i, %j, %addr)
    mul %ans, %n, %i
    add %ans, %ans, %j
    sll %ans, %ans, 2
    add %ans, %ans, %addr
.end_macro
.macro print(%d)
	li $v0, 1
	move $a0, %d
	syscall
.end_macro
.macro printSpace
	la $a0, space
	li $v0, 4
	syscall
.end_macro
.macro printEnter
	la $a0, enter
	li $v0, 4
	syscall
.end_macro	
.macro end 
	li $v0, 10
	syscall
.end_macro
.data
	matrix1: .space 256
	matrix2: .space 256
	matrix3: .space 256
	space: 	  .asciiz " "
	enter:    .asciiz "\n"
.text
	scan($s0)
	la $s1, matrix1
	scanMatrix($s0, $s1)
	la $s2, matrix2
	scanMatrix($s0, $s2)
	li $t4, 0 # $t4 = i
	for_1_loop:
	    beq $t4, $s0, for_1_end
	    
	    li $t5, 0
	    for_2_loop:
	        beq $t5, $s0, for_2_end
	        
	        li $t6, 0
	        li $t0, 0 # res
	        for_3_loop:
	        	beq $t6, $s0, for_3_end
	        	getAddr($t1, $s0, $t4, $t6, $s1)
	        	lw $t1, ($t1)
	        	getAddr($t2, $s0, $t6, $t5, $s2)
	        	lw $t2, ($t2)
	        	mul  $t7, $t1, $t2
	        	add  $t0, $t0, $t7
	        	addi $t6, $t6, 1
	        	j for_3_loop
	        for_3_end:  
	           print($t0)
	        addi $t5, $t5, 1
	        bne $t5, $s0, print_space
	            printEnter
	        beq $t5, $s0, print_end
	        print_space: printSpace
	        print_end:
	        j for_2_loop
	    for_2_end:	     
	    
	    addi $t4, $t4, 1
	    j for_1_loop
	for_1_end:
	end
		
	
