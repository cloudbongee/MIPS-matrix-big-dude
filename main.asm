
#	+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+
#	|       ASM 6 By Jaime Meyer Beilis Michel       |
#	|       University of Arizona for CSC252         |
#	+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+
#	|    This project implements a small matrix      |
#	|    class utilizing row major organization      |
#	|   shows an implementation in an algorthm       |
#	+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+

#	I hope it is understandable that I am utilizing li and move

#	documentation found in github:
#	https://github.com/cloudbongee/MIPS-matrix-big-dude.git

#	assembling and linking with linux cross assembler:
	
# optional
#	sudo apt-get install binutils-mips-linux-gnu gcc-mips-linux-gnu

# process 1: 
# Run the following:
#	mips-linux-gnu-as matrix.asm -o matrix.o
#	... (assemble with all other required files)
#	mips-linux-gnu-ld matrix.o <all other files> -o matrix
 
# process 2:
# On linux, I made a bash script that assembles the required files
#	chmod +x assemble.sh
#	./assemble.sh


.data

welcome:	.asciiz		"Welcome to a slight matrix demonstration\nMade by Jaime Beilis at the University of Arizona for CSC252"
choice1:	.asciiz		"\nAre you inputting a [f]ile or [w]riting yourself?: "
queryfile:	.asciiz		"\nEnter file name : "

symbs:		.word		0
fname:		.space		282	
inputBuffer:	.space		50002

.text
	.globl main 
# startup, asks for the input of the matrix class
# arranges the processes that will be followed
main:
	# initiate the symbol pool
	jal	initiate_symbol_pool
	lw	$v0, symbs

	li	$v0, 4			# // argument for writing strings
	li	$a0, welcome		# // print a welcome
	syscall				# printf(welcome);
	
	restart:
	
	li	$a0, choice1		# // print input query type question
	syscall				# printf(choice1);
					
					# char $v0;
	li	$v0, 12			# // input syscall for character
	syscall				# scanf("%c", &$v0);
	
	li	$t0, 'f'
	bne	$v0, $t0, not_file	# if('f' == $v0){	
	
	li	$v0, 4
	li	$a0, queryfile
	syscall				# printf(queryfile);
	
	li	$v0, 8			# // syscall for reading a sequence of chars
	la	$a0, fname
	li	$a1, 280
	syscall				# scanf("%s", fname);
	
	la	$a0, fname
	la	$a1, inputBuffer
	jal	file_input
	
	j endChoice1			# } 
	
	not_file:			
	li	$t0, 'w'		
	bne	$v0, $t0, restart	# else if('w' == $v0){
	
	la	$a0, inputBuffer
	jal	user_input
	
	endChoice1:			# } else{ goto restart; }
	
	li	$v0, 10			# // terminate program
	syscall



	
