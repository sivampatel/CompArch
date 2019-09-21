.data
words:	.word	1
chars:	.word	0
charOutput: .asciiz " character(s)"
wordOutput: .asciiz " word(s) "
prompt:	.asciiz "Enter some text"
end:	.asciiz "Goodbye"
dialogType: .asciiz "Program has ended. "
string: .space 50
empyty: .asciiz ""

.text 
main:	li $v0, 54
	la $a0, prompt
	la $a1, string
	li $a2, 50
	syscall
	
	jal count
	
	sw $v0, words
	sw $v1, chars
	
	j print
	
	
count:	#a0 = address of string
	la $t5, string # store address of string
	li $v0, 1
	li $v1, 0
	li $t7, ' ' # check for space
	li $t8, '\n'
		
loop:	# v0 = words, v1 = characters, 
	lb $t6, ($t5)	#load character
	
	bne $t6, $t7, continue
	addi $v0, $v0, 1
	
continue:
	beq $t6, $zero, breakLoop	# check for '\0' character (null-terminator)
	beq $t6, $t8, breakLoop	# check for '\n' character (newline)
	
	addi $v1, $v1, 1	#increment numbe of characters
	addi $t5, $t5, 1	#increment character address
	
	j loop
	
breakLoop:
	beq $v1, $zero, exit
	jr $ra
	
clearString:
	

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
	
	j main

exit:	#print goodbye
	li $v0, 59
	la $a0, dialogType
	la $a1, end
	syscall
	
	li $v0, 10
	syscall
	
