.macro scanInt(%d)
	li $v0, 5
	syscall
	move %d, $v0
.end_macro

.macro getAddr(%ans, %n, %i, %j, %addr)
    mul %ans, %n, %i
    add %ans, %ans, %j
    sll %ans, %ans, 2
    add %ans, %ans, %addr
.end_macro

.macro scanMatrix(%m, %n, %addr)
    li $t5, 0
    for_1_loop:
        beq $t5, %m, for_1_end
            li $t6, 0
            for_2_loop:
                beq $t6, %n, for_2_end
                scanInt($t7)
                getAddr($t8, %n, $t5, $t6, %addr)
                sw $t7, ($t8)
                addi $t6, $t6, 1
                j for_2_loop
            for_2_end:
        addi $t5, $t5, 1
        j for_1_loop
    for_1_end:
.end_macro

.macro conv(%addr1, %addr2, %m, %n, %k, %l)
	sub  $s2, %m, %k
	addi $s2, $s2, 1
	sub  $s3, %n, %l
	addi $s3, $s3, 1
    li $t4, 0
    for_3_loop:
        bge $t4, $s2, for_3_end
        
        li $t5, 0
        for_4_loop:
            bge $t5, $s3, for_4_end
            li $s4, 0
            li $t6, 0 
            
            for_5_loop:
                bge $t6, %k, for_5_end
                li  $t7, 0
                for_6_loop:
                    bge $t7, %l, for_6_end
                	   add $t8, $t4, $t6
                	   add $t9, $t5, $t7
                	   getAddr($s5, %n, $t8, $t9, %addr1)
                	   lw $s5, ($s5)
                	   getAddr($s6, %l, $t6, $t7, %addr2)
                	   lw $s6, ($s6)
                	   mul $s5, $s5, $s6
                	   add $s4, $s4, $s5
                    addi $t7, $t7, 1
                    j for_6_loop
                for_6_end:
            	
             	addi $t6, $t6, 1
                j for_5_loop
            for_5_end:
            printInt($s4)
            addi $t5, $t5, 1
            bne  $t5, $s3, print_space
                printEnter
                j print_end
            print_space:printSpace 
            print_end:
            j for_4_loop
        for_4_end:
        addi $t4, $t4, 1
        j for_3_loop
        
    for_3_end:
.end_macro

.macro printInt(%d)
	li $v0, 1
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

.data
    matrix1:  .space 500
    matrix2:  .space 500
    space  :  .asciiz " "
    enter  :  .asciiz "\n"
    
.text
    scanInt($t0)
    scanInt($t1)
    scanInt($t2)
    scanInt($t3)
    la $s0, matrix1
    la $s1, matrix2
    scanMatrix($t0, $t1, $s0)
    scanMatrix($t2, $t3, $s1)
    conv($s0, $s1, $t0, $t1, $t2, $t3)
   #conv(%addr1, %addr2, %m, %n, %k, %l)
   end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
