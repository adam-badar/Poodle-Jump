#####################################################################
#
# CSCB58 Winter 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Adam Badar, 1007965338, badarada, adam.badar@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 512 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# $t0
#
#####################################################################

# width = 64, height = 128
.eqv 	BASE_ADDRESS 	0x10008000
.eqv	END_ADDRESS	0x1000FFFC	#4*(64*128-1)
.eqv	TOP_RIGHT	0x100080F8
.eqv	INITIAL_POODLE	0x1000BBFC	#4*(60*64-1)
.eqv	SHIFT_SHIP_LAST	1324	
.eqv	ROW_LEN		256
.eqv	WAIT_TIME	30 

#Colours
.eqv	WHITE		0xffffff
.eqv	RED		0xff0000
.eqv	GREEN		0x00ff00
.eqv	BLUE		0x0000ff
.eqv	YELLOW		0xffff00
.eqv	CYAN		0x00ffff
.eqv	MAGENTA		0xff00ff
.eqv	ORANGE		0xff7e00
.eqv	PURPLE		0x7e00ff
.eqv	PINK		0xff007e
.eqv	BROWN		0x7e3f00
.eqv	GREY		0x7e7e7e
.eqv	BLACK		0x000000

.data
backgroundArr: .word 0x6fb1ff:1024
	
.text
.globl main

#POODLE-JUMP :))


main: 
	li	$a0, BASE_ADDRESS		# $a0 stores the base address for display
	li	$a1, END_ADDRESS	# 
	li	$a2, -ROW_LEN			# negative width
	#jal	clear				# jump to clear and save position to $ra
	
	#................................#
	# GLOBAL variables
		# $s0: previous character location
		# $s1: current character location
		# $s2: platform shift increment
		# $s3: 1 if collision happened, 0 if not
		# $s4: clock (number of frames played)
		# $s5: 
		# $s6: wait time (decreases as time goes on)
		# $s7: wait clock

	# main variables
		# $t9: temp
	#................................#
	#Initialization
		#poodle location
		li $s1, INITIAL_POODLE
		li $s0, END_ADDRESS
		addi $s0, $s0, -ROW_LEN
		li $s3, 0
		li $s4, -1
		li $s6, WAIT_TIME
		li $s7, WAIT_TIME
		
	mainLoop:
	#Get input from keyboard
		
		
	#Erase objects from old position
		beq $s3, $zero, mainClear
		
		mainClear:
			move $a0, $s0
			addi	$a0, $a0, -ROW_LEN
			addi	$a0, $a0, -ROW_LEN
			move	$a1, $s0
			addi	$a1, $a1, SHIFT_SHIP_LAST
			addi	$a1, $a1, ROW_LEN
			addi	$a1, $a1, ROW_LEN
			li	$a2, -48
			jal	clear	
	
		main_draw:
			# redraw ship:
			move	$a0, $s1
			jal	drawPoodle					# jump to draw_ship and save position to $ra
			move 	$s0, $s1
		mainSleep:
			li $v0, 32
			move $a0, $s6
			syscall
		j mainLoop
		


# ------------------------------------
# handling different keypresses
	# $a0: 0xfff0000
	# use:
		# $t1: width
		# $t2: address of first of second row
		# $t3: address of last of second last row 
		# $t
		# $t9: temp
keypress:
	li	$t1, ROW_LEN
	li	$t2, BASE_ADDRESS
	addi	$t2, $t2, ROW_LEN
	li	$t3, END_ADDRESS
	addi	$t3, $t3, -SHIFT_SHIP_LAST
	addi	$t3, $t3, -ROW_LEN
	
	lw	$t0, 4($a0)
	beq	$t0, 0x61, key_a						# ASCII code of 'a' is 0x61 or 97 in decimal
	beq	$t0, 0x77, key_w						# ASCII code of 'w' is 0x77
	beq	$t0, 0x64, key_d						# ASCII code of 'd' is 0x64
	beq	$t0, 0x73, key_s						# ASCII code of 's' is 0x73
	beq	$t0, 0x70, key_p						# ASCII code of 'p' is 0x70

	# go left
	key_a:
		# make sure ship is not in left column
		div	$s1, $t1						# see if ship position is divisible by the width
		mfhi	$t9							# $t9 = $s1 mod $t1 
		beq	$t9, $zero, keypress_done				# if it is in the left column, we can't go left
		addi	$s1, $s1, -8						# else, move left
		b keypress_done

	# go up
	key_w:
		# make sure ship is not in top row
		blt	$s1, $t2, keypress_done					# if $s1 is in the top row, don't go up
		addi	$s1, $s1, -ROW_LEN				# else, move up
		addi	$s1, $s1, -ROW_LEN				# else, move up
		b keypress_done

	# go right
	key_d:
		# make sure ship is not in right column
		div	$s1, $t1						# see if ship position is divisible by the width
		mfhi	$t9							# $t9 = $s1 mod $t1 
		addi	$t1, $t1, -48						# need to check if the mod is the row size - 12*4 (width of plane-1)
		beq	$t9, $t1, keypress_done					# if it is in the far right column, we can't go right
		addi	$s1, $s1, 8						# else, move right
		b keypress_done

	# go down
	key_s:
		# make sure ship is not in bottom row
		bgt	$s1, $t3, keypress_done					# if $s1 is in the bottom row, don't go down
		addi	$s1, $s1, ROW_LEN				# else, move down
		addi	$s1, $s1, ROW_LEN				# else, move down
		b keypress_done

	key_p:
		# restart game
		la	$ra, main
		b keypress_done

	keypress_done:
		jr	$ra							# jump to ra
