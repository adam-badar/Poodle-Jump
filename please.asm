.data
dooAddressBottom: .word 0x10008f64
dooAddressMid: .word 0x10008ee4
dooAddressTop: .word 0x10008e68
dooAddressBottomRight: .word 0x10008f6c

platform1: .word 0x10008f58
platform2: .word 0x10008f58
platform3: .word 0x10008f58
platform4: .word 0x10008f58
boardAddressStartBB: .word 0x10008fd8

topLeftAddress: .word 0x10008000
bottomRightAddress: .word 0x10008ffc
doodlerColor: .word 0xfd3a69
boardColor: .word 0xfecd1a
overColor1: .word 0xfa7d09
overColor2: .word 0xff4301
backColor: .word 0xffffff
pressColor: .word 0x111d5e

jumpCounter: .word 0
moveCounter: .word 0
chordCounter: .word 0
horizontalInd: .word 0
score: .word 0
sleep_t: .word 0
enteringLoopCounterD: .word 0
enteringLoopCounterU: .word 0

colorArray: .word 0x6fb1ff:1024		# the color array all initialized to royal blue
chordArray: .word 64, 64, 64, 60, 64, 68, 56

# the first elements for all rows of the sign "GAME OVER"
row1: .word 0x10008218
row2: .word 0x10008298
row3: .word 0x10008318
row4: .word 0x10008398
row5: .word 0x10008418
row6: .word 0x10008498
row7: .word 0x10008518
row8: .word 0x10008598
row9: .word 0x10008618
row10: .word 0x10008698
row11: .word 0x10008718
row12: .word 0x10008798

row14: .word 0x10008898
row15: .word 0x10008918
row16: .word 0x10008998
row17: .word 0x10008a18
row18: .word 0x10008a98

.text
# features of this game
# milestones 1-3 completed
# milestone 4: b.Game Over(RETRY) + d. dynamic increase in difficulty (speed)
# milestone 5: a.Realistic Physics(speed up/slow down mimicing gravity) + b. i. Moving Blocks when the score is higher than 5 
# iii. other types of blocks + e. dynamic notification
# Also, I understand how to play background music and the code is shown below, but somehow it does not work

main:
li $v0, 42 			# tell system to generate a random number within the specified range
li $a1, 100

lw $s0, platform2
lw $s1, platform3
lw $s3, platform4
li $s2, 4
subi $s0, $s0, 728 		# start position of the first random board with fixed height
subi $s1, $s1, 1880 		# start position of the second random board with fixed height
subi $s3, $s3, 2776 		# start position of the third random board with fixed height

# generate two random address for platform2, 3, 4
syscall
div $a0, $a0, $s2
mul $a0, $a0, $s2
add $s0, $s0, $a0


syscall
div $a0, $a0, $s2
mul $a0, $a0, $s2
add $s1, $s1, $a0

div $a0, $a0, $s2
mul $a0, $a0, $s2
add $s3, $s3, $a0

sw $s0, platform2
sw $s1, platform3
sw $s3, platform4

CentralLoop:

# reset the background (fill the bitmap with the color array)
SetUp:
la $t8, colorArray		# $t8 holds address of the colorArray
lw $t9, topLeftAddress		# $t9 holds address of the bitmap display array
add $t0, $zero, $zero		# $t0 holds 4*i; initially 0
addi $t1, $zero, 4096		# $t1 holds the size of the color array

FillDisplay:
bge $t0, $t1, CheckUserInput		# branch if $t0 >= 4096
add $t2, $t8, $t0		# $t2 holds address of colorArray[i]
add $t3, $t9, $t0		# $t3 holds address of bitmapDisplay[i]
lw $t5, 0($t2)			# $t5 = colorArray[i]
sw $t5, 0($t3)			# bitmapDisplay[i] = $t5
addi $t0, $t0, 4		# update offset in $t0
j FillDisplay

CheckUserInput:
# check user input
lw $t8, 0xffff0000
beq $t8, 1 , keyboard_input
j continue1

