
#	parse.asm
# 	By Jaime Meyer Beilis Michel
# 	programmed on a structurally sound dorm building
#	Best by today.

#	The parse.asm file contains the utils, and functions
#	required to parse the input placed in an input buffer.

#	Here is the general procedure to the parsing algorithm:
#	a) We declare an integer representinf the field type we are scanning for currently
#	b) Start iteration of the string
#	c) Ignore padding whitespace, spaces, tabs
#	d) Ignore anything starting with the syntax "//"
# 	e1) If not matching to the syntax "Matrix", check that the current symbol is in the symbol_pool
#	d1) If in the pool, then move over to the next field, declare operation 1
#	d2) If not, then invalid
#	e2) If matching to the syntax "Matrix", keep operation 0

#	If the operation is a declarition, then simply read past the "=" sign and allocate accordingly
#	If the operation is an operation, then simply call over the correct symbols

# 	you might be wondering why my styling is all over the place in this file,
# 	the real reason is that parsing is usually a very humbling process. Where one ultimately
#	gives up to horrible style decisions for a little bit of sanity. Do forgive

.data

MAT: 	.ascii 		"Matrix"
syntax_fields:
	.byte		0,0,0
	
.text

	.globl 		parse_input
	.globl 		execute_command

parse_input:
# parse_input goes through the inputted text, forming a function syntax that is then executed
	addiu	$sp, $sp, -12
	sw	$ra, 4($sp)
	sw	$ra, 0($sp)
	addiu	$fp, $sp, 8
	sw	$a0, 8($sp)
	
	# registers the input type in the fields sequence
	# 0, 1, 2
	move	$s0, $zero

	# address for the "Matrix declarition"
	la	$s1, MAT

	# storage for the current hash
	move	$s2, $zero

	# store the space
	li	$t1, ' '
	# store the glorious semicolon
	li	$t2, ';'
	# store the illustrous "="
	li	$t3, '='


	# start iteration of the string
	ITERATE:
	lb	$t0, 0($a0)
	beq	$t0, $zero, ITERATE_END
	
	# check if it's a space
	bne	$t0, $t1, NOT_SPACE
	# if it is, then restart hash counter
	move	$s2, $zero
	NOT_SPACE:
	
	# check if it's an equal sign
	bne	$t0, $t3, NOT_EQSGN
		
	NOT_EQSGN:
	
	# check if it's a semicolon
	bne	$t0, $t2, NOT_SC
	jal	run_instruction
	NOT_SC:

	addi	$a0, $a0, 1
	ITERATE_END:
	
	lw	$ra, 4($sp)
	lw	$fp, 0($sp)
	addiu	$sp, 12
	jr	$ra



