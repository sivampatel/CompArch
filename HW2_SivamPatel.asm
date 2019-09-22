
.data
words:	    .word 1
chars:	    .word 0
charOutput: .asciiz " character(s)"
wordOutput: .asciiz " word(s) "
prompt:	    .asciiz "Enter some text"
end:	    .asciiz "Goodbye"
dialogType: .asciiz "Program has ended. "
string:     .space 100

.text 
main:	# get user input
	li $v0, 54
	la $a0, prompt
	la $a1, string
	li $a2, 50
	syscall
	
	move $s1, $a1 # move status code to S1
	bne $s1, 0, exit # check for new / successful user input
	
	jal count # call function to count number of words and characters in string
	
	# save values returned from function
	sw $v0, words
	sw $v1, chars
	
	# print output
	j print
	
count:	#t0 = address of string, $t1 = current byte (character), v0 = words counter, v1 = characters counter

	addi $sp, $sp, -4
	sw $s1, ($sp) # push $s1 to stack

	li $v0, 1 # set number of words to 1
	li $v1, 0 # set number of characters to 0
	la $t0, string # store address of string
	li $t2, 32 # space character ascii code
	li $s1, 10 # newline character ascii code using S register
		
loop:
	lb $t1, ($t0)	#load character
	
	bne $t1, $t2, continue # check if character is a space
	addi $v0, $v0, 1 # increment word counter
	
continue:
	beq $t1, $zero, breakLoop # check for '\0' character (null-terminator)
	beq $t1, $s1, breakLoop	# check for '\n' character (newline)
	
	addi $v1, $v1, 1	#increment numbe of characters
	addi $t0, $t0, 1	#increment character address
	
	j loop # keep looping through string
	
breakLoop:
	lw $s1, ($sp) # restore value of $s1 form stack
	addi $sp, $sp, 4 # pop value from stack
	beq $v1, $zero, exit # check if string is empty
	jr $ra # return to main

print:	# print string
	li $v0, 4
	la $a0, string
	syscall
	
	# print number of words
	li $v0, 1
	lw $a0, words
	syscall

	# print " words "
	li $v0, 4
	la $a0, wordOutput
	syscall
	
	# print number of characters
	li $v0, 1
	lw $a0, chars
	syscall
	
	# print " characters "
	li $v0, 4
	la $a0, charOutput
	syscall
	
	# print newline
	li $v0, 11
	li $a0, 10
	syscall
	
	j main # go back to main to restart program

exit:	#print goodbye
	li $v0, 59
	la $a0, dialogType
	la $a1, end
	syscall
	
	li $v0, 10 # exit program
	syscall