keyboard_input:
lw $t9, 0xffff0004
beq $t9, 0x6a, respond_to_j
j checkIfK

checkIfK:
beq $t9, 0x6b, respond_to_k
j continue1

respond_to_j:
li $t0, -4
addi $sp, $sp, -4		# push the shift amount $t0 to stack
sw $t0, 0($sp)
jal ShiftDoo
j continue1

respond_to_k:
li $t0, 4
addi $sp, $sp, -4		# push the shift amount $t0 to stack
sw $t0, 0($sp)
jal ShiftDoo
j continue1

continue1:
# check whether the distance between doo's feet adress and 
# the address of 'previous at' platform (make a check distance subrountine) is within a range

addi $sp, $sp, -4		# push the leftmost unit of the platform1
lw $t0, platform1
sw $t0, 0($sp)
jal checkWithinRange
lw $t1, 0($sp)			# pop the return value of checkWithinRange
addi $sp, $sp, 4

addi $sp, $sp, -4		# push the leftmost unit of the platform2
lw $t0, platform2
sw $t0, 0($sp)
jal checkWithinRange
lw $t2, 0($sp)			# pop the return value of checkWithinRange
addi $sp, $sp, 4


# check which platform did the doo land on
beqz $t1, checkSecond

bne $t7, 1, exitChecking	# check whether the doo is falling
re_jump1:
li $t4, 0			# make jumpCounter 0 so that doodler can re-jump
sw $t4, jumpCounter

li $t7, 0			# make the indicator 0 and push it to stack
addi $sp, $sp, -4
sw $t7, 0($sp)

jal shiftPlatformsDown		# shift down all the platforms and do not change any reference

lw $t7, 0($sp)			# pop off the indicator of whether the doo should jump or fall from the stack
addi $sp, $sp, 4

j continue2

checkSecond:
beqz $t2, exitChecking

bne $t7, 1, exitChecking	# check whether the doo is falling

re_jump2:
lw $k0, score			# make the score increment by one
addi $k0, $k0, 1
sw $k0, score

li $t4, 0			# make jumpCounter 0 so that doodler can re-jump
sw $t4, jumpCounter

li $t7, 0			# make the indicator 0 and push it to stack
addi $sp, $sp, -4
sw $t7, 0($sp)

jal shiftPlatformsDown		# shift down all the platforms and change references for pl1, pl2 and generate a new pl3

lw $t7, 0($sp)			# pop off the indicator of whether the doo should jump or fall from the stack
addi $sp, $sp, 4

lw $t6, platform2
sw $t6, platform1
lw $t6, platform3
sw $t6, platform2
lw $t6, platform4
sw $t6, platform3
# generate a new pl4

li $v0, 42 			# tell system to generate a random number within the specified range
li $a1, 100

lw $s0, platform1

li $s2, 4
subi $s0, $s0, 2776 		# start position of the third random board with fixed height

# generate two random address for platform 4
syscall
div $a0, $a0, $s2
mul $a0, $a0, $s2
add $s0, $s0, $a0

sw $s0, platform4

j continue2

exitChecking:
# addi $sp, $sp, -4		# push the original counter to the stack so that doodler finish the leftover movement
# sw $t4, 0($sp)

addi $sp, $sp, -4		# push the indicator of whether the doo should jump or fall to stack
sw $t7, 0($sp)

jal shiftPlatformsDown

lw $s0, boardColor
li $s1, 0xb6eb7a
bne $s0, $s1, continue2
jal shiftPlatformsRight
j continue2

continue2:
# redraw the screen

jal RedrawTheDoo		# redraw the doo

# check whether the score is 5
bne $k0, 5, changeColor
jal DrawNotifications
j sleep

changeColor:
ble $k0, 5, sleep
li $t0, 0xb6eb7a
sw $t0, boardColor
j sleep

#play music
#Set:
#la $t8, chordArray		# $t8 holds address of the colorArray
#lw $t0, chordCounter		# $t0 holds 4*i; initially 0
#li $t1, 28			# $t1 holds the size of the color array