# ------------------------------------

# clear screen between given addresses
	# $a0: start address
	# $a1: end address
	# $a2: negative of the width*4 of box to clear
	# useS:
		# $t8: COLOUR_NIGHT
		# $t9: negative increment
clear:
	li	$t8, BLUE
	li	$t9, 0								# increment
	
	clear_loop:
		bgt	$a0, $a1, clear_loop_done
		# if the increment is equal to the negative width, go down a row
		beq	$t9, $a2, clear_loop_next_row
		sw	$t8, 0($a0)						# clear $a0 colour
		addi	$a0, $a0, 4						# $a0 = $a0 + 4
		addi	$t9, $t9, -4						# $t9 = $t9 - 4
		j	clear_loop						# jump to clear_loop
	clear_loop_next_row:
		add	$a0, $a0, $t9						# $a0 = $a0 - width*4
		addi	$a0, $a0, ROW_LEN				# set $a0 to next row
		li	$t9, 0							# reset increment $t9 = 0
		j clear_loop
	clear_loop_done:
		jr	$ra							# jump to $ra
# ------------------------------------

return:	jr $ra

# end program
end:
	jal	draw_dead
	# darken screen
	li	$v0, 10								# $v0 = 10 terminate the program gracefully
	syscall

#....................................#

# ------------------------------------
# draw GAME OVER
	# uses:
		# $a0: DISPLAY_DEAD
		# $a1: COLOUR_NUMBER
		# #t9: hold old $ra
draw_dead:
	li	$a1, WHITE
	move 	$t9, $ra

	li	$a0, TOP_RIGHT
	jal	drawG
	li	$a0, TOP_RIGHT
	addi	$a0, $a0, 20
	jal	drawA
	li	$a0, TOP_RIGHT
	addi	$a0, $a0, 40
	jal	drawM
	li	$a0, TOP_RIGHT
	addi	$a0, $a0, 60
	jal	drawE
	li	$a0, TOP_RIGHT
	addi	$a0, $a0, 60
	jal	drawO
	li	$a0, TOP_RIGHT
	addi	$a0, $a0, 60
	jal	drawV
	li	$a0, TOP_RIGHT
	addi	$a0, $a0, 60
	jal	drawE
	li	$a0, TOP_RIGHT
	addi	$a0, $a0, 60
	jal	drawR

	jr	$t9
# ------------------------------------

