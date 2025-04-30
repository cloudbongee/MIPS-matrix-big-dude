
#	obj.asm
#	from MIPS_MATRIX
#	Probably the most important file here,
#	sadly it can be totally redone with a lot more optimization
# 	but I am kind of rushing this one due to finals, amongst other
#	situations on a time constraint.
#	Please, spare the comments

#	NOTE:
#	I am currently introducing a very flexible syntax.
#	That is, a mistake in writing a matrix (say [[1,2, _3], o[...]... ])
#	wouldn't really make that much of a difference, as my current parsing method
# 	is based on filtering a very limited set of ascii characters.
#	On a real implementation, this is unallowable, and should require penalizing on runtime
#	compilation / interpretation.


.data

// make a buffer that reads each element
ElementBuffer:	.space	50
// instead of trash collecting every time
// a counter is imposed to iterate on each 
// elements
ElementBufferCounter:
		.word	0

ReadingMatrix:	.word 	0
ReadingRow:	.word 	0 

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

# after passed  a string address a0, it initiates a matrix on the first
# [, then makes a row on the starting [ of the elements. adding an element
# as separated by a comma, it also has a sequence that parses strings to integers
initiate_matrix:
	
	addiu	$sp, $sp, -12		# // prologue
	sw	$ra, 4($sp)
	sw	$fp, 0($sp)
	addiu	$fp, $sp, 8

	li	$t0, '['
	li	$t1, ']'
	li	$t2, ','
	
	ITERATE_STRING:
	lb	$s3, 0($a0)

	bne	$s3, $t0, NOTOPEN	# if($s3 == '['){
	
	lw	$t3, ReadingMatrix
	beq	$t3, $zero, MATRIX_OPENED	# if matrix was opened before

	li	$t3, 1
	sw	$t3, ReadingRow			# make reading row true
	
	MATRIX_OPENED:

	li	$t3, 1
	sw	$t3, ReadingMatrix	# // now elements are not ignored

	
	j THENCHAR

	NOTOPEN:			# }


	bne	$s3, $t1, NOTCLOSE	# if($s3 == ']'){

	lw	$t3, ReadingRow		

	sw	$zero, ReadingRow	# in whichever of both cases, row reading will be closed

	beq	$t3, $zero, EXIT_SEQUENCE:
	# If Reading row is true is false and a closing has been found, then it is go time
	# else 
	
	NOTCLOSE:			# }


	bne	$s3, $t2, THENCHAR	# if(#s4 == ','){

	# case 1: it is a comma and reading row is open, then add number to buffer
	# transform to an int value, allocate space in memory in which the integer is appended
	# (currently using row major form)
	
	lw	$t3, ReadingRow 
	beq	$t3, $zero, DONTALLOCATE
	
	sw	$a0, 8($sp)
	la	$a0, elementBuffer

	# convert to integer
	jal	intString_to_int

	# TODO: ALLOCATE MEMORY, PUT IT IN A WORD THAT STORES THE ADDRESS
	# CHECK THAT SUCH WORD EXISTS. IF EXISTS ADD ONE WORD AND THROW THE INT
	# ELSE, MAKE NEW MEMORY ADD WORD, DECLARE DATA SEGMENT WORD

	DONTALLOCATE:

	# restart the counter
	sw	$zero	ElementBufferCounter
	
	# case 2: it is a comma and reding row is closed. This one can be ignored.
	# The row major form permits us a lot of flexibility with such a small charset

	THENCHAR:			# } else{
	# finally, do the else case. 
	# that would be, if it exists within the range of numerical input
	# and it exists within row read we add 1 to the counter, load on the space
	# allocated
	
	li	$t3, 29
	slt	$t4, $t3, $s4
	li	$t3, 40
	slt	$t3, $s4, $t3
	and	$t3, $t3, $t4

	lw	$t4, ReadingRow
	and	$t3, $t3, $t4

	beq	$t3, $zero, SKIPCHAR
	
	la	$t3, ElementBuffer	# grab buffer space
	lw	$t4, ElementBufferCounter # grab counter
	
	add	$t3, $t3, $t4
	sb	$s3, 0($t3)

	addi	$t4, $t4, 1		# augment the counter
	lw	$t4, ElementBufferCounter

	addi	$t3, $t3, 1		# add an argument forward that nullifies the iteration when converting into integer
	sb	$zero, 0($t3)		

	SKIPCHAR:

	
					# }

	addi	$a0, $a0, 1
	j ITERATE_STRING
	END_ITERATE_STRING:
	


	EXIT_SEQUENCE:
	sw	$zero, ReadingMatrix

	lw	$ra, 4($sp)		# // epilogue
	lw	$fp, 0($sp)
	addiu	$sp, $sp, 8
	jr	$ra