#Play:
#bgt $t0, $t1, sleep		# branch if $t0 >= 4096
#li $t2, 0
#add $t2, $t8, $t0		# $t2 holds address of colorArray[i]
#lw $t5, 0($t2)

#lw $a0, 0($t5)			# $t5 = chordArray[i]
#li, $a1, 1000
#li, $a2, 0
#li $a3, 90

#addi $t0, $t0, 4		# update offset in $t0
#beq $t0, 28, refill
#sw $t0, chordCounter
#j sleep

#refill:
#li $t0, 0
#sw $t0, chordCounter
#j sleep

sleep:
li $v0, 32			# involke the sleep instruction
lw $t0, score
lw $t1, sleep_t
sub $t0, $t0, $t1
sw $t0, sleep_t
lw $a0, sleep_t

syscall

j CentralLoop			# repeat the central loop

ShiftDoo:
lw $t0, 0($sp)			# pop the shift amount off the stack
addi $sp, $sp, 4
lw $t1, dooAddressBottom	# $t1 stores the bottom address for doo
lw $t2, dooAddressMid		# $t2 stores the mid address for doo
lw $t3, dooAddressTop 		# $t3 stores the top address for doo
lw $t5, dooAddressBottomRight

add $t1, $t1, $t0		# shift the bottom left with the amount of $t0
add $t2, $t2, $t0		# shift the middle left with the amount of $t0
add $t3, $t3, $t0		# shift the top with the amount of $t0
add $t5, $t5, $t0

sw $t1, dooAddressBottom	# update the bottom address for doo
sw $t2, dooAddressMid		# update the mid address for doo
sw $t3, dooAddressTop 		# update the top address for doo
sw $t5, dooAddressBottomRight
jr $ra				# jump back to the central loop

shiftPlatformsDown:
lw $t7, 0($sp)			# pop the indicator off the stack
addi $sp, $sp, 4
lw $t4, jumpCounter			# pop the counter off the stack
# addi $sp, $sp, 4
ble $t4, 1280, shiftUpCondition
shiftUpCondition:
beq $t7, 1, shiftPlatformsUp

li, $t7, 0			# make the indicator 0

lw $t1, platform1		# $t1 stores the leftmost address for platform1
lw $t2, platform2		# $t2 stores the leftmost address for platform2
lw $t3, platform3 		# $t3 stores the leftmost address for platform3
lw $t5, platform4 		# $t5 stores the leftmost address for platform4

addi $sp, $sp, -4
sw $ra, 0($sp)
lw $t9, 0($sp)

check_loop_entering:
# check the loop entering counter to determine how far will the platforms shift -- realistic physics
lw $s1, enteringLoopCounterD
addi $s1, $s1, 1
sw $s1, enteringLoopCounterD

check_one_d:
bne $s1, 1, check_two_d
li $s2, 70			# store the shift amount
sw $s2, sleep_t
j keepStoring

check_two_d:
bne $s1, 2, check_three_d
li $s2, 90			# store the shift amount
sw $s2, sleep_t
j keepStoring

check_three_d:
bne $s1, 3, check_four_d
li $s2, 110			# store the shift amount
sw $s2, sleep_t
j keepStoring

check_four_d:
bne $s1, 4, keepStoring
li $s2, 130			# store the shift amount
sw $s2, sleep_t
j keepStoring

keepStoring:

addi $t1, $t1, 128		# shift down the leftmost address for platform1
addi $t2, $t2, 128		# shift down the leftmost address for platform2
addi $t3, $t3, 128		# shift down the leftmost address for platform3
addi $t5, $t5, 128

sw $t1, platform1
sw $t2, platform2
sw $t3, platform3
sw $t5, platform4

addi $sp, $sp, -4
sw $ra, 0($sp)
lw $s7, 0($sp)

lw $s0, platform1		# push the address of platform1 to the stack to redraw plt1
addi $sp, $sp, -4
sw $s0, 0($sp)
jal RedrawPlatform

