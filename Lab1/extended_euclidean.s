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
    # prologue - save only $a0 and $a1
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $a0, 4($sp)
    sw $a1, 0($sp)

    move $t0, $a0    # a
    move $t1, $a1    # b
    li   $t2, 0      # x0
    li   $t3, 1      # x1

    li   $t5, 1
    beq  $t1, $t5, inverse_is_1

mod_loop:
    ble  $t0, 1, done_inverse  # while a > 1

    div  $t0, $t1
    mflo $t6       # q = a / b
    mfhi $t7       # a % b

    move $t8, $t1  # temp = b
    move $t1, $t7  # b = a % b
    move $t0, $t8  # a = temp

    move $t8, $t2         # temp = x0
    mul  $t9, $t6, $t2    # q * x0
    sub  $t2, $t3, $t9    # x0 = x1 - q*x0
    move $t3, $t8         # x1 = temp

    j mod_loop

#gcd(a, b) ≠ 1
done_inverse:
    li   $t5, 1
    bne  $t0, $t5, no_inverse

    # if x1 < 0, x1 = x1 + b
    bltz $t3, fix_negative
    move $v0, $t3
    j restore

# x1 = x1 + b
fix_negative:
    add  $v0, $t3, $a1
    j restore

inverse_is_1:
    li $v0, 1
    j restore

no_inverse: # Does not exists
    li $v0, -1

restore:
    lw $ra, 8($sp)
    lw $a0, 4($sp)
    lw $a1, 0($sp)
    addi $sp, $sp, 12
    jr $ra
