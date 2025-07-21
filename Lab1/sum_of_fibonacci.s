.data
	input_msg:     .asciiz "Please input a number: "
    output_msg:    .asciiz "The sum of Fibonacci(0) to Fibonacci("
    output_msg2:  .asciiz ") is: "
    newline:       .asciiz "\n"

.text
.globl main
#------------------------- main -----------------------------
main:
# print input_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg		# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a1, $v0      		# store input in $a1 (store read integer n)
    move    $a0, $v0            # store input in $a1 (set arugument of procedure)

#TODO jump to procedure factorial
	jal 	fibonacciSum
	move 	$t0, $v0			# save return value in t0 (because v0 will be used by system call) 

# print output_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg		# load address of string into $a0
	syscall                 	# run the syscall

#TODO print the read integer n
	li 		$v0, 1				# call system call: print int
	move 	$a0, $a1			# move value of integer into $a0
	syscall 					# run the syscall

#TODO print output_msg2 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg2	# load address of string into $a0
	syscall                 	# run the syscall

# print the result of procedure factorial on the console interface
	li 		$v0, 1				# call system call: print int
	move 	$a0, $t0			# move value of integer into $a0
	syscall 					# run the syscall

# print a newline at the end
	li		$v0, 4				# call system call: print string
	la		$a0, newline		# load address of string into $a0
	syscall						# run the syscall

# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall

#------------------------- procedure fibonacciSum -----------------------------
# load argument n in $a0, return value in $v0.
.text
fibonacciSum:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)      # n

    li $s0, 0           # sum = 0
    li $s1, 0           # i = 0
    move $s2, $a0       # $s2 = n

fibonacciSum_loop:
    bgt $s1, $s2, done
    move $a0, $s1       # $a0 = i
    jal fibonacci       # call fibonacci(i)
    add $s0, $s0, $v0   # sum += fibonacci(i)
    addi $s1, $s1, 1    # i++
    j fibonacciSum_loop

done:
    move $v0, $s0       # return sum in $v0
    lw $ra, 4($sp)
    lw $a0, 0($sp)
    addi $sp, $sp, 8
    jr $ra

#------------------------- procedure fibonacci -----------------------------
# load argument n in $a0, return value in $v0.
.text
fibonacci:
    addi $sp, $sp, -16
    sw $s1, 12($sp)
    sw $s0, 8($sp)
    sw $ra, 4($sp)
    sw $a0, 0($sp)

    li $v0, 0
    beq $a0, $zero, exit  # if (n == 0) return 0

    li $t0, 1
    li $v0, 1
    beq $a0, $t0, exit    # if (n == 1) return 1

    # compute fibonacci(n - 1)
    addi $a0, $a0, -1
    jal fibonacci
    move $s0, $v0             # t1 = fib(n-1)

    # compute fibonacci(n - 2)
    lw $a0, 0($sp)
    addi $a0, $a0, -2
    jal fibonacci
    move $s1, $v0             # t2 = fib(n-2)

    # fib(n) = fib(n-1) + fib(n-2)
    add $v0, $s0, $s1

exit:
    lw $s1, 12($sp)
    lw $s0, 8($sp)
    lw $ra, 4($sp)
    lw $a0, 0($sp)
    addi $sp, $sp, 16
    jr $ra