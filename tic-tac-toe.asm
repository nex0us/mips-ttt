.data
grid:  		.word 0, 0, 0, 0, 0, 0, 0, 0, 0
input1:		.asciiz "\n X select the next move (1-9):  "
input2: 	.asciiz "\n O select the next move (1-9):  "
output1:	.asciiz "\n Invalid move! The square is already occupied; please select again (1-9):  "
output2:	.asciiz "\n Invalid index! Please select the next square (1-9):  "
hdivider:	.asciiz "\n-----------------\n"
space:		.asciiz "  "
vdivider:	.asciiz "  |"
mark1:		.asciiz "X"
mark2:		.asciiz "O"
placeholder:.asciiz "-"
output3:	.asciiz "\n Congratulations, X WINS!"
output4:	.asciiz "\n Congratulations, O WINS!"
output5:	.asciiz	"\n GAME DRAW"
nl:			.asciiz "\n"

.text
main:	
	addi $t3, $zero, 9		# Counter
	addi $a2, $zero, 1		# Value 1 will represent X.
	addi $s2, $zero, 2		# Value 2 will represent O.
	addi $s0, $zero, 3		# Counter for printing.
	addi $s1, $zero, 3		# Another counter for printing.
	add $t9, $zero, $zero	# A flag to tell who's turn it is.
	jal print
	#beq $t9, $zero, main2
	j main2

print:	
	li $v0, 4				# Print operation
	la $a1, grid			# a1 contains address of grid (tic-tac-toe board)
	print1:	
		lw $t8, 0($a1)		# Load word at address, (0 is a dash, 1 is an X, 2 is an O)
		addi $a1, $a1, 4	# Move address up by word
		la $a0, space		# Load address of space
		syscall				# Print space
		beq $t8, $zero, dash 
		beq $t8, $a2, X
	O:	
		la $a0, mark2
		syscall
		addi $s0, $s0, -1	# Moving counter down by 1
		bgtz $s0, hdash
		j nline
	X:	
		la $a0, mark1
		syscall
		addi $s0, $s0, -1	# Counter down by 1
		bgtz $s0, hdash
		j nline
	dash:	
		la $a0, placeholder	# Load dash placeholder
		syscall				# Print dash
		addi $s0, $s0, -1	# 
		bgtz $s0, hdash		# $s0 > 0 -> hdash
		j nline
	hdash:	
		la $a0, vdivider	# Load vdivider
		syscall				# Print it
		j print1			# back to print1
	nline:	
		la $a0, hdivider
		syscall
		addi $s1, $s1, -1
		addi $s0, $s0, 3	# Resetting counter to 3
		bgtz $s1, print1
		jr $ra

win1:
	jal print
	li $v0, 4
	la $a0, output3
	syscall
	j endgame

win2:
	jal print 		# Prints board
	li $v0, 4		
	la $a0, output4 # Prints that player O wins.
	syscall
	j endgame

draw:
	jal print	
	li $v0, 4		
	la $a0, output5 # Prints that it was a draw.
	syscall
	j endgame	

main21:	
	li $v0, 4
	la $a0, output1
	syscall
main2:	
	li $v0, 4			# Load command to output string
	beq $t9, $zero, inputX
	j inputO
	inputX:
		la $a0, input1
		syscall
		li $v0, 5		# Load command to input an integer
		syscall
		j endinputX
	inputO:
		la $a0, input2
		syscall
		jal random_number
		li $v0, 1
		la $a0, ($v1)
		syscall
		li $v0, 4
		la $a0, nl
		syscall
		add $v0, $v1, $zero
	endinputX:
	slti $t1, $v0, 10	# Catches an exception, index > 9.
	beq $t1, $zero, excep1
	slti $t1, $v0, 1	# Catches an exception, index < 1.
	bne $t1, $zero, excep1
	la $a0, grid
	addi $v0, $v0, -1
	sll $t1, $v0, 2		# Multiply index by 4, for byte offset.
	add $a0, $a0, $t1	
	lw $a1, 0($a0)
	bgtz $a1, main21
	beq $t9, $zero, makeX
	j makeO
	makeX:
		addi $a1, $a1, 1
		j endmakeX
	makeO:
		addi $a1, $a1, 2
	endmakeX:
	sw $a1, 0($a0)
	addi $t3, $t3, -1		# Subtract counter.
	beq $t9, $zero, switch_X
	j switch_O
	switch_O:
		addi $t9, $t9, 1 	# Player O's turn is next
		j endswitch
	switch_X:
		addi $t9, $t9, -1 	# Player X's turn is next
	endswitch:
	addi $s1, $s1, 3
	j end1
	excep1:
		li $v0, 4
		la $a0, output2
		syscall
		j main2

