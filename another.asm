#####################################################################
#
# CSC258H5S Fall 2020 Assembly Final Project
# University of Toronto, St. George
#
# Student: Ng Bob Shoaun, 1006568992
#
# Bitmap Display Configuration:
# - Unit width in pixels: 16
# - Unit height in pixels: 16
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# - Milestone 5
#
# Which approved additional features have been implemented?
# 1. Scoreboard
# 2. Game over/retry
# 3. Different levels
# 4. Dynamic difficulty
#	- platform spacing increases
#	- capped at a certain point
# 5. More platform types
# 	- broken platform
#	- cloud platform
#	- moving platform
# 6. Boosting / power-ups
#	- Spring
#	- jetpack
# 7. Fancier graphics
# 8. Background music & sound effects
#
# Any additional information that the TA needs to know:
# - I forgot to mention in my demo that i have also added moving platforms.
#
#####################################################################
.data
	gameMatrix: .word 0:1536
	sleepDuration: .word 40
	
	doodlerColor: .word 0xEEB1D5
	doodlerSecondaryColor: .word 0xe58abf
	backgroundColor: .word 0x43AA8B
	platformColor: .word 0xF9C74F
	springColor: .word 0x577590
	brokenPlatformColor: .word 0xF3722C
	cloudPlatformColor: .word 0xF0F0F0
	jetpackColor: .word 0x191923
	movingPlatformColor: .word 0x22577A
	jumpMeterColor: .word 0xF94144
	scoreMeterColor: .word 0x2708A0
	gameOverTextColor: .word 0x000000
	
	doodlerInitialPosition: .word 64
	doodlerJumpDuration: .word 13	# jump duration in frames
	springBoostDuration: .word 25	# spring boost duration in frames
	jetpackBoostDuration: .word 70
	
.text
main:
	lw $t0, doodlerInitialPosition  # doodler current position
	li $t1, 0 			# doodler velocity
	li $t2, 0			# jump timer
	li $t3, 0			# game over flag, 1 means game over
	li $t4, 768			# next spawn coord / spawn timer
	li $t5, 0			# difficulty / platform spacing	
	li $t6, -128			# moving platforms move timer
	li $t7, 0			# background music timer
	
	
	
	li $s0, 0
	startLoop:
		beq $s0, 32, gameLoop
		jal scrollWorld
		jal spawnObstacle
		jal drawWorld
		addi $s0, $s0, 1
		j startLoop

	gameLoop:
		
		bge $t0, 1536, skipScroll
		jal scrollWorld
		jal spawnObstacle
		addi $t0, $t0, 128	# also scroll player
		
		skipScroll:
			jal movePlatforms
			
			beq $t3, 1, skipMoveDoodler
			jal moveDoodler
		
		skipMoveDoodler:
			jal drawWorld
			jal drawDoodler
				
			ble $t0, 4096, contGameLoop	# doodler reaches bottom of screen
			
			jal gameOver
			jal drawGameOverText
			
			beq $t3, 1, contGameLoop
			li $t3, 1		# set gameOver to true
			#jal playGameOverSound
			
		contGameLoop:
			jal sleep
			j gameLoop
		
	endGameLoop:
		li $v0, 10 # terminate the program gracefully
		syscall
		
gameOver:
	lw $s0, 0xffff0000
	beq $s0, 1, gameOverInput
	jr $ra
	
	gameOverInput:
	 	lw $s1, 0xffff0004
		beq $s1, 0x72, rPressed
		beq $s1, 0x71, qPressed
		jr $ra
	
	rPressed:
		j main
	
	qPressed:
		li $v0, 10 # terminate the program gracefully
		syscall
		
drawGameOverText:
	addi $sp, $sp, -12
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	lw $s0, gameOverTextColor
	addi $s1, $gp, 1960
	
	# o
	sw $s0, 0($s1)
	sw $s0, 4($s1)
	sw $s0, 8($s1)
	sw $s0, 128($s1)
	sw $s0, 136($s1)
	sw $s0, 256($s1)
	sw $s0, 260($s1)
	sw $s0, 264($s1)
	
	addi $s1, $s1, 16
	
	# o
	sw $s0, 0($s1)
	sw $s0, 4($s1)
	sw $s0, 8($s1)
	sw $s0, 128($s1)
	sw $s0, 136($s1)
	sw $s0, 256($s1)
	sw $s0, 260($s1)
	sw $s0, 264($s1)
	
	addi $s1, $s1, 16
	
	# f
	sw $s0, -252($s1)
	sw $s0, -248($s1)
	sw $s0, -124($s1)
	sw $s0, 0($s1)
	sw $s0, 4($s1)
	sw $s0, 8($s1)
	sw $s0, 132($s1)
	sw $s0, 260($s1)
	
	addi $s1, $s1, 1380
	
	# r
	sw $s0, 0($s1)
	sw $s0, 4($s1)
	sw $s0, 128($s1)
	sw $s0, 256($s1)
	
	addi $s1, $s1, 16
	
	# |
	sw $s0, -128($s1)
	sw $s0, 0($s1)
	sw $s0, 128($s1)
	sw $s0, 256($s1)
	sw $s0, 384($s1)
	
	addi $s1, $s1, 12
	
	# q
	sw $s0, 4($s1)
	sw $s0, 8($s1)
	sw $s0, 128($s1)
	sw $s0, 136($s1)
	sw $s0, 260($s1)
	sw $s0, 264($s1)
	sw $s0, 392($s1)
	sw $s0, 520($s1)
	sw $s0, 524($s1)
	
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, ($sp)
	addi $sp, $sp, 12
	jr $ra
	

	
