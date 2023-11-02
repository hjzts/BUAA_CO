# generic looping mechanism
.macro for (%regIterator, %from, %to, %bodyMacroName)
	add %regIterator, $zero, %from
	Loop:
	%bodyMacroName ()
	add %regIterator, %regIterator, 1
	ble %regIterator, %to, Loop
.end_macro
	
#print an integer
.macro body()
	print_int $t0
	print_str "\n"
.end_macro

.eqv  LIMIT      20
.eqv  CTR        $t2
.eqv  CLEAR_CTR  add  CTR, $zero, 0

.data

.text	
	   #printing 1 to 10:
	   for ($t0, 1, 10, body)
	
       li $v0,1
       CLEAR_CTR
loop:  move $a0, CTR
       syscall
       add   CTR, CTR, 1
       blt   CTR, LIMIT, loop
       CLEAR_CTR
       
i_for:
	j_for:
		k_for:
	
		k_end:
	j_end:
i_end:      
       
       
       