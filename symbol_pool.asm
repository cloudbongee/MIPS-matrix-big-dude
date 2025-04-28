
#	symbol_pool.asm
# 	By Jaime Meyer Beilis Michel
# 	Made on a calm Sunday afternoon
#	The symbol_pool part of the project
#	implements a hashmap that maps a string
# 	to the memory space allocated for its matrix.

# 	current memory structure of symbol pool
#	byte 0-4 [ symbol_pool_functions ]
#	byte 4-8 [ length                ]
#	byte 8-12[ counter for used bytes]
#	         [ symbol table ] dynamically allocated



.data


prime_table_sizes:
			.word 401	
symbol_pool_functions:
			.word append_symbol

.text

.globl	initiate_symbol_pool
.globl append_symbol

# // it allocates, and initializes the structure and data for the symbol pool, returns address
# // the reason I made this function return the address instead of globalizing on the .data
# // declaritions is because .data segment is fixed :(
initiate_symbol_pool:
	addiu	$sp, $sp, -8		# // epilogue
	sw	$ra, 4($sp)
	sw	$fp, 0($sp)
	addiu	$fp, $sp, 4
	
	li	$v0, 9			# // syscall for sbrk
	li	$a0, 436		# // 53 * 8 + 12 (bytes allocated for 53 buckets, counter, function table, size)
	syscall
					# // $v0 gets some allocated space
	move	$t0, $zero		# int $t0 = 0;
	li	$t1, 436		# int $t1 = 436;
	move	$t2, $v0		# symbol_pool* $t2 = $v0
	
	
					# // cleanup sequence for the allocated memory
	CLEANUP_LOOP:			# while($t0 < $t1){
	slt	$t0, $t1		
	beq	$t0, $zero, END_CLEANUP_LOOP
	
	sw	$zero, 0($t2)		# $t2[$t0] = 0;
	
	addi	$t2, $t2, 4
	addi	$t0, $t0, 4		# $t0++;
	END_CLEANUP_LOOP:		# }
	
	la	$t0, symbol_pool_functions
	sw	$t0, 0($v0)		# $t2[0] = *functions;
	
	
	lw	$ra, 4($sp)		# // prologue
	lw	$fp, 0($sp)
	addiu	$sp, $sp, 8
	jr	$ra
	
# // $a0 will pass the address of the pool, $a1 passes the hashed integer, $a2 will pass the address for the matrix
append:					# append(symbol_pool* self, int hashed, matrix* $a2){
	addiu	$sp, $sp, -8		# // epilogue
	sw	$ra, 4($sp)
	sw	$fp, 0($sp)
	addiu	$fp, $sp, 4
	
	lw	$t3, 4($a0)
					# // get remainder
	rem	$t0, $a1, $t3		# $t0 = $a1 % $t0;
					# // normalize to word size for a pair
	sll	$t0, $t0, 3		# $t0 *= 8;
	
	add	$t0, $t0, $a0		# // make $t0 the resulting address
					# $t0 = $t0 + $a0;
	
	addi	$t0, $t0, 12		# // 12 offset

	sll	$t5, $t3, 3		# // multiply length times 8
	add	$t5, $a0,$t3		# // add length to address
	addi	$t5, $t5, 12		# // point to the end address of the list

	CLUSTER_CHECK:
	lw	$t1, 0($t0)

	beq	$t1, $zero, UNCLUSTERED # while($t1 != 0){
	addi	$t0, $t0, 8		# $t0 += 8;
	
	bne	$t0, $t5, CLUSTER_CHECK # if the pointer reaches the end of the list

	addi	$t0, $a0, 12		# reset to start position 
		
	j CLUSTER_CHECK			# }
	UNCLUSTERED:
	
	sw	$a1, 0($t0)		# // add key value pair to bucket
	sw	$a2, 4($t0)

	lw	$t2, 8($a0)		# // update counter for allocated pairs
	addi	$t2, $t2, 1
	sw	$t2, 8($a0)

	bne	$t2, $t3, OK_LENGHT	# if(this->size == this->counter){
	
	jal	reallocate		# this->reallocate()

	OK_LENGTH:			# }

	lw	$ra, 4($sp)		# // prologue
	lw	$fp, 0($sp)
	addiu	$sp, $sp, 8
	jr	$ra			# }
	
	

reallocate:				# TODO: 
					# I will wait on this implementation
					# as it is timely and won't be needed
					# to get things up and running
	jr	$ra