# Both end1 and end2 are used to determine if X or O wins.
end1:
	add $a3, $zero, $a2
	j check_X
	switch_check:
		add $a3, $zero, $s2
	check_X:
		
	#start_checks:
	la $a0, grid # Load grid to $a0
	addi $t7, $zero, 4 # Row space offset is just one word
 	jal check_row # Checks row 1
	jal check_row # Checks row 2
	jal check_row # Checks row 3
	
	# Check left to right diagonal
	la $a0, grid # Load start of grid back to $a0
	addi $t7, $zero, 16 # Offset for left to right diagonal
	jal check_row

	# Check right to left diagonal
	la $a0, grid # Load start of grid back to $a0
	addi $a0, $a0, 8 # Move starting index to 8 for start of right to left diagonal
	addi $t7, $zero, 8 # Offset for right to left diagonal
	jal check_row

	# Check first column
	la $a0, grid
	addi $t7, $zero, 12 # Offset for first column
	jal check_row

	# Check second column
	la $a0, grid
	addi $a0, $a0, 4 # Starting index for column 2
	addi $t7, $zero, 12 # Offset for column 2
	jal check_row

	# Check third column
	la $a0, grid
	addi $a0, $a0, 8 # Starting index for column 3
	addi $t7, $zero, 12 # Offset for column 3
	jal check_row
	
	beq $a3, $a2, switch_check # After checking X switch to checking O
	
	next7:	bne $t3, $zero, next7print
	j next7notprint
	next7print:
		jal print
		j main2
	next7notprint: 
	j draw		# X must win by 9th turn or it's a draw
	
	j main2
	
endgame:
	li $v0, 10
	syscall

check_row: 
	# Check if Row is filled with X/O *updated, so that works for all checks not just row*
	# load either X or O into parameter $a3
	# check all conditions with $a3
	# if all conditions met then update $v1 as return value, 1 == win, 0 == no win
	lw $t4, ($a0)
	add $a0, $t7, $a0
	lw $t5, ($a0)
	add $a0, $t7, $a0
	lw $t6, ($a0)
	add $a0, $t7, $a0
	
	beq $t4, $a3, _cond2
	jr $ra
	_cond2:	
		beq $t5, $a3, _cond3
		jr $ra
	_cond3:
		beq $t6, $a3, check_row1_return
		jr $ra
	check_row1_return:
		beq $a3, $s2, win2 	# 'O' has won
		j win1 				# 'X' has won
		
random_number:
	addi $v0, $zero, 30     # Syscall 30: System Time syscall
	syscall                 # $a0 will contain the 32 LS bits of the system time
	add $t0, $zero, $a0     # Save $a0 value in $t0 

	addi $v0, $zero, 40     # Syscall 40: Random seed
	add $a0, $zero, $zero   # Set RNG ID to 0
	add $a1, $zero, $t0     # Set Random seed to
	syscall

	add $v1, $zero, $zero
	addi $v0, $zero, 42		# Syscall 42: Random int range
	add $a0, $zero, 1  		# Set RNG ID to 0
	addi $a1, $zero, 10   	# Set upper bound to 4 (exclusive)
	syscall                 # Generate a random number and put it in $a0
	add $v1, $zero, $a0     # Copy the random number to $s1
	jr $ra
