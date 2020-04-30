		.data

weights:		.space 1024
values:			.space 1024
tmp_values:		.space 1024
tmp_positions:		.space 1024
backpack_msg:		.asciiz "Enter the weight the backpack can bear: "
backpack_err:		.asciiz "Warning! The entered value must be greater than 0\n"
object_msg:		.asciiz "\nObject "
weight_msg:		.asciiz "\nEnter the weight of the object (enter 0 to exit): "
weight_err:		.asciiz "Warning! The weight must be 0 (to exit) or a positive number"
value_msg:		.asciiz "Enter the value of the object: "
value_err:		.asciiz "Warning! The value must be between 1 and 10!\n"
final_object_msg:	.asciiz "\nObjects brought: "
final_weight_msg:	.asciiz "\nTotal weight: "
final_value_msg:	.asciiz "\nTotal value: "
no_object_msg:		.asciiz "no object"
space:			.asciiz " "

		.text

start:			la $s2, weights
			la $s3, values
			la $s4, tmp_values
			la $s5, tmp_positions
			move $t2, $s2
			move $t3, $s3
			move $t4, $s4
			move $t5, $s5

backpack:		li $v0, 4
			la $a0, backpack_msg
			syscall
			li $v0, 5
			syscall
			blez $v0, error_backpack
			move $s0, $v0
			move $t0, $s0
			move $t1, $zero

object:			addiu $t1, $t1, 1
			li $v0, 4
			la $a0, object_msg
			syscall
			li $v0, 1
			move $a0, $t1
			syscall

weight:			li $v0, 4
			la $a0, weight_msg
			syscall
			li $v0, 5
			syscall
			beqz $v0, revision
			bltz $v0, error_weight
			sw $v0, 0($t2)
			addiu $t2, $t2, 4

value:			li $v0, 4
			la $a0, value_msg
			syscall
			li $v0, 5
			syscall
			blez $v0, error_value
			bgtu $v0, 10, error_value
			sw $v0, 0($t3)
			sw $v0, 0($t4)
			addiu $t3, $t3, 4
			addiu $t4, $t4, 4
			j object

revision:		subu $t1, $t1, 1
			move $s1, $t1
			beqz $s1, init_print
			subu $t1, $t1, 1
			mul $t1, $t1, 4
			move $s6, $t1
			move $t9, $zero

init:			move $t1, $zero
			move $t2, $zero
			move $t3, $zero
			move $t6, $zero
			move $t4, $s4
			move $t7, $zero
			move $t8, $zero
			lw $t2, 0($t4)
			addu $t8, $t8, $t2

research:		beq $t2, 10, evaluate
			sltu $t7, $t6, $s6
			beqz $t7, evaluate
			addiu $t4, $t4, 4
			addiu $t6, $t6, 4
			lw $t1, 0($t4)
			addu $t8, $t8, $t1
			bgtu $t1, $t2, update_max
			j research

evaluate:		beqz $t8, ordina
			move $t7, $zero
			addu $t7, $s2, $t3
			lw $t1, 0($t7)
			bgtu $t1, $t0, reset
			sw $t3, 0($t5)
			addiu $t5, $t5, 4
			addiu $t9, $t9, 1
			subu $t0, $t0, $t1
			beqz $t0, sort

reset:			addu $t4, $s4, $t3
			sw $zero, 0($t4)
			j init

sort:			move $s7, $t0
			move $t0, $zero
			move $t1, $zero
			move $t2, $zero

init_sort:		beq $t2, $t9, init_print
			move $t3, $t2
			move $t4, $t2
			mul $t2, $t2, 4
			addu $t5, $s5, $t2
			lw $t0, 0($t5)

research_min:		addiu $t4, $t4, 1
			beq $t4, $t9, save_sort
			addiu $t5, $t5, 4
			lw $t1, 0($t5)
			bltu $t1, $t0, update_min
			j research_min

save_sort:		beq $t2, $t3, update_cycle
			addu $t5, $s5, $t2
			lw $t6, 0($t5)
			sw $t0, 0($t5)
			mul $t3, $t3, 4	
			addu $t5, $s5, $t3
			sw $t6, 0($t5)

update_cycle:		div $t2, $t2, 4
			addiu $t2, $t2, 1
			j init_sort

update_min:		move $t0, $t1
			move $t3, $t4
			j research_min

init_print:		move $t0, $zero
			move $t1, $zero
			move $t4, $zero
			move $t5, $s5
			move $t6, $zero
			move $t7, $zero
			li $v0, 4
			la $a0, final_object_msg
			syscall
			beqz $t9, print_empty

print_object:		beq $t6, $t9, print_wieght_value
			move $t2, $s2
			move $t3, $s3
			lw $t4, 0($t5)
			addu $t2, $t2, $t4
			lw $t7, 0($t2)
			addu $t0, $t0, $t7
			addu $t3, $t3, $t4
			lw $t7, 0($t3)
			addu $t1, $t1, $t7
			addiu $t4, $t4, 4
			addiu $t5, $t5, 4
			addiu $t6, $t6, 1
			li $v0, 1
			move $a0, $t4
			divu $a0, $a0, 4
			syscall
			li $v0, 4
			la $a0, space
			syscall
			j print_object

print_empty:		li $v0, 4
			la $a0, no_object_msg
			syscall

print_wieght_value:	li $v0, 4
			la $a0, final_weight_msg
			syscall
			li $v0, 1
			move $a0, $t0
			syscall
			li $v0, 4
			la $a0, final_value_msg
			syscall
			li $v0, 1
			move $a0, $t1
			syscall

exit:			j exit

error_backpack:		li $v0, 4
			la $a0, backpack_err
			syscall
			j backpack

error_weight:		li $v0, 4
			la $a0, weight_err
			syscall
			j weight

error_value:		li $v0, 4
			la $a0, value_err
			syscall
			j value

update_max:		move $t2, $t1
			move $t3, $t6
			j research