lw $s0, platform2		# push the address of platform2 to the stack to redraw plt2
addi $sp, $sp, -4
sw $s0, 0($sp)
jal RedrawPlatform

lw $s0, platform3		# push the address of platform3 to the stack to redraw plt3
addi $sp, $sp, -4
sw $s0, 0($sp)
jal RedrawPlatform

lw $s0, platform4		# push the address of platform4 to the stack to redraw plt4
addi $sp, $sp, -4
sw $s0, 0($sp)
jal RedrawPlatform

sw $s7, 0($sp)
lw $ra, 0($sp)

add $t4, $t4, 128		# increment the counter
sw $t4, jumpCounter
beq $t4, 1280, changeIndicator1  # make the indicator 1
j exitDown
changeIndicator1:
li, $t7, 1
li $s1, 0
sw $s1, enteringLoopCounterD	# make loop-entering time 0
exitDown:
jr $ra				# jump back to the central loop

shiftPlatformsUp:
lw $t4, jumpCounter

li, $t7, 1			# make the indicator 1

# check time
check_loop_entering_u:
# check the loop entering counter to determine how far will the platforms shift -- realistic physics
lw $s1, enteringLoopCounterU
addi $s1, $s1, 1
sw $s1, enteringLoopCounterU

check_one_u:
bne $s1, 1, check_two_u
li $s2, 130			# store the shift amount
sw $s2, sleep_t
j keepStoringu

check_two_u:
bne $s1, 2, check_three_u
li $s2, 110			# store the shift amount
sw $s2, sleep_t
j keepStoringu

check_three_u:
bne $s1, 3, check_four_u
li $s2, 90			# store the shift amount
sw $s2, sleep_t
j keepStoringu

check_four_u:
bne $s1, 4, keepStoringu
li $s2, 70			# store the shift amount
sw $s2, sleep_t
j keepStoringu

keepStoringu:

lw $t1, platform1		# $t1 stores the leftmost address for platform1
lw $t2, platform2		# $t2 stores the leftmost address for platform2
lw $t3, platform3 		# $t3 stores the leftmost address for platform3
lw $t5, platform4 		# $t5 stores the leftmost address for platform4

addi $t1, $t1, -128		# shift down the leftmost address for platform1 for -128 units
addi $t2, $t2, -128		# shift down the leftmost address for platform2 for -128 units
addi $t3, $t3, -128		# shift down the leftmost address for platform3 for -128 units
addi $t5, $t5, -128

sw $t1, platform1
sw $t2, platform2
sw $t3, platform3
sw $t5, platform4

addi $sp, $sp, -4
sw $ra, 0($sp)
lw $t9, 0($sp)

lw $s0, platform1		# push the address of platform1 to the stack to redraw plt1
addi $sp, $sp, -4
sw $s0, 0($sp)
jal RedrawPlatform

lw $s0, platform2		# push the address of platform2 to the stack to redraw plt2
addi $sp, $sp, -4
sw $s0, 0($sp)
jal RedrawPlatform

lw $s0, platform3		# push the address of platform3 to the stack to redraw plt3
addi $sp, $sp, -4
sw $s0, 0($sp)
jal RedrawPlatform

lw $s0, platform4		# push the address of platform4 to the stack to redraw plt4
addi $sp, $sp, -4
sw $s0, 0($sp)
jal RedrawPlatform

sw $t9, 0($sp)
lw $ra, 0($sp)

addi $t4, $t4, -128		# decrease the counter
sw $t4, jumpCounter
beq $t4, 0, changeIndicator2 	# whether to make the indicator 0
j exitUp
changeIndicator2:
li, $t7, 0			# make the indicator 0
li $s1, 0
sw $s1, enteringLoopCounterU

addi $sp, $sp, -4
sw $ra, 0($sp)

j checkAlive
exitUp:
bne $s7, 1, exitUpUltimate
lw $ra, 0($sp)
addi $sp, $sp, 4
li $s7, 0
jr $ra