movePlatforms:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	blt $t6, 128, contMovePlatforms
	li $t6, -128
	
	contMovePlatforms:
		blt $t6, 0, moveRight
		jal movePlatsLeft
		j endMovePlatforms
		
	moveRight:
		jal movePlatsRight
	
	endMovePlatforms:
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra
		
movePlatsRight:
	addi $sp, $sp, -12
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	addi $t6, $t6, 4
	
	li $s0, 4864
	loopMovePlatsRight:
		beq $s0, 764, endMovePlatsRight
		lw $s1, gameMatrix($s0)
		bne $s1, 6, contMovePlatsRight
		
		addi $s2, $s0, 4
		sw $zero, gameMatrix($s0)
		sw $s1, gameMatrix($s2)
		
		contMovePlatsRight:
			addi $s0, $s0, -4
			j loopMovePlatsRight
	
	endMovePlatsRight:
		lw $s2, 8($sp)
		lw $s1, 4($sp)
		lw $s0, ($sp)
		addi $sp, $sp, 12
		jr $ra
		
movePlatsLeft:
	addi $sp, $sp, -12
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	addi $t6, $t6, 4
	
	li $s0, 768
	loopMovePlatsLeft:
		beq $s0, 4864, endMovePlatsLeft
		lw $s1, gameMatrix($s0)
		bne $s1, 6, contMovePlatsLeft
		
		addi $s2, $s0, -4
		sw $zero, gameMatrix($s0)
		sw $s1, gameMatrix($s2)
		
		contMovePlatsLeft:
			addi $s0, $s0, 4
			j loopMovePlatsLeft
	
	endMovePlatsLeft:
		lw $s2, 8($sp)
		lw $s1, 4($sp)
		lw $s0, ($sp)
		addi $sp, $sp, 12
		jr $ra
		
		
spawnJetpack:
	addi $sp, $sp, -8
	sw $s0, ($sp)
	sw $s1, 4($sp)
	
	li $s1, 5	# 5 represents jetpack
	addi $s0, $t4, -128
	sw $s1, gameMatrix($s0)
	addi $s0, $s0, -128
	sw $s1, gameMatrix($s0)
	addi $s0, $s0, -128
	sw $s1, gameMatrix($s0)
	addi $s0, $s0, 132
	sw $s1, gameMatrix($s0)
	addi $s0, $s0, 132
	sw $s1, gameMatrix($s0)
	addi $s0, $s0, -128
	sw $s1, gameMatrix($s0)
	addi $s0, $s0, -128
	sw $s1, gameMatrix($s0)
	
	lw $s1, 4($sp)
	lw $s0, ($sp)
	addi $sp, $sp, 8
	jr $ra


# a0 platform type
spawnPlatform:
	addi $sp, $sp, -4
	sw $s0, ($sp)

	move $s0, $t4
	sw $a0, gameMatrix($s0) # spawn platform
	addi $s0, $s0, 4
	sw $a0, gameMatrix($s0)
	addi $s0, $s0, 4
	sw $a0, gameMatrix($s0)
	addi $s0, $s0, 4
	sw $a0, gameMatrix($s0)
	addi $s0, $s0, 4
	sw $a0, gameMatrix($s0)

	lw $s0, ($sp)
	addi $sp, $sp, 4
	jr $ra

# $a0 random position on platform
spawnSpring:
	addi $sp, $sp, -8
	sw $s0, ($sp)
	sw $s1, 4($sp)
	
	mul $s0, $a0, 4		# multiply random num by 4 
	add $s0, $s0, $t4	# get coords of platform
	addi $s0, $s0, -128	# spawn above platform
	
	li $s1, 2	# 2 represents spring
	sw $s1, gameMatrix($s0)
	
	lw $s1, 4($sp)
	lw $s0, ($sp)
	addi $sp, $sp, 8
	jr $ra

	
