# 	THIS IS MY SUBMISSION FILE
# 	FOR ASM 6
# 	TEST WITH OBJECT_TEST.ASM

#	obj.asm
#	from MIPS_MATRIX
#	Jaime Meyer Beilis Michel on a chill April 30th
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
# // keep count of the number of elements
ElementNo:	.word 0
ElementNoWord:  .word 0
# // make a buffer that reads each element
ElementBuffer:	.space	50
# // instead of trash collecting every time
# // a counter is imposed to iterate on each 
# // elements
ElementBufferCounter:
		.word	0

ReadingMatrix:	.word 	0
ReadingRow:	.word 	0 

MatrixAddressTemp:
		.word	0

# // TODO: store row and column length for matrices
RowLength:	.word   0
ColumnLength:	.word	0

debug:		.asciiz "You might want to reconsider that which you are doing"

# NOTE: 
# the current method I am using permits for an input like this
# [[a,b], [a,b,c]]
# however, it will leak.
# That is alright for starters, making the system so it handles 
# input errors like that should be time consuming

.text

# it takes an argument $a0 containing the address of space , assummed separated as bytes, and converts
# into integer for the ascii values ['0'-'9']
.globl intString_to_int

# creates a matrix object in the memory heap from a given input address $a0;
# returns the starting heap address of the Matrix generated. (Row major form)
.globl initiate_matrix

# iterates a string with an integer written in decimal form to make it an actual value
intString_to_int:
	
	addiu	$sp, $sp, -16		# // prologue
	sw	$ra, 4($sp)
	sw	$fp, 0($sp)
	addiu	$fp, $sp, 12

	li	$t5, 47
	li	$t6, 58
	move	$t9, $zero		# $t9 = 0; // counter for position
	sw	$a0, 8($sp)		# // store argument
	COUNT_INTEGER_POSITIONS:

	lb	$s4, 0($a0)		# // iterate string
	slt	$t7, $t5, $s4		# // check the string is in the range of integers
	slt	$t8, $s4, $t6
	and	$t8, $t8, $t7

	beq	$t8, $zero, END_COUNT	# if(isChar($s4)){	
	addi	$t9, $t9, 1
	addi	$a0, $a0, 1

	j COUNT_INTEGER_POSITIONS
	END_COUNT:			# }else { return; }

	
	lw	$a0, 8($sp)

	li	$t7, 1
	li	$t4, 10			# // numbers will be multiplied by a power of 10
					# // such that 
					# // (asciival - 30) * 10^(i-1) where i:= $t9;
	addi	$t9, $t9, -1
	move	$s0, $t9

	POW:				# // naive exponentation. It sucks but I need to cut a huge corner here
	beq	$s0, $zero, END_POW	# // for each i in the range exponent down to 0

	mul	$t7, $t7, $t4
	addi	$s0, $s0, -1

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
	
	addi	$s4, $s4, -48		# $s4 -= 48 ;// normalize character
	mul	$s4, $s4, $s0		# $s4 *= $s0;// multiply 
	add	$v0, $v0, $s4		# $v0 += $s4;// add to result

	div	$s0, $s0, $t4		# $s0 /= 10;// divide by 10

	addi	$t9, $t9, -1		# // substract the position
	addi	$a0, $a0, 1		# // iterate the string


	j TRANSFORM_INTEGER_POSITIONS
	END_TRANSFORM:

	lw	$ra, 4($sp)		# // epilogue
	lw	$fp, 0($sp)
	addiu	$sp, $sp, 16
	jr	$ra