exitUpUltimate:
jr $ra				# jump back to the central loop

checkAlive:

lw $t6, 0($sp)
addi $sp, $sp, 4

lw $t5, dooAddressBottomRight
lw $t8, dooAddressBottom
lw $s5, bottomRightAddress
lw $s4, 128($t8)
lw $s2, 128($t5)
lw $s3, boardColor

sub $s5, $s5, $t5
bge $s5, 128, checkFootStart
j NotAlive

checkFootStart:
bne $s2, $s3, checkAnotherFoot
addi $sp, $sp, -4
sw $t6, 0($sp)
li $s7, 1
j exitUp

checkAnotherFoot:
bne $s4, $s3, NotAlive

j exitUp				# alive checked and jump back to shiftup

NotAlive:
li $ra, 0
j GameOver

checkWithinRange:
lw $t0, 0($sp)			# pop off the leftmost unit of the platform
addi $sp, $sp, 4
		
lw $t2, dooAddressBottomRight
sub $t3, $t0, $t2		# get the distance in byte
bgt $t3, 128, OutRange		# check if the right foot is on the leftmost unit of this platform
blt $t3, 92, OutRange		# check if the left foot is on the rightmost unit of this platform
li, $t0, 0			# clear up $t0
addi $sp, $sp, -4		# push the return value 1
addi $t0, $zero, 1
sw $t0, 0($sp)
jr $ra
OutRange:
li, $t0, 0			# clear up $t0
addi $sp, $sp, -4		# push the return value 0
sw $t0, 0($sp)
jr $ra

shiftPlatformsRight:
lw $s6, horizontalInd				# pop the indicator off the stack
# addi $sp, $sp, 4
lw $t5, moveCounter			# pop the counter off the stack
# addi $sp, $sp, 4
ble $t5, 12, shiftLeftCondition
shiftLeftCondition:
beq $s6, 1, shiftPlatformsLeft

li, $s6, 0			# make the indicator 0


lw $t2, platform2		# $t2 stores the leftmost address for platform2
lw $t3, platform3 		# $t3 stores the leftmost address for platform3
lw $t5, platform4 		# $t5 stores the leftmost address for platform4


addi $t2, $t2, 4		# shift down the leftmost address for platform2
addi $t3, $t3, 4		# shift down the leftmost address for platform3
addi $t5, $t5, 4

sw $t2, platform2
sw $t3, platform3
sw $t5, platform4

addi $sp, $sp, -4
sw $ra, 0($sp)
lw $s7, 0($sp)


lw $s0, platform2		# push the address of platform2 to the stack to redraw plt2
addi $sp, $sp, -4
sw $s0, 0($sp)
jal RedrawPlatform

lw $s0, platform3		# push the address of platform3 to the stack to redraw plt3
addi $sp, $sp, -4
sw $s0, 0($sp)
jal RedrawPlatform

lw $s0, platform4		# push the address of platform4 to the stack to redraw plt4
addi $sp, $sp, -4
sw $s0, 0($sp)
jal RedrawPlatform

sw $s7, 0($sp)
lw $ra, 0($sp)

add $t5, $t5, 4		# increment the counter
sw $t5, moveCounter
sw $s6, horizontalInd
beq $t5, 12, changeInd  # make the indicator 1
j exitRight
changeInd:
li, $s6, 1
sw $s6, horizontalInd
exitRight:
jr $ra				# jump back to the central loop

shiftPlatformsLeft:
lw $t5, moveCounter
lw $s6, horizontalInd

li, $s6, 1			# make the indicator 1


lw $t2, platform2		# $t2 stores the leftmost address for platform2
lw $t3, platform3 		# $t3 stores the leftmost address for platform3
lw $t5, platform4 		# $t5 stores the leftmost address for platform4

addi $t2, $t2, -4		# shift down the leftmost address for platform2 for -128 units
addi $t3, $t3, -4		# shift down the leftmost address for platform3 for -128 units
addi $t5, $t5, -4

