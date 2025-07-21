.data
	input_msg:     .asciiz "Enter the number: "
    input_msg2:    .asciiz "Enter the modulo: "
    not_exist:     .asciiz "Inverse not exist.\n"
    output_msg:    .asciiz "Result: "
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
	move    $t0, $v0      		# store input in $a0 (set arugument of procedure factorial)

# print input_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg2		# load address of string into $a0
	syscall                 	# run the syscall
 
# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $t1, $v0      		# store input in $a1 (set arugument of procedure factorial)

#TODO store a and b in argument registers
    move $a0, $t0      # a
    move $a1, $t1      # b

#TODO jump to procedure factorial
	jal 	mod_inverse
	move 	$t2, $v0			# save return value in t0 (because v0 will be used by system call) 

#TODO check if $v0 == -1
    li $t3, -1
    beq $t2, $t3, print_not_exist

# print output_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg		# load address of string into $a0
	syscall                 	# run the syscall

# print the result of procedure factorial on the console interface
	li 		$v0, 1				# call system call: print int
	move 	$a0, $t2			# move value of integer into $a0
	syscall 					# run the syscall

# print a newline at the end
	li		$v0, 4				# call system call: print string
	la		$a0, newline		# load address of string into $a0
	syscall						# run the syscall

    j       exit

#TODO does not exists
print_not_exist:
    li $v0, 4
    la $a0, not_exist
    syscall

# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall

#------------------------- procedure mod_inverse -----------------------------
# load argument n in $a0, return value in $v0.
.text
mod_inverse:
    # prologue
    addi $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)  # a
    sw $s1, 20($sp)  # b
    sw $s2, 16($sp)  # b0
    sw $s3, 12($sp)  # x0
    sw $s4, 8($sp)   # x1
    sw $s5, 4($sp)   # q

    move $s0, $a0    # a
    move $s1, $a1    # b
    move $s2, $a1    # b0 = b
    li $s3, 0        # x0 = 0
    li $s4, 1        # x1 = 1

    li $t0, 1
    beq $s1, $t0, inv_is_1

mod_loop:
    ble $s0, 1, done_inverse  # while a > 1

    div $s0, $s1
    mflo $s5     # q = a / b
    mfhi $t1     # a % b

    move $t2, $s1   # t = b
    move $s1, $t1   # b = a % b
    move $s0, $t2   # a = t

    move $t2, $s3   # t = x0
    mul $t3, $s5, $s3  # q * x0
    sub $s3, $s4, $t3  # x0 = x1 - q*x0
    move $s4, $t2      # x1 = t

    j mod_loop

done_inverse:
    li $t0, 1
    bne $s0, $t0, no_inverse  # if (a != 1) return -1

    # if x1 < 0, x1 += b0
    bltz $s4, fix_negative
    move $v0, $s4
    j restore

fix_negative:
    add $s4, $s4, $s2
    move $v0, $s4
    j restore

inv_is_1:
    li $v0, 1
    j restore

no_inverse:
    li $v0, -1

restore:
    lw $ra, 28($sp)
    lw $s0, 24($sp)
    lw $s1, 20($sp)
    lw $s2, 16($sp)
    lw $s3, 12($sp)
    lw $s4, 8($sp)
    lw $s5, 4($sp)
    addi $sp, $sp, 32
    jr $ra