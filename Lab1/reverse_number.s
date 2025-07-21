.data
	input_msg: .asciiz "Enter a number: "
	output_msg: .asciiz "Reversed number: "
	newline: .asciiz "\n"

.text
.globl main
#------------------------- main -----------------------------
main:
# print input_msg on the console interface
    li      $v0, 4				# call system call: print string
	la      $a0, input_msg		# load address of string into $a0
	syscall               	    # run the syscall

# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a0, $v0      		# store input in $a0 (set arugument of procedure)

#TODO call recerse_loop
	jal     reverse             
    move    $t0, $v0            # save return value to $t0

# print output_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg		# load address of string into $a0
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

#------------------------- procedure reverNumber -----------------------------
.text
reverse:
	addi    $sp, $sp, -8           # reserve space on stack
    sw      $ra, 4($sp)            # save return address
    sw      $a0, 0($sp)            # save argument

    move    $t1, $a0               # load n to $t1
    li      $t0, 0                 # reverse = 0
	li      $t2, 10                # set $t2 = 10

reverse_loop:
    beq     $t1, $zero, done    # while(n != 0)
    divu    $t1, $t2            # t1 / 10 #! (remainder->hi, quotient->lo)
    mfhi    $t3                 # digit = n % 10
    mflo    $t1                 # n = n / 10 
    mul     $t0, $t0, 10        # reverse *= 10
    add     $t0, $t0, $t3       # reverse += digit
    j       reverse_loop

done:
    move    $v0, $t0            # return value = reverse
    addi    $sp, $sp, 8
    jr      $ra