.eqv	WHITE		0xffffff
.eqv	START		0x1000BBFC
.eqv	INITIAL		0x10008000
.eqv	END		1036
.eqv	ROW_LEN		256
.eqv 	YELLOW		0xffff00
 
.text
.globl main

main:
	li $a1, INITIAL 
	li $t1, 0
	
	mainloop:
		jal drawbox 
		addi $t1, $t1, 4
		li $v0, 32
		li $a0, 400000
		clearbox:
	# clear previous square, starting from four rows above, three cols to the left
			addi	$a1, $a1, -ROW_LEN
			addi	$a1, $a1, -ROW_LEN
			addi	$a1, $a1, -ROW_LEN
			li	$a2, INITIAL
			addi	$a2, $a2, END
			addi	$a2, $a2, ROW_LEN
			addi	$a2, $a2, ROW_LEN
			addi	$a2, $a2, ROW_LEN
			li	$a3, -48
			jal	clear
		# ------------------------------------
		blt $t1, 512, mainloop
		
		
	j end

drawbox:
	li $t0, WHITE
	sw $t0, 0($a1)
	sw $t0, 4($a1)
	sw $t0, 8($a1)
	addi $a1, $a1, ROW_LEN
	sw $t0, 0($a1)
	sw $t0, 8($a1)
	addi $a1, $a1, ROW_LEN
	sw $t0, 0($a1)
	sw $t0, 8($a1)
	addi $a1, $a1, ROW_LEN
	sw $t0, 0($a1)
	sw $t0, 4($a1)
	sw $t0, 8($a1)
	jr $ra



# ------------------------------------
# clear screen between given addresses
	# $a1: start address
	# $a2: end address
	# $a3: negative of the width*4 of box to clear

clear:
	li	$t8, YELLOW
	li	$t9, 0								# increment
	
	clear_loop:
		bgt	$a1, $a2, clear_loop_done
		# if the increment is equal to the negative width, go down a row
		beq	$t9, $a3, clear_loop_next_row
		sw	$t8, 0($a1)						# clear $a0 colour
		addi	$a1, $a1, 4						# $a0 = $a0 + 4
		addi	$t9, $t9, -4						# $t9 = $t9 - 4
		j	clear_loop						# jump to clear_loop
	clear_loop_next_row:
		add	$a1, $a1, $t9						# $a0 = $a0 - width*4
		addi	$a1, $a1, ROW_LEN				# set $a0 to next row
		li	$t9, 0							# reset increment $t9 = 0
		j clear_loop
	clear_loop_done:
		jr	$ra							# jump to $ra
	

end:
	li $v0 ,10
	syscall
