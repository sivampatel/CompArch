# Sivam Patel
# HW 1
# CS 3340.502

.data
a:	.word	0
b:	.word	0
c:	.word 	0
o1:	.word	0
o2:	.word	0
o3:	.word	0
name: .asciiz	""
namePrompt: .asciiz "What is your name? "
intPrompt: .asciiz "Please enter an integer between 1-100: "
result: .asciiz "your answers are: "

.text
main:
	# print prompt for user name
	li $v0, 4
	la $a0, namePrompt
	syscall
	
	# get user input for name and save to variable 
	li $v0, 8
	la $a0, name
	li $a1, 20
	syscall
	
	# get input for variable a
	li $v0, 4
	la $a0, intPrompt
	syscall
	li $v0, 5 # get user input
	syscall
	sw $v0, a # save user input into variable a
	
	# get input for variable b
	li $v0, 4
	la $a0, intPrompt
	syscall
	li $v0, 5 # get user input
	syscall
	sw $v0, b # save user input into variable b
	
	# get input for variable c
	li $v0, 4
	la $a0, intPrompt
	syscall
	li $v0, 5 # get user input
	syscall
	sw $v0, c # save user input into variable c
	
	# load variables a,b,c into registers
	lw $t1, a
	lw $t2, b
	lw $t3, c
	
	# calculate output 1
	add $t4, $t1, $t1 # 2a
	sub $t4, $t4, $t2 # (2a) - b
	add $t4, $t4, 9 # (2a - b) + 9
	sw $t4, o1 # save output 1 into variable
	
	# calculate output 2
	sub $t4, $t3, $t2 # c - b
	sub $t5, $t1, 5 # a + 5
	add $t4, $t4, $t5 # (c - b) + (a + 5)
	sw $t4, o2 # save output 2 into variable
	
	sub $t4, $t1, 3 # a - 3
	add $t5, $t2, 4 # b + 4
	add $t6, $t3, 7 # c + 7
	add $t4, $t4, $t5 # (a - 3) + (b + 4)
	sub $t4, $t4, $t6 # ((a - 3) + (b + 4)) - (c + 7)
	sw $t4, o3 # save output 3 into variable
	
	# print name
	li $v0, 4
	la $a0, name
	syscall
	
	# print result message
	li $v0, 4
	la $a0, result
	syscall
	
	# print output 1
	li $v0, 1
	lw $a0, o1
	syscall 
	
	# print space
	li $v0, 11  
	li $a0, ' '
	syscall

	#print output 2
	li $v0, 1
	lw $a0, o2
	syscall 
	
	# print space
	li $v0, 11  
	li $a0, ' '
	syscall

	#print output 3
	li $v0, 1
	lw $a0, o3
	syscall 
	
	li $v0, 10
	syscall

# test cases

# What is your name? Sivam
# Please enter an integer between 1-100: 15
# Please enter an integer between 1-100: 72
# Please enter an integer between 1-100: 47
# Sivam
# your answers are: -33 -15 34

# What is your name? Sivam
# Please enter an integer between 1-100: 82
# Please enter an integer between 1-100: 18
# Please enter an integer between 1-100: 73
# Sivam
# your answers are: 155 132 21