sw $t2, platform2
sw $t3, platform3
sw $t5, platform4

addi $sp, $sp, -4
sw $ra, 0($sp)
lw $t9, 0($sp)

lw $s0, platform2		# push the address of platform2 to the stack to redraw plt2
addi $sp, $sp, -4
sw $s0, 0($sp)
jal RedrawPlatform

lw $s0, platform3		# push the address of platform3 to the stack to redraw plt3
addi $sp, $sp, -4
sw $s0, 0($sp)
jal RedrawPlatform

lw $s0, platform4		# push the address of platform4 to the stack to redraw plt4
addi $sp, $sp, -4
sw $s0, 0($sp)
jal RedrawPlatform

sw $t9, 0($sp)
lw $ra, 0($sp)

addi $t5, $t5, -4		# decrease the counter
sw $t5, moveCounter
sw $s6, horizontalInd
beq $t5, 0, changeInd2 	# whether to make the indicator 0
j exitLeft
changeInd2:
li, $s6, 0
sw $s6, horizontalInd

exitLeft:
jr $ra				# jump back to the central loop

RedrawTheDoo:
lw $t0, doodlerColor		# $t0 stores the color for doo
lw $t1, dooAddressBottom 	# $t1 stores the bottom address for doo
lw $t2, dooAddressMid 		# $t2 stores the mid address for doo
lw $t3, dooAddressTop 		# $t3 stores the top address for doo

sw $t0, 0($t3) 			# paint the top
sw $t0, 0($t2) 			# paint the left trunk
sw $t0, 4($t2) 			# paint the mid trunk
sw $t0, 8($t2) 			# paint the right trunk
sw $t0, 0($t1) 			# paint the left foot of doo
sw $t0, 8($t1) 			# paint the right foot of doo

jr $ra				# jump back to the centrl loop

RedrawPlatform:
lw $t2, boardColor		# $t2 stores the color for the platform
lw $t0, 0($sp)			# pop off the leftmost unit of the platform
addi $sp, $sp, 4

sw $t2, 4($t0)			# paint the leftmost unit of the random board
sw $t2, 8($t0)
sw $t2, 12($t0)
sw $t2, 16($t0)
sw $t2, 20($t0)
sw $t2, 24($t0)
sw $t2, 28($t0)

jr $ra				# jump back to the centrl loop

DrawNotifications:

lw $t2,backColor

# pop off which notification to draw from the stack
lw $t0, 0($sp)
addi $sp, $sp, 4
j draw_five

draw_five:
ble $t0, 5, draw_ten

# draw the first row for "wow"
lw $s0, row2
sw $t2, 0($s0)
sw $t2, 28($s0)
sw $t2, 36($s0)
sw $t2, 40($s0)
sw $t2, 44($s0)
sw $t2, 48($s0)
sw $t2, 56($s0)
sw $t2, 84($s0)

lw $s0, row3
sw $t2, 0($s0)
sw $t2, 28($s0)
sw $t2, 36($s0)
sw $t2, 48($s0)
sw $t2, 56($s0)
sw $t2, 84($s0)

lw $s0, row4
sw $t2, 4($s0)
sw $t2, 24($s0)
sw $t2, 36($s0)
sw $t2, 48($s0)
sw $t2, 60($s0)
sw $t2, 80($s0)

lw $s0, row5
sw $t2, 4($s0)
sw $t2, 12($s0)
sw $t2, 16($s0)
sw $t2, 24($s0)
sw $t2, 36($s0)
sw $t2, 48($s0)
sw $t2, 60($s0)
sw $t2, 68($s0)
sw $t2, 72($s0)
sw $t2, 80($s0)

lw $s0, row6
sw $t2, 8($s0)
sw $t2, 20($s0)
sw $t2, 36($s0)
sw $t2, 40($s0)
sw $t2, 44($s0)
sw $t2, 48($s0)
sw $t2, 64($s0)
sw $t2, 76($s0)

jr $ra