#DRAW FUNCTIONS
drawG:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, WHITE
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	sw $t8, 24($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 24($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 24($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	jal return

drawA: 
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, WHITE
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	jal return

drawM: 
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, WHITE
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	jal return 

drawE:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, WHITE
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	jal return 

drawO: 
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, WHITE
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	jal return

drawV:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, WHITE
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	jal return

drawR:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, WHITE
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 16($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 16($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 16($a0)
	
drawRedBlock:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, RED
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	sw $t8, 24($a0)
	sw $t8, 28($a0)
	sw $t8, 32($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	sw $t8, 24($a0)
	sw $t8, 28($a0)
	sw $t8, 32($a0)
	jal return

drawBrownBlock:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, BROWN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	sw $t8, 24($a0)
	sw $t8, 28($a0)
	sw $t8, 32($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	sw $t8, 24($a0)
	sw $t8, 28($a0)
	sw $t8, 32($a0)
	jal return
	
drawOrangeBlock:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, ORANGE
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	sw $t8, 24($a0)
	sw $t8, 28($a0)
	sw $t8, 32($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	sw $t8, 24($a0)
	sw $t8, 28($a0)
	sw $t8, 32($a0)
	jal return

drawCyanBlock:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, CYAN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	sw $t8, 24($a0)
	sw $t8, 28($a0)
	sw $t8, 32($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	sw $t8, 24($a0)
	sw $t8, 28($a0)
	sw $t8, 32($a0)
	jal return

drawSpike:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, WHITE
	sw $t8, 0($a0)
	sw $t8, 8($a0)
	sw $t8, 16($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 8($a0)
	sw $t8, 16($a0)
	jal return

drawSpring:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, WHITE
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 4($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 8($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	jal return

drawJetpack:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, WHITE
	li $t9, YELLOW
	sw $t9, 4($a0)
	sw $t9, 16($a0)
	addi $a0, $a0, ROW_LEN
	sw $t9, 0($a0)
	sw $t9, 8($a0)
	sw $t9, 12($a0)
	sw $t9, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 4($a0)
	sw $t8, 16($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 4($a0)
	sw $t8, 16($a0)
	jal return

drawHole:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, WHITE
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	sw $t8, 24($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	sw $t8, 24($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 0($a0)
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	sw $t8, 24($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	addi $a0, $a0, ROW_LEN
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	addi $a0, $a0, ROW_LEN
	


drawSadPoodle:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t0, PINK
	li $t1, WHITE
	li, $t2, GREY
	li, $t3, CYAN
	sw $t1, 20($a0)
	sw $t1, 24($a0)
	sw $t1, 28($a0)
	sw $t1, 32($a0)
	sw $t1, 36($a0)
	sw $t1, 40($a0)
	sw $t1, 44($a0)
	addi $a0, $a0, ROW_LEN
	sw $t1, 16($a0)
	sw $t0, 20($a0)
	sw $t0, 24($a0)
	sw $t0, 28($a0)
	sw $t0, 32($a0)
	sw $t0, 36($a0)
	sw $t0, 40($a0)
	sw $t0, 44($a0)
	sw $t1, 48($a0)
	addi $a0, $a0, ROW_LEN 
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	sw $t1, 12($a0)
	sw $t0, 16($a0)
	sw $t0, 20($a0)
	sw $t0, 24($a0)
	sw $t0, 28($a0)
	sw $t0, 32($a0)
	sw $t0, 36($a0)
	sw $t0, 40($a0)
	sw $t0, 44($a0)
	sw $t0, 48($a0)
	sw $t1, 52($a0)
	sw $t1, 56($a0)
	sw $t1, 60($a0)
	addi $a0, $a0, ROW_LEN
	sw $t1, 0($a0)
	sw $t0, 4($a0)
	sw $t0, 8($a0)
	sw $t1, 12($a0)
	sw $t0, 16($a0)
	sw $t1, 20($a0)
	sw $t1, 24($a0)
	sw $t1, 28($a0)
	sw $t0, 32($a0)
	sw $t1, 36($a0)
	sw $t1, 40($a0)
	sw $t1, 44($a0)
	sw $t0, 48($a0)
	sw $t1, 52($a0)
	sw $t0, 56($a0)
	sw $t0, 60($a0)
	sw $t1, 64($a0)
	addi $a0, $a0, ROW_LEN
	sw $t1, 0($a0)
	sw $t0, 4($a0)
	sw $t0, 8($a0)
	sw $t1, 12($a0)
	sw $t0, 16($a0)
	sw $t0, 20($a0)
	sw $t3, 24($a0)
	sw $t0, 28($a0)
	sw $t0, 32($a0)
	sw $t0, 36($a0)
	sw $t3, 40($a0)
	sw $t0, 44($a0)
	sw $t0, 48($a0)
	sw $t1, 52($a0)
	sw $t0, 56($a0)
	sw $t0, 60($a0)
	sw $t1, 64($a0)
	addi $a0, $a0, ROW_LEN
	sw $t1, 0($a0)
	sw $t0, 4($a0)
	sw $t0, 8($a0)
	sw $t1, 12($a0)
	sw $t0, 16($a0)
	sw $t0, 20($a0)
	sw $t3, 24($a0)
	sw $t0, 28($a0)
	sw $t0, 32($a0)
	sw $t0, 36($a0)
	sw $t3, 40($a0)
	sw $t0, 44($a0)
	sw $t0, 48($a0)
	sw $t1, 52($a0)
	sw $t0, 56($a0)
	sw $t0, 60($a0)
	sw $t1, 64($a0)
	addi $a0, $a0, ROW_LEN
	sw $t1, 0($a0)
	sw $t0, 4($a0)
	sw $t0, 8($a0)
	sw $t1, 12($a0)
	sw $t0, 16($a0)
	sw $t0, 20($a0)
	sw $t0, 24($a0)
	sw $t1, 28($a0)
	sw $t1, 32($a0)
	sw $t1, 36($a0)
	sw $t0, 40($a0)
	sw $t0, 44($a0)
	sw $t0, 48($a0)
	sw $t1, 52($a0)
	sw $t0, 56($a0)
	sw $t0, 60($a0)
	sw $t1, 64($a0)
	addi $a0, $a0, ROW_LEN
	sw $t1, 0($a0)
	sw $t0, 4($a0)
	sw $t0, 8($a0)
	sw $t1, 12($a0)
	sw $t0, 16($a0)
	sw $t0, 20($a0)
	sw $t1, 24($a0)
	sw $t0, 28($a0)
	sw $t0, 32($a0)
	sw $t0, 36($a0)
	sw $t1, 40($a0)
	sw $t0, 44($a0)
	sw $t0, 48($a0)
	sw $t1, 52($a0)
	sw $t0, 56($a0)
	sw $t0, 60($a0)
	sw $t1, 64($a0)
	addi $a0, $a0, ROW_LEN
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	sw $t1, 12($a0)
	sw $t0, 16($a0)
	sw $t0, 20($a0)
	sw $t0, 24($a0)
	sw $t0, 28($a0)
	sw $t0, 32($a0)
	sw $t0, 36($a0)
	sw $t0, 40($a0)
	sw $t0, 44($a0)
	sw $t0, 48($a0)
	sw $t1, 52($a0)
	sw $t1, 56($a0)
	sw $t1, 60($a0)
	addi $a0, $a0, ROW_LEN
	sw $t1, 16($a0)
	sw $t1, 20($a0)
	sw $t1, 24($a0)
	sw $t1, 28($a0)
	sw $t1, 32($a0)
	sw $t1, 36($a0)
	sw $t1, 40($a0)
	sw $t1, 44($a0)
	sw $t1, 48($a0)
	jal return

drawPoodle:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t0, PINK
	li $t1, WHITE
	li, $t2, GREY
	sw $t1, 16($a0)
	sw $t1, 20($a0)
	sw $t1, 24($a0)
	addi $a0, $a0, ROW_LEN
	sw $t1, 12($a0)
	sw $t0, 16($a0)
	sw $t0, 20($a0)
	sw $t0, 24($a0)
	sw $t1, 28($a0)
	addi $a0, $a0, ROW_LEN 
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	sw $t0, 12($a0)
	sw $t0, 16($a0)
	sw $t0, 20($a0)
	sw $t0, 24($a0)
	sw $t0, 28($a0)
	sw $t1, 32($a0)
	sw $t1, 36($a0)
	addi $a0, $a0, ROW_LEN
	sw $t1, 0($a0)
	sw $t2, 4($a0)
	sw $t1, 8($a0)
	sw $t0, 12($a0)
	sw $t1, 16($a0)
	sw $t0, 20($a0)
	sw $t1, 24($a0)
	sw $t0, 28($a0)
	sw $t1, 32($a0)
	sw $t2, 36($a0)
	sw $t1, 40($a0)
	addi $a0, $a0, ROW_LEN
	sw $t1, 0($a0)
	sw $t2, 4($a0)
	sw $t1, 8($a0)
	sw $t0, 12($a0)
	sw $t0, 16($a0)
	sw $t0, 20($a0)
	sw $t0, 24($a0)
	sw $t0, 28($a0)
	sw $t1, 32($a0)
	sw $t2, 36($a0)
	sw $t1, 40($a0)
	addi $a0, $a0, ROW_LEN
	sw $t1, 0($a0)
	sw $t2, 4($a0)
	sw $t1, 8($a0)
	sw $t0, 12($a0)
	sw $t0, 16($a0)
	sw $t0, 20($a0)
	sw $t0, 24($a0)
	sw $t0, 28($a0)
	sw $t1, 32($a0)
	sw $t2, 36($a0)
	sw $t1, 40($a0)
	addi $a0, $a0, ROW_LEN
	sw $t1, 4($a0)
	sw $t1, 8($a0)
	sw $t0, 12($a0)
	sw $t0, 16($a0)
	sw $t0, 20($a0)
	sw $t0, 24($a0)
	sw $t0, 28($a0)
	sw $t1, 32($a0)
	sw $t1, 36($a0)
	addi $a0, $a0, ROW_LEN
	sw $t1, 12($a0)
	sw $t1, 16($a0)
	sw $t1, 20($a0)
	sw $t1, 24($a0)
	sw $t1, 28($a0)
	jal return



	
