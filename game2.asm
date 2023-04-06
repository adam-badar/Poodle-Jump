
#DEFINE CONSTANTS
# width = 64, height = 128
.eqv 	BASE_ADDRESS 	0x10008000	#top-left pixel
.eqv	START_POSITION	0x1000F000	#starting position for poodle (64*120+32)*4
.eqv	TOP_RIGHT	0x100080FC	#top-right pixel
.eqv	END		0x1000FFFC
.eqv	ROW_LEN		256
.eqv	GAME_OVER	0x10009828
#DEFINE COLOURS
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
.eqv	BACKGROUND	0Xffffe0

.data
backgroundColor: .word 0Xffffe0

.text
.globl main

main:
	li $a0, BASE_ADDRESS
	li $a1, START_POSITION
	jal drawBackground
	
	#INITIALIZE
		#variables:
			#$s0: prev position
			#$s1: curr position
			#s2: 
		li $s1, START_POSITION
		li $s0, END
		li $s6, 50
	
	
	loop:
		li $a0, 0xffff0000
		lw $t9, 0($a0)
		bne $t9, 1, draw
		jal keypress
		move_check:
			beq $s0, $s1, draw
		clear:
			move $a0, $s0
			jal clearPoodle
		draw:
			move $a0, $s1
			jal drawPoodle
			move $s0, $s1
			
		sleep:
			li $v0, 32
			move $a0, $s6
			syscall
		
		j loop
	
return:
	jr $ra
#FINISH PEACEFULLLY
end:
	li $v0, 10
	syscall
	
#.......................................

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
	li	$t2, ROW_LEN
	addi	$t2, $t2, BASE_ADDRESS
	li	$t3, END
	addi	$t3, $t3, -2048 #checks if character on the last lien
	
	
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
		addi	$s1, $s1, -4						# else, move left
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
		addi	$s1, $s1, 4						# else, move right
		b keypress_done

	# go down
	key_s:
		# make sure ship is not in bottom row
		bgt	$s1, $t3, gameOver				# if $s1 is in the bottom row, don't go down
		addi	$s1, $s1, ROW_LEN					# else, move down
		addi	$s1, $s1, ROW_LEN					# else, move down
		b keypress_done

	key_p:
		# restart game
		la	$ra, main
		b keypress_done

	keypress_done:
		jr	$ra							# jump to ra
# ------------------------------------
	

gameOver:
	li $a0, GAME_OVER
	jal drawG
	addi $a0, $a0, 28
	jal drawA
	addi $a0, $a0, 28
	jal drawM
	addi $a0, $a0, 28
	jal drawE
	addi $a0, $a0, 28
	jal drawO
	addi $a0, $a0, 28
	jal drawV
	addi $a0, $a0, 28
	jal drawE
	addi $a0, $a0, 28
	jal drawR
#SET BACKGROUND..........................

drawBackground:
	li $t4, BACKGROUND
	bgt $a0, 0x1000FFFC, return
	sw $t4, 0($a0)
	addi $a0, $a0, 4
	j drawBackground
	

#DRAW OBJECTS............................

drawG:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, BLACK
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
	jr $ra

drawA: 
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, BLACK
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
	jr $ra

drawM: 
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, BLACK
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
	jr $ra

drawE:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, BLACK
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
	jr $ra

drawO: 
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, BLACK
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
	jr $ra

drawV:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, BLACK
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
	jr $ra

drawR:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, BLACK
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
	jr $ra
	
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
	jr $ra

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
	jr $ra
	
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
	jr $ra

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
	jr $ra

drawSpike:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, BLACK
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
	jr $ra

drawSpring:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, BLACK
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
	jr $ra

drawJetpack:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, BLACK
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
	jr $ra
	
drawHole:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t8, BLACK
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
	jr $ra
	


drawSadPoodle:
	addi $a0, $a0, ROW_LEN
	addi $a0, $a0, ROW_LEN
	li $t0, PINK
	li $t1, BLACK
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
	jr $ra

clearPoodle:
	li $t0, BACKGROUND
	li $t1, BACKGROUND
	li, $t2, BACKGROUND
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
	jr $ra


drawPoodle:
	li $t0, RED
	li $t1, BLACK
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
	jr $ra
