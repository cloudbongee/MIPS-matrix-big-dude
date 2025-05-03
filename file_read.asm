
#	from MIPS_MATRIX project 
#	input.asm
#	Reads file input

.data	
.text
	.globl	file_input
	.globl	user_input


# // file input function reads a file from a given argument $a0 (filename), into allocated space addressed $a1
file_input:				# void file_input(str& $a0, char* $a1){
	addiu	$sp, $sp, -16		# // epilogue
	sw	$ra, 4($sp)
	sw	$fp, 0($sp)
	addiu	$fp, $sp, 12
	
	sw	$a0, 8($sp)
	sw	$a1, 12($sp)

	li	$v0, 13			# // syscall argument for opening file
	move	$a1, $zero		# // flag for reading file
	syscall				# // opens the file
	
	move	$a0, $v0		# // file descriptor into first argument
	li	$v0, 14			# // syscall argument for reading file
	lw	$a1, 12($sp)		# // load the allocated space address

	li	$a2, 50000		# // buffer space
	syscall

	lw	$a0, 12($sp)		# // pass the address of the string		
					# // parsing the input. 
	jal	parse_input		# return parse_matrix(char* $a0);
	
	lw	$ra, 4($sp)
	lw	$fp, 0($sp)
	addiu	$sp, $sp, 12
	jr	$ra			# }


# // takes address of input buffer on $a0, reads input
user_input:				# void user_input(){
	addiu	$sp, $sp, -12		# // epilogue
	sw	$ra, 4($sp)
	sw	$fp, 0($sp)
	addiu	$fp, $sp, 4
	
	sw	$a0, 8($sp)
	li	$v0, 8
	li	$a1, 50000		# // allocated input space
	syscall

	lw	$a0, 8($sp)
	jal	parse_input

	lw	$ra, 4($sp)
	lw	$fp, 0($sp)
	addiu	$sp, $sp, 8
	jr	$ra




