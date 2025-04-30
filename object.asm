
#	obj.asm
#	from MIPS_MATRIX

.text

.globl intString_to_int

.globl initiate_matrix


intString_to_int:
	
	addiu	$sp, $sp, -12
	sw	$ra, 4($sp)
	sw	$fp, 0($sp)
	addiu	$fp, $sp, 8

	li	$t5, 29
	li	$t6, 40
	move	$t9, $zero		# $t9 = 0; // counter for position
	sw	$a0, 8($sp)		# store argument
	COUNT_INTEGER_POSITIONS:

	lb	$s4, 0($a0)		# // iterate string
	slt	$t7, $t5, $s4		# // check the string is in the range of integers
	slt	$t8, $s4, $t6
	and	$t8, $t8, $t7

	beq	$t8, $zero, END_COUNT	
	addi	$t9, $t9, 1
	addi	$a0, $a0, 1

	j COUNT_INTEGER_POSITIONS
	END_COUNT:

	
	lw	$a0, 8($sp)

	li	$t7, 1
	li	$t4, 10			# // numbers will be multiplied by a power of 10
					# // such that 
					# // (asciival - 30) * 10^i where i:= $t9;
	move	$s0, $t9

	POW:				# // naive exponentation. It sucks but I need to cut a huge corner here
	beq	$s0, $zero, END_POW	# // for each i in the range exponent down to 0

	mul	$t7, $t7, $t4
	subi	$s0, $s0, 1

	j POW
	END_POW:
			
	move	$s0, $t7		# $s0 = 10^($t9);
	move	$v0, $zero		# $s1 = 0; // store the result
	TRANSFORM_INTEGER_POSITIONS:
	lb	$s4, 0($a0)		# // iterate string
	slt	$t7, $t5, $s4		# // check the string is in the range of integers
	slt	$t8, $s4, $t6
	and	$t8, $t8, $t7

	beq	$t8, $zero, END_TRANSFORM
	
	subi	$s4, $s4, 30		# $s4 -= 30 ;// normalize character
	mult	$s4, $s4, $s0		# $s4 *= $s0;// multiply 
	add	$v0, $v0, $s4		# $v0 += $s4;// add to result

	div	$s0, $s0, $t4		# $s0 /= 10;// divide by 10

	subi	$t9, $t9, 1		# // substract the position
	addi	$a0, $a0, 1		# // iterate the string


	j TRANSFORM_INTEGER_POSITIONS
	END_TRANSFORM:

	lw	$ra, 4($sp)
	lw	$fp, 0($sp)
	addiu	$sp, $sp, 12
	jr	$ra

# after passed  a string address 0, it initiates a matrix on the first
# [, then makes a row on the starting [ of the elements. adding an element
# as separated by a comma, it also has a sequence that parses strings to integers
initiate_matrix:
	
	addiu	$sp, $sp, -8		# // prologue
	sw	$ra, 4($sp)
	sw	$fp, 0($sp)
	addiu	$fp, $sp, 4

	li	$t0, '['
	li	$t1, ']'
	li	$t2, ','
	
	ITERATE_STRING:
	

	j ITERATE_STRING
	END_ITERATE_STRING:
	
	lw	$ra, 4($sp)		# // epilogue
	lw	$fp, 0($sp)
	addiu	$sp, $sp, 8
	jr	$ra