# $a0 reference in game matrix coord
removePlatform:
	addi $sp, $sp, -16
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	lw $s0, gameMatrix($a0)	# load reference pixel to know which platform it is
	li $s1, -16	# iterate all possibilities of a 4 wide platform
	
	removeLoop:
		beq $s1, 20, finishRemove
		add $s3, $a0, $s1	# current coord we are looking at
		
		lw $s4, gameMatrix($s3)	# load contents of current pixel
		bne $s4, $s0, contRemoveLoop	# check if same as reference
		sw $zero, gameMatrix($s3)
	
	contRemoveLoop:
		addi $s1, $s1, 4
		j removeLoop
	
	finishRemove:
		lw $s3, 12($sp)
		lw $s2, 8($sp)
		lw $s1, 4($sp)
		lw $s0, ($sp)
		addi $sp, $sp, 16
		jr $ra
		
spawnObstacle:
	addi $sp, $sp, -8
	sw $ra, ($sp)
	sw $s0, 4($sp)
	
	bge $t4, 768, endSpawnObstacle
	
	# RNG for type of obstacle
	li $v0, 42
	li $a0, 0
	li $a1, 30
	syscall
	
	blt $a0, 13, spawnNext1
	li $a0, 1	# 1 represents standard platform
	jal spawnPlatform
	j endSpawn
	
	spawnNext1:
		blt $a0, 9, spawnNext2
		# spawn standard platform and broken platform below
		li $a0, 1	# 1 represents standard platform
		jal spawnPlatform
		
		# RNG to spawn broken platform
		li $v0, 42
		li $a0, 0
		li $a1, 64
		syscall
		
		move $s0, $a0
		mul $s0, $s0, 4		# coord form
		addi $s0, $s0, 256	# lower bound
		
		add $t4, $t4, $s0	# set platform spawn pos
		
		li $a0, 3	# 3 represents broken platform
		jal spawnPlatform
		
		mul $s0, $s0, -1
		add $t4, $t4, $s0	# revert original t4
		j endSpawn
	
	spawnNext2:
		blt $a0, 6, spawnNext3
		li $a0, 4	# 4 represents cloud platform
		jal spawnPlatform
		j endSpawn
	
	spawnNext3:
		blt $a0, 5, spawnNext4
		li $a0, 6	# 6 represents moving platform
		jal spawnPlatform
		j endSpawn
	
	spawnNext4:
		blt $a0, 4, spawnNext5
		li $a0, 1	
		jal spawnPlatform
		jal spawnJetpack
		j endSpawn
		
	spawnNext5:
		li $a0, 1	
		jal spawnPlatform
		jal spawnSpring
		j endSpawn
	
	endSpawn:
		# RNG for next platform
		li $v0, 42
		li $a0, 0
		li $a1, 192
		syscall

		mul $a0, $a0, 4		# coord form
		add $a0, $a0, $t5	# apply difficulty as spacing
		addi $t4, $a0, 768	# apply offset for buffer
		
		bgt $t5, 712, endSpawnObstacle	# difficulty cap
		addi $t5, $t5, 4	# increase difficulty
	
	endSpawnObstacle:
		lw $s0, 4($sp)
		lw $ra, ($sp)
		addi $sp, $sp, 8
		jr $ra

scrollWorld:
	addi $sp, $sp, -20
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	addi $t4, $t4, -128 	# update scroll timer
	
	li $s0, 4864
	scroll:
		blt $s0, $zero, endScrollWorld
		lw $s1, gameMatrix($s0)
		addi $s2, $s0, 128	# scroll amount
		sw $s1, gameMatrix($s2)
		addi $s0, $s0, -4
		j scroll
		
	endScrollWorld:
		lw $s3, 16($sp)
		lw $s2, 12($sp)
		lw $s1, 8($sp)
		lw $s0, 4($sp)
		lw $ra, ($sp)
		addi $sp, $sp, 20
		jr $ra
		
