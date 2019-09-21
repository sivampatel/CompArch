.data
words:	.word	1
chars:	.word	0
charOutput: .asciiz " character(s)"
wordOutput: .asciiz " word(s) "
prompt:	.asciiz "Enter some text"
end:	.asciiz "Goodbye"
dialogType: .asciiz "Program has ended. "
string: .space 100

.text 
main:	li $v0, 54
	la $a0, prompt
	la $a1, string
	li $a2, 50
	syscall
	
	bne $a1, 0, exit # check for new / successful user input
	
	jal count # count number of words and characters in string
	
	sw $v0, words
	sw $v1, chars
	
	j print
	
count:	#t0 = address of string, $t1 = current byte (character), v0 = words counter, v1 = characters counter
	la $t0, string # store address of string
	li $v0, 1
	li $v1, 0
	li $t2, 32 # space character ascii code
	li $t3, 10 # newline character ascii code
		
loop:
	lb $t1, ($t0)	#load character
	
	bne $t1, $t2, continue
	addi $v0, $v0, 1
	
continue:
	beq $t1, $zero, breakLoop	# check for '\0' character (null-terminator)
	beq $t1, $t3, breakLoop	# check for '\n' character (newline)
	
	addi $v1, $v1, 1	#increment numbe of characters
	addi $t0, $t0, 1	#increment character address
	
	j loop
	
breakLoop:
	beq $v1, $zero, exit
	jr $ra

print:	
	li $v0, 4
	la $a0, string
	syscall
	
	li $v0, 1
	lw $a0, words
	syscall

	li $v0, 4
	la $a0, wordOutput
	syscall
	
	li $v0, 1
	lw $a0, chars
	syscall
	
	li $v0, 4
	la $a0, charOutput
	syscall
	
	li $v0, 11
	li $a0, 10
	syscall
	
	j main

exit:	#print goodbye
	li $v0, 59
	la $a0, dialogType
	la $a1, end
	syscall
	
	li $v0, 10
	syscall
	