draw_ten:
bne $t0, 10, draw_fifteen
jr $ra

draw_fifteen:
bne $t0, 10, exitDrawNotification
jr $ra

exitDrawNotification:
jr $ra

OverDraw:
lw $t0, overColor1
lw $t1, overColor2
lw $t2,backColor
lw $t3, pressColor

# draw first row
lw $s0, row1
sw $t2, 0($s0)
sw $t2, 4($s0)
sw $t2, 8($s0)
sw $t2, 12($s0)
sw $t2, 20($s0)
sw $t2, 24($s0)
sw $t2, 28($s0)
sw $t2, 32($s0)
sw $t2, 40($s0)
sw $t2, 56($s0)
sw $t2, 64($s0)
sw $t2, 68($s0)
sw $t2, 72($s0)
sw $t2, 76($s0)

lw $s0, row2
sw $t2, 0($s0)
sw $t0, 4($s0)
sw $t0, 8($s0)
sw $t0, 12($s0)
sw $t0, 16($s0)
sw $t2, 20($s0)
sw $t0, 24($s0)
sw $t0, 28($s0)
sw $t0, 32($s0)
sw $t0, 36($s0)
sw $t2, 40($s0)
sw $t0, 44($s0)
sw $t2, 52($s0)
sw $t2, 56($s0)
sw $t0, 60($s0)
sw $t2, 64($s0)
sw $t0, 68($s0)
sw $t0, 72($s0)
sw $t0, 76($s0)
sw $t0, 80($s0)

lw $s0, row3
sw $t2, 0($s0)
sw $t0, 4($s0)
sw $t2, 8($s0)
sw $t2, 12($s0)
sw $t2, 20($s0)
sw $t0, 24($s0)
sw $t2, 28($s0)
sw $t2, 32($s0)
sw $t0, 36($s0)
sw $t2, 40($s0)
sw $t0, 44($s0)
sw $t0, 48($s0)
sw $t0, 56($s0)
sw $t0, 60($s0)
sw $t2, 64($s0)
sw $t0, 68($s0)
sw $t2, 72($s0)
sw $t2, 76($s0)

lw $s0, row4
sw $t2, 0($s0)
sw $t0, 4($s0)
sw $t0, 12($s0)
sw $t0, 16($s0)
sw $t2, 20($s0)
sw $t0, 24($s0)
sw $t0, 28($s0)
sw $t0, 32($s0)
sw $t0, 36($s0)
sw $t2, 40($s0)
sw $t0, 44($s0)
sw $t0, 52($s0)
sw $t2, 56($s0)
sw $t0, 60($s0)
sw $t2, 64($s0)
sw $t0, 68($s0)
sw $t0, 72($s0)
sw $t0, 76($s0)
sw $t0, 80($s0)

lw $s0, row5
sw $t2, 0($s0)
sw $t1, 4($s0)
sw $t2, 8($s0)
sw $t2, 12($s0)
sw $t1, 16($s0)
sw $t2, 20($s0)
sw $t1, 24($s0)
sw $t2, 32($s0)
sw $t1, 36($s0)
sw $t2, 40($s0)
sw $t1, 44($s0)
sw $t2, 56($s0)
sw $t1, 60($s0)
sw $t2, 64($s0)
sw $t1, 68($s0)
sw $t2, 72($s0)
sw $t2, 76($s0)

lw $s0, row6
sw $t1, 4($s0)
sw $t1, 8($s0)
sw $t1, 12($s0)
sw $t1, 16($s0)
sw $t1, 24($s0)
sw $t1, 36($s0)
sw $t1, 44($s0)
sw $t1, 60($s0)
sw $t1, 68($s0)
sw $t1, 72($s0)
sw $t1, 76($s0)
sw $t1, 80($s0)

