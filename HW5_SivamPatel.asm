	.data
arr:		.space 	80
buffer:		.space	80
mean:		.float 	0
stdDeviation:	.float	0
fileName:	.asciiz	"input.txt"
errorMessage:	.asciiz "File could not be read."
arrBeforeSort:	.asciiz "The array before: "
arrAfterSort:	.asciiz "The array after: "
meanOutput:	.asciiz "The mean is: "
medianOutput:	.asciiz "The median is: "
sdOutput:	.asciiz "The Standard Deviation is: "

	.text
main:	# set a0 and a1
	la $a0, fileName
	la $a1, buffer
	jal readFile # read data from file

	# check if file could be opened and read from
	slti $t0, $v0, 1
	bne $t0, $zero, error
	
	# take values from buffer and put into array
	la $a0, arr
	li $a1, 20
	la $a2, buffer
	jal bufferToArray

	# prompt to print array before sort
	li $v0, 4
	la $a0, arrBeforeSort
	syscall
	
	# print unsorted array
	la $a0, arr
	li $a1, 20
	jal printArray

	la $a0, arr
	li $a1, 20
	jal sort # sort array
	
	# print prompt for sorted array
	li $v0, 4
	la $a0, arrAfterSort
	syscall
	
	#print sorted array
	la $a0, arr
	li $a1, 20
	jal printArray

	# calculate mean of array
	la $a0, arr
	li $a1, 20
	jal calcMean

	# print prompt for mean output
	li $v0, 4
	la $a0, meanOutput
	syscall

	# print mean
	li $v0, 2
	lwc1 $f12, mean
	syscall
	
	# print newline
	li $v0, 11
	li $a0, 10
	syscall

	# print prompt for median 
	li $v0, 4
	la $a0, medianOutput
	syscall
	
	# calculate median of array
	la $a0, arr
	li $a1, 20
	jal calcMedian
	
	# check if median is float / int ($v1 is 1 is float, 0 if int)
	bne $v1, $zero, printFloat
	
	# print median if int
	move $a0, $v0
	li $v0, 1
	syscall
	
	j SD # skip printFloat and go to Standard Deviation

printFloat: # print median if float
	li $v0, 2
	mov.s $f12, $f0
	syscall

SD:	# calculate standard deviation
	la $a0, arr
	li $a1, 20
	jal calcSD
	
	swc1 $f0, stdDeviation # save value to memory
	
	li $v0, 11
	li $a0, 10
	syscall
	
	li $v0, 4
	la $a0, sdOutput
	syscall

	li $v0, 2
	mov.s $f12, $f0
	syscall

	j exit # end program

readFile:
	move $t0, $a1 # save memory address of buffer

	# open file
	li $v0, 13
	li $a1, 0
	li $a2, 0 
	syscall
	
	move $s0, $v0 # save file descriptor

	# read file contents into buffer
	li $v0, 14
	move $a0, $s0
	move $a1, $t0
	li $a2, 80
	syscall
	
	move $t0, $v0 # save number of characters read for error checking

	#close file
	li $v0, 16
	move $a0, $s0
	syscall
	
	move $v0, $t0 # reset number of characters read from earlier syscall

	jr $ra # return to main

bufferToArray:
	move $t1, $a2 # memory address of buffer
	move $t0, $a0 # address of new array
	sll $a1, $a1, 2 # number of bytes needed in array
	add $s7, $t0, $a1 # address of final value in array

	li $t3, 0	# keep track of 10 * x
	li $t2, 10

loopThroughArray:
	lb $t4, ($t1)	# load current byte
	slti $t5, $t4, 48 	# check if (not x < 48) && (x < 58) 
	bne $t5, $zero, incrementNotDigit 
	slti $t5, $t4, 58
	beq $t5, $zero, incrementNotDigit

	subi $t4, $t4, 48 # get int value of digit

	mult $t3, $t2 # 10 * x
	mflo $t6

	addi $t3, $t3, 1 # x++

	lw $t7, ($t0)

	mult $t6, $t7 
	mflo $t6

	add $t6, $t6, $t4 # get new value of int

	sw $t6, ($t0) # save int to memory

	j incrementAll 

incrementNotDigit: # if current byte not a digit, move to next index in array
	addi $t0, $t0, 4
	add $t3, $zero, $zero

incrementAll: # increment values through loop
	addi $t1, $t1, 1
	beq $t0, $s7, endArray # check if at end of array

	j loopThroughArray
	
endArray: # return to main
	jr $ra 

printArray: 
	move $t0, $a0
	sll $a1, $a1, 2 # get number of bytes using size of array
	add $t1, $t0, $a1 # get address of final value in array