drawWorld:
	addi $sp, $sp, -20
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)

	li $s0, 0
	drawLoop:
		beq $s0, 4096, endDrawWorld
		
		addi $s2, $s0, 768	# matrix coords by applying offset
		lw $s1, gameMatrix($s2)	# get value at coords
		add $s2, $s0, $gp	# get address at coords
		beq $s1, 0, dBackground
		beq $s1, 1, dPlatform
		beq $s1, 2, dSpring
		beq $s1, 3, dBrokenPlatform
		beq $s1, 4, dCloudPlatform
		beq $s1, 5, dJetpack
		beq $s1, 6, dMovingPlatform
		j contDrawLoop
		
	dBackground:
		lw $s3, backgroundColor
		div $s1, $s0, 40	# gradient
		add $s3, $s3, $s1
		j contDrawLoop
		
	dPlatform:
		lw $s3, platformColor
		j contDrawLoop
		
	dSpring:
		lw $s3, springColor
		j contDrawLoop
	
	dBrokenPlatform:
		lw $s3, brokenPlatformColor
		j contDrawLoop
		
	dCloudPlatform:
		lw $s3, cloudPlatformColor
		j contDrawLoop
	
	dJetpack:
		lw $s3, jetpackColor
		j contDrawLoop
		
	dMovingPlatform:
		lw $s3, movingPlatformColor
		j contDrawLoop
	
	contDrawLoop:
		sw $s3, ($s2)
		addi $s0, $s0, 4
		j drawLoop
		
	endDrawWorld:
		lw $s3, 16($sp)
		lw $s2, 12($sp)
		lw $s1, 8($sp)
		lw $s0, 4($sp)
		lw $ra, ($sp)
		addi $sp, $sp, 20
		jr $ra


moveDoodler:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	li $t1, 0	# reset velocity
	jal checkKeyboardInput
	
	bne $t2, $zero, jumping
	addi $t1, $t1, 128	# apply gravity
	
	jal checkDoodlerCollision
	j endMoveDoodler
	
	jumping:
		addi $t1, $t1, -128
		addi $t2, $t2, -1
	
	endMoveDoodler:
		add $t0, $t0, $t1	# move doodler based on velocity
	
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra
	
checkDoodlerCollision:
	addi $sp, $sp, -20
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)

	addi $s0, $t0, 768 	# current pos in game matrix coords
	
	li $s3, 384	# check left, middle and right
	
	checkCollisions:
		beq $s3, 396, endCheckCollisions
		add $s1, $s0, $s3
		lw $s2, gameMatrix($s1)
		beq $s2, 1, standardPlatformCollision
		beq $s2, 2, springCollision
		beq $s2, 3, brokenPlatformCollision
		beq $s2, 4, cloudPlatformCollision
		beq $s2, 5, jetpackCollision
		beq $s2, 6, standardPlatformCollision

		addi $s3, $s3, 4	# increase iterator
		j checkCollisions
	
	standardPlatformCollision:
		addi $t1, $t1, -128		# cancel gravity
		lw $t2, doodlerJumpDuration	# start jump
		j endCheckCollisions
	
	springCollision:
		addi $t1, $t1, -128		# cancel gravity
		lw $t2, springBoostDuration	# start jump with higher duration
		j endCheckCollisions
		
	brokenPlatformCollision:
		# remove broken platform
		move $a0, $s1
		jal removePlatform
		j endCheckCollisions
	
	cloudPlatformCollision:
		addi $t1, $t1, -128		# cancel gravity
		lw $t2, doodlerJumpDuration	# start jump
		# remove cloud platform
		move $a0, $s1
		jal removePlatform
		j endCheckCollisions
		
	jetpackCollision:
		lw $t2, jetpackBoostDuration
		j endCheckCollisions

	endCheckCollisions:
		lw $ra, 16($sp)
		lw $s3, 12($sp)
		lw $s2, 8($sp)
		lw $s1, 4($sp)
		lw $s0, ($sp)
		addi $sp, $sp, 20
		jr $ra


checkKeyboardInput:
	addi $sp, $sp, -8
	sw $s0, ($sp)
	sw $s1, 4($sp)
	
	lw $s0, 0xffff0000
	beq $s0, 1, inputDetected
	j endCKI
	
	inputDetected:
	 	lw $s1, 0xffff0004
		beq $s1, 0x6A, jPressed
		beq $s1, 0x6B, kPressed
		j endCKI
	
	jPressed:
		addi $t1, $t1, -8
		j endCKI
	
	kPressed:
		addi $t1, $t1, 8
	
	endCKI:
		lw $s1, 4($sp)
		lw $s0, ($sp)
		addi $sp, $sp, 8
		jr $ra
	
drawDoodler:
	addi $sp, $sp, -8
	sw $s0, ($sp)
	sw $s1, 4($sp)
	
	lw $s1, doodlerColor
	add $s0, $gp, $t0
	
	sw $s1, 128($s0)
	sw $s1, 136($s0)
	sw $s1, 256($s0)
	sw $s1, 264($s0)
	
	lw $s1, doodlerSecondaryColor
	sw $s1, 4($s0)
	sw $s1, 132($s0)
	
	
	lw $s1, 4($sp)
	lw $s0, ($sp)
	addi $sp, $sp, 8
	jr $ra
		
sleep:	
	li $v0, 32
	lw $a0, sleepDuration
	syscall
	jr $ra