lw $s0, row7
sw $t2, 0($s0)
sw $t2, 4($s0)
sw $t2, 8($s0)
sw $t2, 12($s0)
sw $t2, 20($s0)
sw $t2, 36($s0)
sw $t2, 44($s0)
sw $t2, 48($s0)
sw $t2, 52($s0)
sw $t2, 56($s0)
sw $t2, 64($s0)
sw $t2, 68($s0)
sw $t2, 72($s0)
sw $t2, 76($s0)

lw $s0, row8
sw $t2, 0($s0)
sw $t0, 4($s0)
sw $t0, 8($s0)
sw $t0, 12($s0)
sw $t0, 16($s0)
sw $t2, 20($s0)
sw $t0, 24($s0)
sw $t2, 36($s0)
sw $t0, 40($s0)
sw $t2, 44($s0)
sw $t0, 48($s0)
sw $t0, 52($s0)
sw $t0, 56($s0)
sw $t0, 60($s0)
sw $t2, 64($s0)
sw $t0, 68($s0)
sw $t0, 72($s0)
sw $t0, 76($s0)
sw $t0, 80($s0)

lw $s0, row9
sw $t2, 0($s0)
sw $t0, 4($s0)
sw $t2, 12($s0)
sw $t0, 16($s0)
sw $t0, 24($s0)
sw $t2, 32($s0)
sw $t0, 40($s0)
sw $t2, 44($s0)
sw $t0, 48($s0)
sw $t2, 52($s0)
sw $t2, 56($s0)
sw $t2, 64($s0)
sw $t0, 68($s0)
sw $t2, 72($s0)
sw $t2, 76($s0)
sw $t0, 80($s0)

lw $s0, row10
sw $t2, 0($s0)
sw $t0, 4($s0)
sw $t2, 12($s0)
sw $t0, 16($s0)
sw $t2, 24($s0)
sw $t0, 28($s0)
sw $t2, 32($s0)
sw $t0, 36($s0)
sw $t2, 44($s0)
sw $t0, 48($s0)
sw $t0, 52($s0)
sw $t0, 56($s0)
sw $t0, 60($s0)
sw $t2, 64($s0)
sw $t0, 68($s0)
sw $t0, 72($s0)
sw $t0, 76($s0)
sw $t0, 80($s0)

lw $s0, row11
sw $t2, 0($s0)
sw $t1, 4($s0)
sw $t2, 8($s0)
sw $t2, 12($s0)
sw $t1, 16($s0)
sw $t1, 28($s0)
sw $t1, 36($s0)
sw $t2, 44($s0)
sw $t1, 48($s0)
sw $t2, 52($s0)
sw $t2, 56($s0)
sw $t2, 64($s0)
sw $t1, 68($s0)
sw $t1, 76($s0)

lw $s0, row12
sw $t1, 4($s0)
sw $t1, 8($s0)
sw $t1, 12($s0)
sw $t1, 16($s0)
sw $t1, 32($s0)
sw $t1, 48($s0)
sw $t1, 52($s0)
sw $t1, 56($s0)
sw $t1, 60($s0)
sw $t1, 68($s0)
sw $t1, 80($s0)

jr $ra

Restart:

li, $t0, 0x10008f58
sw, $t0, platform1
sw, $t0, platform2
sw, $t0, platform3
sw, $t0, platform4

li, $t0, 0x10008f64
sw, $t0, dooAddressBottom

li, $t0, 0x10008ee4
sw, $t0, dooAddressMid

li, $t0, 0x10008e68
sw, $t0, dooAddressTop

li, $t0, 0x10008f6c
sw, $t0, dooAddressBottomRight

li, $t0, 0xfecd1a
sw, $t0, boardColor

li $t0, 0
li $k0, 0
sw $t0, score

jr $ra

GameOver:
FinalUserInput:
# check user input
lw $t8, 0xffff0000
beq $t8, 1 , k_input
j drawOver

k_input:
lw $t9, 0xffff0004
beq $t9, 0x73, respond_to_s
j drawOver

respond_to_s:
jal Restart
j main

drawOver:
jal OverDraw
j FinalUserInput

Exit:
li $v0, 10 			# terminate the program gracefully
syscall




















