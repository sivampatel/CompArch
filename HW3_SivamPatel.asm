	.data
height: 	.word	0
weight: 	.word	0
name: 		.space 20
prompt1: 	.asciiz	"What is your name? "
prompt2: 	.asciiz	"Please enter your height in inches: "
prompt3: 	.asciiz	"Please enter your weight in pounds (round to the nearest whole number): "
prompt4: 	.ascii 	", your bmi is: "
bmi:		.float  0
compare1: 	.float 18.5
compare2: 	.float 25
compare3: 	.float 30
underweight: 	.asciiz "This is considered underweight. \n"
normal: 	.asciiz "This is considered underweight. \n"
overweight: 	.asciiz "This is considered overweight. \n"
obese: 		.asciiz "This is considered obese. \n"

	.text
input:
	# prompt for name
	li $v0, 4
	la $a0, prompt1
	syscall

	# get user name
	li $v0, 8
	la $a0, name
	li $a1, 20
	syscall
	
	# ask user for height
	li $v0, 4
	la $a0, prompt2
	syscall
	
	# read user height input
	li $v0, 5
	syscall

	# save input
	sw $v0, height

	# ask user for weight
	li $v0, 4
	la $a0, prompt3
	syscall

	# read weight input
	li $v0, 5
	syscall

	# save weight value 
	sw $v0, weight

removeNewline:
	la $t0, name		# load name into register

	# loop to remove the newline (\n) character from the end of name
loop:
	lb $t1, ($t0)		# get address of current byte / character
	beq $t1, 10, remove	# check if current character is '\n'
	addi $t0, $t0, 1	# go to next character
	j loop			# keep going through loop

remove:	# remove '\n' character
	sb $zero, ($t0)	 
	
getBMI:
	# load height, weight, number 703 to registers
	lw $t0, height
	lw $t1, weight
	li $t2, 703

	mtc1 $t2, $f2		# move registers to c1 registers
	cvt.s.w $f2, $f2	# convert 703 to float (single precision)

	mtc1 $t1, $f1		# move weight to c1 register
	cvt.s.w $f1, $f1	# convert weight to float (single precision)

	mtc1 $t0, $f0		# move height to c1 registers
	cvt.s.w $f0, $f0	# convert height to float (single precision)

	mul.s $f1, $f1, $f2	# weight = weight * 703
	mul.s $f0, $f0, $f0	# height = height * height
	div.s $f1, $f1, $f0	# bmi = (weight * 703) / (height ^ 2)

	swc1 $f1, bmi		# save bmi
print:
	# orubt bane
	li $v0, 4
	la $a0, name
	syscall

	# print " your bmi is "
	li $v0, 4
	la $a0, prompt4
	syscall

	# print bmi
	li $v0, 2
	ldc1 $f12, bmi
	syscall

	# newline
	li $v0, 11
	li $a0, 10
	syscall
	
compare:
	# load comarpison variables into registers
	l.s $f2 compare1
	l.s $f3 compare2
	l.s $f4 compare3

	# check if bmi < 18.5
	c.lt.s $f1, $f2
	bc1t print1

	# check if bmi < 25
	c.lt.s $f1, $f3
	bc1t print2

	# check if bmi < 30
	c.lt.s $f1, $f4
	bc1t print3

	# print message saying user weight is obese
	li $v0, 4
	la $a0, obese
	syscall

	j exit

print1:	# print message saying user is underweight
	li $v0, 4
	la $a0, underweight
	syscall 

	j exit

print2:	# print message saying user is normal weight
	li $v0, 4
	la $a0, normal
	syscall 

	j exit

print3:	# print message saying user is overweight
	li $v0, 4
	la $a0, overweight
	syscall

exit: # exit program
	li $v0, 10
	syscall