# after passed  a string address a0, it initiates a matrix on the first
# [, then makes a row on the starting [ of the elements. adding an element
# as separated by a comma, it also has a sequence that parses strings to integers
initiate_matrix:
	
	addiu	$sp, $sp, -16		# // prologue
	sw	$ra, 4($sp)
	sw	$fp, 0($sp)
	addiu	$fp, $sp, 12

	sw	$a0, 8($sp)
	li	$t0, '['		# $t0 = '[';
	li	$t1, ']'		# $t1 = ']';
	li	$t2, ','		# $t2 = ',';
	
	move	$s6, $a0		# $s6 = *$a0
	
	ITERATE_STRING:			# for(int i = 0; i < string length; i++){

	lb	$s3, 0($s6)		# $s3 = $a0[i]
	
	# move	$a0, $t3
	
	bne	$s3, $t0, NOTOPEN	# if($s3 == '['){
	
	lw	$t3, ReadingMatrix		# $t3 = ReadingMatrix;
	beq	$t3, $zero, MATRIX_OPENED	# if($t3 != 0){

	li	$t3, 1				# $t3 = 1;
	sw	$t3, ReadingRow			# make reading row true
	
	MATRIX_OPENED:				# }

	li	$t3, 1
	sw	$t3, ReadingMatrix	# // now elements are not ignored

	
	j THENCHAR

	NOTOPEN:			# }

	bne	$s3, $t1, NOTCLOSE	# else if($s3 == ']'){

	lw	$t3, ReadingRow		# $t3 = ReadingRow;
	
	# TODO: COUNT DIMENSIONS

	sw	$zero, ReadingRow	# // in whichever of both cases, row reading will be closed

	beq	$t3, $zero, EXIT_SEQUENCE
					# // If Reading row is true is false and a closing has been found, then it is go time
	

	NOTCLOSE:			# }




	# COMMA SECTION ~~~~~~ Handle with care, logic here is very delicate
	
	
	bne	$s3, $t2, THENCHAR	# if(#s4 == ','){

	# case 1: it is a comma and reading row is open, then add number to buffer
	# transform to an int value, allocate space in memory in which the integer is appended
	# (currently using row major form)
	
	lw	$t3, ReadingRow 		# $t3 = ReadingRow;
	
						# if($t3 != 0){
	beq	$t3, $zero, DONTALLOCATE	# // if reading the row then do:
	
	# sw	$s6, 8($sp)			# 	// save the first argument
	la	$a0, ElementBuffer		# 	$a0 = elementBuffer;
	lw	$t3, ElementBufferCounter	# 	$t3 = elementBufferCounter;
	
						# // subcase, the counter length is 0, that means the
						# // characters were not read and we pad by passing
						# // a value 0
						
	beq	$t3, $zero, PADDING		# 	if($t3 == 0){

	# convert to integer
	
	# sw	$a0, 12($sp)
	move	$s7, $s3
	jal	intString_to_int	# // returns the result from converting a set of characters into an integer value
	move	$t3, $v0		# $t3 = intString_to_int(*elementBuffer); // the integer value read from the string is passed to $t3
	move	$s3, $s7
	# lw	$a0, 12($sp)
	
	j DOALLOC		# goto DOALLOC; // DO ALLOCATE, skip the padding process
	
	PADDING:		# }
	
				# // If the counter is 0, then pad the mistake and allocate a value of 0
	move	$t3, $zero	# $t3 = 0;

	DOALLOC:		# DOALLOC: // 
	
	
	# move	$t4, $a0	# $t4 = $a0;
	
	addiu	$sp, $sp, -4
	lw	$s4, ElementNoWord
	addi	$s4, $s4, 4
	sw	$s4, ElementNoWord
	lw	$s4, ElementNo
	addi	$s4, $s4, 1
	sw	$s4, ElementNo
	sw 	$t3, 0($sp)
	
	
	DONTALLOCATE:

				# // now the value has passed, meaning that we can restart the counter
	sw	$zero,	ElementBufferCounter
				
				# // case 2: it is a comma and reding row is closed. This one can be ignored.
				# // The row major form permits us a lot of flexibility with such a small charset
				
	j  SKIPCHAR		# // now we skip.
	
	THENCHAR:		# } else{

				# finally, do the else case. 
				# that would be, if it exists within the range of numerical input
				# and it exists within row read we add 1 to the counter, load on the space
				# allocated
	
	li	$t3, 47
	slt	$t4, $t3, $s3
	li	$t3, 58
	slt	$t3, $s3, $t3
	and	$t3, $t3, $t4		# // conditions to make sure that
					# // '0' <=  $s3 <= '9' respectively

	lw	$t4, ReadingRow		# // if the int is true and we are reading a row, then we add to the buffer
	and	$t3, $t3, $t4		# if(ReadingRow && isInt($t3)){

	beq	$t3, $zero, SKIPCHAR	# if($t3 != 0){
	
	la	$t3, ElementBuffer		# $t3 = *ElementBuffer; // grab buffer space
	
	lw	$t4, ElementBufferCounter 	# $t4 = ElementBufferCounter; // grab counter
	
	add	$t3, $t3, $t4			# $t3 += $t4; // current position of the character element
	
	sb	$s3, 0($t3)			# ElementBuffer[$t3 + $t4] = $s3 // read byte is loaded into the buffer 

	addi	$t4, $t4, 1			# // augment the counter
	sw	$t4, ElementBufferCounter	# ElementBufferCounter++;



					# // WARNING: This currently assumes no integer is greater than the buffer length!!that is,
					# // intLength < 50
					# // One would have to make this also a stack operation.
					
	addi	$t3, $t3, 1		# // add an argument forward that nullifies the iteration when converting into integer
	sb	$zero, 0($t3)		# // store a 0 forward so it breaks the loop when converting to integer:


	SKIPCHAR:			# }
					# }
					
					

	addi	$s6, $s6, 1		# a0 ++;
	
	# // debug statement
	bne	$s3, $zero, ITERATE_STRING
	move	$t3, $a0
	la	$a0, debug
	li	$v0, 4
	move	$a0, $t3
	
	syscall
	
	
	j ITERATE_STRING		# // reiterate
	
	
	
	END_ITERATE_STRING:
	EXIT_SEQUENCE:
	
	# // sequence to append to heap
	
	# counter for loop iteration
	add	$s0, $zero, $zero
	
	# element number load
	lw	$s1, ElementNo
	
	lw	$s4, ElementNoWord
	# start at an offset of 12
	addu	$s7, $sp, $s4
	
	# pass down the call for heap
	addi	$v0, $zero, 9
	
	# pass down the amount of bytes needed
	add	$a0, $zero, $s4
	syscall
	
	# copy the returned heap address into $s4
	add	$s4, $zero, $v0
	
	
	STACK_TO_HEAP:
	beq	$s0, $s1, EXITSTACKTOHEAP
	# load from stack store in heap
	lw	$s3, 0($s7)
	sw	$s3, 0($s4)
	
	# augment the addresses one word
	addiu	$s7, $s7, -4
	addi	$s4, $s4, 4
	# augment the counter for iter
	addi	$s0, $s0, 1
	j STACK_TO_HEAP
	
	EXITSTACKTOHEAP:
	
	# // Reset all fields
	sw	$zero, ElementNo
	sw	$zero, ElementBufferCounter
	sw	$zero, ReadingRow
	sw	$zero, ReadingMatrix
	

	lw	$t0, ElementNoWord
	addu	$sp, $sp, $t0
	
	lw	$ra, 4($sp)		# // epilogue
	lw	$fp, 0($sp)
	addiu	$sp, $sp, 16

	jr	$ra