printLoop: 
	# print each value in array
	lw $t2, ($t0)
	li $v0, 1
	move $a0, $t2
	syscall
	
	# print space ' ' between values
	li $v0, 11
	li $a0, 32
	syscall
	
	addi $t0, $t0, 4 	# move to next int in array
	
	bne $t0, $t1, printLoop	# keep looping through array

	# print newline 
	li $v0, 11
	li $a0, 10
	syscall

	jr $ra
sort:
	move $t0, $a0
	sll $a1, $a1, 2
	add $t1, $t0, $a1 # end of array
	li $t4, 20 # number of total iterations needed 
	li $t5, 0 #number of iterations

sortLoop:
	move $t2, $t0 # current place to start iteration from
	move $t3, $t0 # address of lowest value

innerLoop: # find lowest value in array
	lw $t6, ($t3)
	lw $t7, ($t2)

	slt $t8, $t7, $t6 # check if arr[x] < min 

	beq $t8, $zero, continue

setLowest: 
	move $t3, $t2 # set x to new min

continue:
	addi $t2, $t2, 4 
	bne $t2, $t1, innerLoop

	# swap lowest value with value at arr[x]
	lw $t6, ($t3) # lowest value
	lw $t7, ($t0) # current value at smallest index
	sw $t7, ($t3) 
	sw $t6, ($t0)  

	addi $t0, $t0, 4 
	bne $t0, $t1, sortLoop

	jr $ra

calcMean:
	li $t0, 0 # sum of all elements
	move $t1, $a0
	move $t9, $a1
	sll $a1, $a1, 2
	add $t2, $t1, $a1 # address of final value in array
	
meanLoop: 
	# loop through array and add values to $t0
	lw $t3, ($t1)
	add $t0, $t0, $t3
	addi $t1, $t1, 4
	bne $t1, $t2, meanLoop
	
	# convert values to float
	mtc1 $t0, $f0
	cvt.s.w $f0, $f0

	# get number of elements in floatint point format
	move $t1, $t9
	mtc1 $t1, $f1
	cvt.s.w $f1, $f1 

	div.s $f0, $f0, $f1 # sum / (num elements)
	swc1 $f0, mean # save mean to memory

	jr $ra	

calcMedian:
	move $t1, $a1
	move $t0, $a0
	li $t2, 2
	div $t1, $t2 # divide (num elements) / 2
	mfhi $t2 
	beq $t2, $zero, evenMedian # check if remainder is 0 or 1 (odd or even num elements)

oddMedian:
	mflo $t2 # find middle element 
	sll $t2, $t2, 2
	add $t0, $t0, $t2 # address of middle value
	
	lw $v0, ($t0) # get middle element and return in $v0
	li $v1, 0  # $v1 0 if median is integer, 1 is median is float

	jr $ra

evenMedian:
	mflo $t2
	addi $t3, $t2, -1 # get middle 2 elements ($t2 and $t3)
	
	# get memory addresses of middle 2 elements
	sll $t2, $t2, 2
	sll $t3, $t3, 2
	add $t2, $t0, $t2
	add $t3, $t0, $t3 
	
	# get both middle values
	lw $t4, ($t2)
	lw $t5, ($t3)
	li $t2, 2 # int for dividing by 2

	# convert middle values to float
	mtc1 $t4, $f0
	mtc1 $t5, $f2
	mtc1 $t2, $f4
	cvt.s.w $f0, $f0
	cvt.s.w $f2, $f2
	cvt.s.w $f4, $f4

	# take average of middle values
	add.s $f0, $f0, $f2 
	div.s $f0, $f0, $f4 # (sum of middle) / 2.0

	li $v1, 1 # set flag to return float, return float in $f0

	jr $ra

calcSD:
	move $t0, $a0 # start of array
	move $t1, $a1
	sll $t1, $t1, 2
	add $t1, $t0, $t1 # end of array
	mtc1 $zero, $f0 # $f0 = 0 , set sum of all (x - mean)^2 to zero
	cvt.s.w $f0, $f0
	l.s $f1, mean # get value of mean

sdloop: # loop through array 
	lw $t2, ($t0)
	mtc1 $t2, $f2 # convert each value to float
	cvt.s.w $f2, $f2
	sub.s $f2, $f2, $f1 # x - mean
	mul.s $f2, $f2, $f2 # (x - mean) ^ 2
	add.s $f0, $f0, $f2 # keep sum of all (x - mean) ^ 2
	addi $t0, $t0, 4 # move to next value in array
	bne $t0, $t1, sdloop # check if at end of array

	addi $a1, $a1, -1 # n - 1

	# convert n - 1 to float
	mtc1 $a1, $f2
	cvt.s.w $f2, $f2

	div.s $f0, $f0, $f2 # (x - avg) ^ 2 / 19
	sqrt.s $f0, $f0 # sqrt of variance

	jr $ra

error:	#print error message and exit program
	li $v0, 4
	la $a0, errorMessage
	syscall

exit:
	li $v0, 10
	syscall
