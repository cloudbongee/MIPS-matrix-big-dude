

# 		Object test

.data
	mat1: .asciiz	"[[34,1,0],[1,2,2],[4,5,1]]"
	
.text	
	la	$a0, mat1
	
	jal	initiate_matrix
	
	li	$v0, 10
	syscall
	
