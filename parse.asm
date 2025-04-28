.data
MAT: 	.ascii 		"Matrix"
.text

	.globl 		parse_input
	.globl 		execute_command

parse_input:
# parse_input goes through the inputted text, forming a function pool that is then executed
	addiu	$sp, $sp, -12
	sw	$ra, 4($sp)
	sw	$ra, 0($sp)
	addiu	$fp, $sp, 8
	sw	$a0, 8($sp)
	
	# the command pool will 
	ITERATE:
	lb	$t0, 0($a0)
	beq	$t0, $zero, ITERATE_END

	# TODO: Fill with the parsing iterative routine
	# i.e. ignore spaces, predict an incoming memory heap field
	# parse correctly and append into memory the correct matrix entries
	# error co
	
	addi	$a0, $a0, 1
	ITERATE_END:
	
	lw	$ra, 4($sp)
	lw	$fp, 0($sp)
	addiu	$sp, 12
	jr	$ra



