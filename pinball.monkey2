#Import "<mojo>"
#Import "<std>"

#Import "table.data"

Using mojo..
Using std..

#Rem 
 * 
 * a 4k pinball game originall source made available by tombr in java
 * converted to monkey by Jesse
 *
#End Rem
 
 Global ATR:Float
 
     ' the size of the window
Const FRAME_WIDTH:Int 		= 1024
Const FRAME_HALF_WIDTH:Int 	= FRAME_WIDTH / 2
Const FRAME_HEIGHT:Int 		= 768
Const LEVEL_HEIGHT:Int 		= 256*6+48
Const MAX_OBJ_COUNT:Int 	= $10000
	' the game state
Const LOADING:Int 			= 0
Const PLAYING:Int 			= 1
Const GAME_OVER:Int 		= 2

 
Class Pinball Extends Window
	
	Field USE_ANIMATED_SCORE:Bool		= True 
	Field USE_THICK_LINES:Bool 			= True
	Field SHOW_BONUS_TEXT:Bool			= True
	Field USE_BLINK:Bool				= True
	Field DISABLE_RESIZE:Bool 			= False
	Field USE_GET_HEIGHT:Bool 			= True
	Field USE_GETES:Bool				= True
	Field USE_EXTRABALL:Bool			= True
	Field BACKGROUND_GRADIENT:Bool 		= True
	Field USE_FLASH:Bool 				= True
	Field USE_SHADED_BALL:Bool 	 		= True
	Field OUTLINE_SIRCLES:Bool	 		= True
	Field FLASH_SIRCLE_SIZE:Bool	 	= True
	Field USE_GROUP_BONUS:Bool			= True
	Field DRAW_BALL_SHADOW:Bool			= True
	Field DRAW_BUMPER_SHADOWS:Bool		= True
	Field USE_EXTRABALL_TEXT:Bool   	= False
	Field USE_BULLSEYE_TEXT:Bool		= True
	Field USE_MULTIPLIER_TEXT:Bool		= True
		
	Field ANGLE_SCALE:Float = (2 * Pi) / 127.0
	
	Field FONT_ITALIC_BOLD:Int = 3
	Field LINE_COLOR:Int = $aaaa66
	Field BACKGROUND_COLOR:Int = $ff2f174f
	Field MULTIPLIER_COLOR:int = $1f6faf
	
	' color components must be less than 16 since its scaled up
	Field BUMPER_COLOR:Int = $0a0d09 
	
	Field FLASH_FRAME_IDX:Int = ((512*3+100)/24)
	
	Field VK_LEFT:Int		= Key.Left
	Field VK_RIGHT:Int		= Key.Right
	Field VK_NEW_GAME:Int	= Key.Enter
	Field VK_ESCAPE:Int		= Key.Escape
	Field VK_TILT:Int		= Key.Space
	
	Field BEHAVIOUR_GROUP1_ARROW:Int 	= 1
	Field BEHAVIOUR_GROUP2_ARROW:Int 	= 2
	Field BEHAVIOUR_GROUP3_ARROW:Int 	= 3
	Field BEHAVIOUR_LEFT_OUTER_LANE:Int = 4
	Field BEHAVIOUR_RIGHT_OUTER_LANE:Int= 5
'	FIeld BEHAVIOUR_INLANE_ARROW:Int 	= 6
'	FIeld BEHAVIOUR_BUMPER_ARROW:Int 	= 7
	Field BEHAVIOUR_UPPER_LEFT:Int 		= 8
	Field BEHAVIOUR_UPPER_RIGHT:Int 	= 9
	Field BEHAVIOUR_START:Int 			= 10
	Field BEHAVIOUR_GAME_OVER:Int 		= 11
	Field BEHAVIOUR_BULLSEYE:Int 		= 12
	Field BEHAVIOUR_BLINKERS:Int 		= 13
	Field BEHAVIOUR_MULTIPLIER:Int 		= 14

	Field GROUP_MULTIPLIER:Int = 0
	Field GROUP_DROP1:Int 		= 1
	Field GROUP_DROP2:Int 		= 2
	Field GROUP_DROP3:Int 		= 3
	Field GROUP_DROP4:Int 		= 4
	Field GROUP_DROP5:Int 		= 5
	Field GROUP_INLANE:Int		= 6
	Field GROUP_BUMPER:Int		= 7
	Field GROUP_UPPER_LEFT:Int 	= 8
	Field GROUP_UPPER_RIGHT:Int = 9
	
	Field VISIBLE_MASK:Int 		= (1 Shl 0)	
	Field COLLIDABLE_MASK:Int 	= (1 Shl 1)	
	Field ROLL_OVER_MASK:Int 	= (1 Shl 2)
	Field DROP_DOWN_MASK:Int 	= (1 Shl 3)
	Field GATE_MASK:Int 		= (1 Shl 4)
	Field BUMPER_MASK:Int		= (1 Shl 5)
	
	

	' Fewer bytes than Math.PI
	Field BOUNCE_NORMAL:Float 	= 1.5
	Field BOUNCE_BUMPER:Float 	= 2.2
	
	' The ball radius
	Field BALL_RADIUS:Int = 24
	
	' hardcode length of flippers
	Field flipperLength:Int = 134
	
	' 16 physics iterations per frame
	Field MAX_SPEED :Int			= 3
	Field GRAVITY:Float 			= 0.00077 '0.0008f
	Field FRICTION:Float 			= 0.999985 '0.999985f
	Field FLIPPER_SPEED:Float 		= (Pi * 2 / 400.0)
	Field LAUNCH_SPEED:Int 			= -2
	Field LAUNCH_DIV:Int 			= 512
	Field BUMPER_ADD:Float 			= 0.25						
	Field PUSH_DIV_X:Int 			= 4
	Field PUSH_DIV_Y:Float 			= 1.7
	Field ITERATIONS:Int 			= 14
	Field KICKER_VEL:Int 			= -2

	' distance moved by edge of flipper during one step
'	2 50 16.82785923385599
'	4 100 8.418083432938381
'	8 200 4.209561039567941
'	16 400 2.104845438174637
'	32 800 1.0524308339800081	
	
	' the maximum number of objects
	
'	FIeld ID_FLAGS:Int 			= 0
	Field ID_SCORE:Int 			= 1
	Field ID_TYPE:Int 			= 2
	Field ID_BEHAVIOUR:Int 		= 3
	Field ID_X:Int 				= 4
	Field ID_Y:Int 				= 5
	Field ID_X2:Int 			= 6
	Field ID_Y2:Int 			= 7
	Field ID_COLLISION_TIME:Int = 8
	Field ID_IS_BALL_OVER:Int 	= 9
	Field ID_COLOR:Int 			= 10
	Field ID_SPECIAL:Int 		= 11
	' not part of Array
	Field ID_DISPLAY_SCORE:Int 	= 12
	Field ID_BONUS_TIME:Int 	= 13
	Field ID_BONUS_X:Int 		= 14
	Field ID_BONUS_Y:Int 		= 15
	Field ID_BONUS_TEXT:Int 	= 16
	Field ID_BULLSEYE_TIME:Int 	= 17
	Field ID_EXTRABALL_TIME:Int = 18
	Field ID_MULTIPLIER_TIME:Int= 19
	Field ID_INFO:Int = 17
	
'	FIeld FD_FLIPPER_ANGLE_VEL:Int = 0
	Field FD_FLIPPER_ANGLE:Int 		= 1
	Field FD_FLIPPER_LENGTH:Int 	= 2
	Field FD_FLIPPER_MIN_ANGLE:Int 	= 3
	Field FD_FLIPPER_MAX_ANGLE:Int 	= 4
	Field ID_FLIPPER_ANGLE_DIR:Int 	= 20
	
	Field GRP_COUNT:Int 			= 0
	Field GRP_FIRST_INDEX:Int 		= 1
	Field GRP_ACTIVATE_CNT:Int 		= 22
	Field GRP_ACTIVATE_FRAME_IDX:Int= 23
	Field GRP_BONUS_TIME:Int 		= 24
	
	' object types
	Field LINE:Int 					= 0
	Field FLIPPER:Int 				= 1
	Field SIRCLE:Int 				= 2
	Field ARROW:Int 				= 3
	
	Field STRIDE:Int 				= $20'16
	
	Field BONUS_ROLLOVER:Int 		= 5
	Field BONUS_DROPDOWN:Int 		= 5
	Field BONUS_UPPER_LEFT:Int 		= 25
	Field BONUS_UPPER_RIGHT:Int 	= 25
	Field BONUS_KICKER:Int 			= 15
	Field BUMPER_TIME_BONUS:Int 	= 5
	Field DROPDOWN_TIME_BONUS:Int 	= 10
	Field ROLLOVER_TIME_BONUS:Int 	= 10
	
	Field BUMPER_ARROW_IDX:Int 		= 32
	Field INLINE_ARROW_IDX:Int 		= 36
	Field START_IDX:Int 			= 5
	
	' what keys are down indexed by keyCode
	Field k:Bool[] 					= new Bool[$10000]     
	
'     * Constructor Where the game loop is in.
 


	'enableEvents(AWTEvent.MOUSE_EVENT_MASK)

 	' frame timing variable
 	Field lastFrame:Long = 0
	    
	' The position of the ball
	Field bally:Float = 0
    Field ballx:Float = 0
		
	' The current velocity of the ball in pixels per tick
	Field ballVely:Float = 0
	Field ballVelx:Float = 0

	' The current rotation of the flipper
	Field flipperAngle:Float = 0
		
	' Flipper moves 1 / 100 of a sircle counter clockwise every tick
	Field flipperUpDelta:Int = 0
		
	' The angle velocity is the angle moves last tick
	Field flipperAngleVel:Float = 0
		
	' float object data goes 
	Field floatData:Float[] = new Float[MAX_OBJ_COUNT]
		
	' groups stored as (index of first object, number of objects in group)
	Field groupData:Int[] = Null
		
	' number of groups
	Field numGroups:int = 0
		
	' object int data and other stuff goes here
	Field intData:Int[] = New Int[MAX_OBJ_COUNT]
		
	' maps from behaviour id to an object containing the id
	Field behaviourObjMap:Int[] = new int[MAX_OBJ_COUNT]
		
	' blink data in own array is smaller
	Field blinkData:Int[] = Null

	' Common object variables
	Field objx:Int = 0
	Field objy:Int = 0
		        
	Field objCount:Int = 0

	' current frameIdx used a lot to determine if it blinks. Game runs at 60 frames per second.
	Field frameIdx:Int = 0
		
	' the current score
	Field score:Int = 0
		
	' the current multiplier. All bonus scores are multiplied by the multiplier before being added to score.
	Field multiplier:Int = 0
		
	' vertical scroll position
	Field levely:Int = 0
		
	' start off in loading state
	Field state:Int = LOADING

	' true when space is pressed and playfield is in a moved state
	Field tilt:Bool = False
	Field pushed:Bool = False
	Field pushedBall:Bool = false
	Field wasTiltKeyPressed:Bool = false
	Field pushTime:Int = 0
		
	' the score when the next extra ball is awarded
	Field extraBallTarget:Int = 0

	' Use a large italic bold font. Selecting the default font saves some space.
'Font font = new Font("", FONT_ITALIC_BOLD, 32)
		
	' when the next vertical flash starts
	Field flashFrameIdx:Int = 0
		
	' set window size

	Method New( title:String="Pinball",width:Int=FRAME_WIDTH,height:Int=FRAME_HEIGHT,flags:WindowFlags=Null )

		Super.New( title,width,height,flags )
		ATR = Pi/180.0
		Init()
	End

	Method Init()
		' load level
		blinkData = new Int[MAX_OBJ_COUNT]
		groupData = new Int[MAX_OBJ_COUNT]

		' use file file named "a" when develeoping since we cant insert level everytime eclipse compiles. 
'		DataInputStream dataIn = new DataInputStream(getClass().getResourceAsStream("/a.class"))
		Local dataIn := FileStream.Open(AssetsDir()+"table.data","r")
					
		' find magic numbers in level
		While (Not (dataIn.ReadUByte() = 124 And dataIn.ReadUByte() = 124))
		Wend
		Local flippers:Int = dataIn.ReadUByte()
		Local sircles:Int = dataIn.ReadUByte()
		Local arrows:Int = dataIn.ReadUByte()
		Local lines:Int = dataIn.ReadUByte()
		objCount = dataIn.ReadUByte()
		
		' flags, score and behavior id is common data read in for all objects
		For Local i:Int = 0 Until objCount
			intData[i * STRIDE] = dataIn.ReadUByte() ' ID_FLAGS is 0
			intData[i * STRIDE + ID_SCORE] = dataIn.ReadUByte()
			intData[i * STRIDE + ID_BEHAVIOUR] = dataIn.ReadUByte()
			intData[i * STRIDE + ID_COLOR] = LINE_COLOR
		Next
		' position is also common for all objects. 
		' Read seperately to improve compression since position is more 
		For Local i:Int = 0 Until objCount						
			' fill inn behaviour to object map
			behaviourObjMap[intData[i * STRIDE + ID_BEHAVIOUR]] = i
			intData[i * STRIDE + ID_X] = dataIn.ReadUByte() * 4
			intData[i * STRIDE + ID_Y] = dataIn.ReadUByte() * 6
		Next
					
		Local objCountOff:Int = 0
					
		' read the radius of all the sircles
		While (sircles > 0)
			intData[objCountOff + ID_TYPE] = SIRCLE
			intData[objCountOff + ID_X2] = dataIn.ReadUByte()
			objCountOff += STRIDE
			sircles -= 1
		Wend 

		' read the direction of all the arrows
		While (arrows > 0)
			intData[objCountOff + ID_TYPE] = ARROW
			intData[objCountOff + ID_X2] = dataIn.ReadUByte()
			objCountOff += STRIDE
			arrows -= 1
		Wend

		' read the flipper min, max angle and direction
		While (flippers > 0)
			intData[objCountOff + ID_TYPE] = FLIPPER
			floatData[objCountOff + FD_FLIPPER_MIN_ANGLE] = dataIn.ReadUByte() * ANGLE_SCALE
			floatData[objCountOff + FD_FLIPPER_MAX_ANGLE] = dataIn.ReadUByte() * ANGLE_SCALE
			Print floatData[objCountOff+FD_FLIPPER_MIN_ANGLE]+"  "+floatData[objCountOff+FD_FLIPPER_MAX_ANGLE]
			intData[objCountOff + ID_FLIPPER_ANGLE_DIR] = (dataIn.ReadUByte() - 1)
			objCountOff += STRIDE
			flippers -= 1
		Wend
					
		' read end position of all the lines
		While (lines > 0)
			intData[objCountOff + ID_X2] = dataIn.ReadUByte() * 4
			intData[objCountOff + ID_Y2] = dataIn.ReadUByte() * 6
			objCountOff += STRIDE
			lines -= 1
		Wend
										
		' unpack line strips
		Local strips:Int = dataIn.ReadUByte()
		
		While (strips > 0)
			' number of lines in the strip
			Local stripLines:Int = dataIn.ReadUByte()
						
			' the index of the line that started the strip
			Local prevIdx:Int = dataIn.ReadUByte()
						
			While (stripLines > 0)
				' copy previous line
				For Local i:int =0 Until STRIDE
					intData[objCountOff + i] = intData[prevIdx * STRIDE + i]
					floatData[objCountOff + i] = floatData[prevIdx * STRIDE + i]
				Next
							
				' start position is end position of the previous line
				intData[objCountOff + ID_X] = intData[objCountOff + ID_X2]
				intData[objCountOff + ID_Y] = intData[objCountOff + ID_Y2]
							
				' read in end position
				intData[objCountOff + ID_X2] = dataIn.ReadUByte() * 4
				intData[objCountOff + ID_Y2] = dataIn.ReadUByte() * 6							
							
				' the use this line as the base for the next line in the strip
				prevIdx = objCount
				objCount += 1
				objCountOff += STRIDE
				stripLines -= 1
			Wend
			strips  -= 1
		Wend

		' read groups as (count, first index) pairs 
		numGroups = dataIn.ReadUByte()
		For Local i:Int=0  Until numGroups*2
			groupData[i] = dataIn.ReadUByte()
		Next
					
		' initialize new game
		multiplier = 1
		score = 0
		state = PLAYING
		tilt = False
		extraBallTarget = 1000
		ballx = intData[behaviourObjMap[BEHAVIOUR_START] * STRIDE + ID_X]
		bally = intData[behaviourObjMap[BEHAVIOUR_START] * STRIDE + ID_Y]
	
	End Method

	Method OnRender(canvas:Canvas) Override
			' the bonus score awarded this frame
			local bonus:Int = 0

			' update state more than once per frame to speed up animation
			for Local updateIdx:Int = 0 Until ITERATIONS

				' update state	
				if (state = PLAYING)
					' check for tilt
					pushed = Not tilt And k[VK_TILT]
					if (Not wasTiltKeyPressed And pushed)
						if (frameIdx < pushTime)
							tilt = True
						End
						pushTime = frameIdx + 31
						pushedBall = False
					End
					wasTiltKeyPressed = pushed

					' update ball
					
					' make sure ball don't go so fast it goes threw the lines
					' also add gravity to y and friction to x
					ballVelx = Min<Float>( MAX_SPEED, ballVelx * FRICTION)
					ballVely = Min<float>( MAX_SPEED, ballVely * FRICTION + GRAVITY)
					ballVelx = Max<Float>(-MAX_SPEED, ballVelx)
					ballVely = Max<Float>(-MAX_SPEED, ballVely)
					
					ballx += ballVelx
					bally += ballVely
					' Collision result variables 
					
					' the projected position of the ball on the line
					Local closestx:Float = 0
					Local closesty:Float = 0
					
					' true if an intersectino accured
					Local foundCollision:Bool = False
					
					' the index of the closest line
					Local collisionObjIdx:Int = 0
					
					' the distance to the closest line
					Local closestDistance:Float = 0

					' detect collision between objects and ball
					For Local objIdx:Int = 0 Until objCount
						Local objFlags:Int 	 	= intData[objIdx * STRIDE]
						Local objBehaviour:Int 	= intData[objIdx * STRIDE + ID_BEHAVIOUR]
						objx 			 		= intData[objIdx * STRIDE + ID_X]
						objy 			 		= intData[objIdx * STRIDE + ID_Y]
						Local linex2:Int 		= intData[objIdx * STRIDE + ID_X2]
						Local liney2:Int 		= intData[objIdx * STRIDE + ID_Y2]
						
						' the closest point on line if inside ball radius
						Local tempProjectedx:Float 	= 0
						Local tempProjectedy:Float 	= 0
						Local dist:Float 			= 0
						Local intersected:Bool = false
					
						Select (intData[objIdx * STRIDE + ID_TYPE])
						case FLIPPER
							' update the flipper
							flipperUpDelta 	= intData[objIdx * STRIDE + ID_FLIPPER_ANGLE_DIR]
							flipperAngle 	= floatData[objIdx * STRIDE + FD_FLIPPER_ANGLE]
							flipperAngleVel = floatData[objIdx * STRIDE]
							Local newAngle:Float = flipperAngle -	((Not tilt) And k[flipperUpDelta < 0 ? VK_LEFT Else VK_RIGHT] ? -flipperUpDelta Else flipperUpDelta) * FLIPPER_SPEED
							newAngle = Max<Float>(floatData[objIdx * STRIDE + FD_FLIPPER_MIN_ANGLE], Min(floatData[objIdx * STRIDE + FD_FLIPPER_MAX_ANGLE], newAngle))
							floatData[objIdx * STRIDE] = newAngle - flipperAngle
							linex2 = (objx + Cos(newAngle) * flipperLength)
							liney2 = (objy + Sin(newAngle) * flipperLength)

							intData[objIdx * STRIDE + ID_X2] = linex2
							intData[objIdx * STRIDE + ID_Y2] = liney2
							floatData[objIdx * STRIDE + FD_FLIPPER_ANGLE] = newAngle
							
							' pass threw to line that does the collision detection
							' dot line with (ball - line endpoint)
							Local rrr:Float = (ballx-objx) * (linex2-objx) + (bally-objy) * (liney2-objy)
							Local Leng:Float = length(linex2-objx, liney2-objy)
							Local t:Float = rrr / Leng / Leng
							If (t >= 0 And t <= 1)
								tempProjectedx = objx + (t * (linex2-objx))
								tempProjectedy = objy + (t * (liney2-objy))
								dist = length(ballx-tempProjectedx, bally-tempProjectedy)
								intersected = (dist <= BALL_RADIUS)
							Else
								' center of ball is outside line segment. Check End points.
								dist = length(ballx-objx, bally-objy)
								Local distance2:Float = length(ballx-linex2, bally-liney2)
								If (dist < BALL_RADIUS)
									intersected = True
									tempProjectedx = objx
									tempProjectedy = objy
								EndIf
								If (distance2 < BALL_RADIUS And distance2 < dist)
									intersected = True
									tempProjectedx = linex2
									tempProjectedy = liney2
									dist = distance2
								EndIf
							EndIf
							
						case LINE
							' dot line with (ball - line endpoint)
							Local rrr:Float = (ballx-objx) * (linex2-objx) + (bally-objy) * (liney2-objy)
							Local len:Float = length(linex2-objx, liney2-objy)
							Local t:Float = rrr / len / len
							if (t >= 0 And t <= 1)
								tempProjectedx = objx + (t * (linex2-objx))
								tempProjectedy = objy + (t * (liney2-objy))
								
								dist = length(ballx-tempProjectedx, bally-tempProjectedy)
								intersected = (dist <= BALL_RADIUS)
							Else
								' center of ball is outside line segment. Check end points.
								dist = length(ballx-objx, bally-objy)
								Local distance2:Float = length(ballx-linex2, bally-liney2)
								If (dist < BALL_RADIUS)
									intersected = True
									tempProjectedx = objx
									tempProjectedy = objy
								End
								If (distance2 < BALL_RADIUS And distance2 < dist)
									intersected = True
									tempProjectedx = linex2
									tempProjectedy = liney2
									dist = distance2
								End
							End

						case SIRCLE
							' linex2 is sircle radius
							Local dx:Float = ballx - objx
							Local dy:Float = bally - objy
							dist = length(dx, dy) - linex2
							if (dist < BALL_RADIUS)
								intersected = True
								tempProjectedx = objx + (dx / length(dx, dy) * linex2)
								tempProjectedy = objy + (dy / length(dx, dy) * linex2)
							End
						End
						
						if (intersected)
							Local nDotBall:Float = 0
							
							' Do one way gate logic by turning off collision detection if it is entered from behind
							if (USE_GETES)
								If ((objFlags & GATE_MASK) <> 0)
									' dot ball center, line endpoint vector on to line normal
									' if it is positive the ball do not collide with ball
									nDotBall = (ballx-objx) * -(liney2-objy) + (bally-objy) * (linex2-objx)
									if (nDotBall > 0)
										' turn off collision detection
										intData[objIdx * STRIDE] &= ($ff ~ COLLIDABLE_MASK)
									End
								End
							End
						
							' store closest hit
							if ((nDotBall <= 0) And (objFlags & COLLIDABLE_MASK) <> 0 And (Not foundCollision Or dist < closestDistance))
								closestDistance = dist
								foundCollision = intersected
								collisionObjIdx = objIdx
								closestx = tempProjectedx
								closesty = tempProjectedy
							End
							
							' do trigger logic
							if (intData[objIdx * STRIDE + ID_IS_BALL_OVER] = 0)
								intData[objIdx * STRIDE + ID_IS_BALL_OVER] = 1

								' skip score on hidden dropdowns
								if (Not tilt And ((intData[objIdx * STRIDE] & DROP_DOWN_MASK) = 0  Or (intData[objIdx * STRIDE] & VISIBLE_MASK) <> 0))
									score += intData[objIdx * STRIDE + ID_SCORE]
								End
								' store collision time, is used to animate bumpers
								intData[objIdx * STRIDE + ID_COLLISION_TIME] = frameIdx
								if (objBehaviour = BEHAVIOUR_GAME_OVER)
									if (USE_EXTRABALL)
										if (blinkData[START_IDX] <> 0) 
											blinkData[START_IDX] = 0
											ballx = intData[behaviourObjMap[BEHAVIOUR_START] * STRIDE + ID_X]
											bally = intData[behaviourObjMap[BEHAVIOUR_START] * STRIDE + ID_Y]
											foundCollision = False
											tilt = False
										Else
											state = GAME_OVER
										End
									Else
										state = GAME_OVER
									End
								End
								if (objBehaviour = BEHAVIOUR_START)
									' pseudo random launch speed
									ballVely = LAUNCH_SPEED - ((frameIdx & $ff) / Float(LAUNCH_DIV))
									
									' flash at start
									flashFrameIdx = frameIdx+FLASH_FRAME_IDX
								End
								if (USE_GROUP_BONUS)
									if ((objFlags & BUMPER_MASK) <> 0 And groupData[GROUP_BUMPER*STRIDE+GRP_BONUS_TIME] > frameIdx)
										bonus += BUMPER_TIME_BONUS
									End
								End
								if ((objFlags & DROP_DOWN_MASK) <> 0)
									if (USE_GROUP_BONUS)
										if (frameIdx < groupData[GROUP_UPPER_RIGHT*STRIDE+GRP_BONUS_TIME] And (intData[objIdx * STRIDE] & VISIBLE_MASK) <> 0)
											bonus += DROPDOWN_TIME_BONUS
										End
									End
									' turn off visible and collidable
									intData[objIdx * STRIDE] = DROP_DOWN_MASK
								End
								if ((objFlags & ROLL_OVER_MASK) <> 0)
									intData[objIdx * STRIDE] |= VISIBLE_MASK
									if (USE_GROUP_BONUS)
										if (frameIdx < groupData[GROUP_UPPER_LEFT*STRIDE+GRP_BONUS_TIME])
											bonus += ROLLOVER_TIME_BONUS
										End
									End
								End
								if (objBehaviour = BEHAVIOUR_UPPER_LEFT And frameIdx < blinkData[INLINE_ARROW_IDX])
									blinkData[INLINE_ARROW_IDX] = 0
									bonus += BONUS_UPPER_LEFT
								End
								if (objBehaviour = BEHAVIOUR_UPPER_RIGHT And frameIdx < blinkData[BUMPER_ARROW_IDX])
									blinkData[BUMPER_ARROW_IDX] = 0
									bonus += BONUS_UPPER_RIGHT
								End
								if (objBehaviour = BEHAVIOUR_BULLSEYE)
									Local bonusShift:Int = 0
									for Local i:Int=0 Until 3
										If (frameIdx < blinkData[33+i])
											blinkData[33+i] = 0
											bonusShift+= 1
										End
									Next
									
									bonus += 25 Shl bonusShift
									if (USE_BULLSEYE_TEXT)										
										intData[ID_BULLSEYE_TIME] = frameIdx + 60*3
									End
								End
								if ((objBehaviour = BEHAVIOUR_RIGHT_OUTER_LANE Or objBehaviour = BEHAVIOUR_LEFT_OUTER_LANE) And objFlags <> 0)
									intData[objIdx * STRIDE] = 0
									ballVely = KICKER_VEL
									bonus += BONUS_KICKER
								End
							End
						Elseif (intData[objIdx * STRIDE + ID_IS_BALL_OVER] = 1)
							' ball do no longer intersect current trigger
							intData[objIdx * STRIDE + ID_IS_BALL_OVER] = 0
						
							if (USE_GETES)
								if ((objFlags & GATE_MASK) <> 0)
									' turn on collision detection again on one way gate
									intData[objIdx * STRIDE] = COLLIDABLE_MASK | GATE_MASK | VISIBLE_MASK
								End
							End
						End
					End ' end iterate objects
					
					' collision response
					if (foundCollision)
						Local objVelx:Float = 0
						Local objVely:Float = 0

						' calculate velocity of flipper at intersection point
						if (intData[collisionObjIdx * STRIDE + ID_TYPE] = FLIPPER)
							Local dx:Float = closestx - intData[collisionObjIdx * STRIDE + ID_X]
							Local dy:Float = closesty - intData[collisionObjIdx * STRIDE + ID_Y]
							Local absVel:Float = floatData[collisionObjIdx * STRIDE] * length(dx, dy)
							' flipper velocity = normal * speed
							if (length(dx, dy) <> 0)
								objVely = absVel *  dx / length(dx, dy)
								objVelx = absVel * -dy / length(dx, dy) 
							End
						End
						
						' find collision normal
						local normalx:Float = (ballx - closestx) / length(ballx - closestx, bally - closesty)
						Local normaly:Float = (bally - closesty) / length(ballx - closestx, bally - closesty)
						
						' push ball out of geometry
						ballx = closestx + normalx * BALL_RADIUS
						bally = closesty + normaly * BALL_RADIUS						
						
						' reflect the ball
						Local impactSpeed:Float = ((intData[collisionObjIdx * STRIDE] & BUMPER_MASK) = 0 Or tilt) ? ((objVelx - ballVelx) * normalx + (objVely - ballVely) * normaly) * BOUNCE_NORMAL Else ((objVelx - ballVelx) * normalx + (objVely - ballVely) * normaly) * BOUNCE_BUMPER + BUMPER_ADD
						
						ballVelx += normalx * impactSpeed
						ballVely += normaly * impactSpeed

						' add velocity in normal direction if table is pushed
						if (Not pushedBall And pushed And frameIdx < pushTime)
							pushedBall = True
							ballVelx += normalx/PUSH_DIV_X
							ballVely += normaly/PUSH_DIV_Y
						End
					End ' end collision response
					
					' generate colors
					local c:Int = MULTIPLIER_COLOR

					' check groups
					for Local groupIdx:Int = 0 Until numGroups
						' get the anded and ored flags of the elements in the group
						Local groupOr:Int = 0
						Local groupAnd:Int = $7f
						Local _or:Int = 0
						Local _and:Int = $7f
						Local blinkTime:Int = 0
						for Local i:Int=0 Until groupData[groupIdx*2]
							Local objIdx:Int = groupData[groupIdx*2+GRP_FIRST_INDEX] + i
							groupOr |= intData[objIdx * STRIDE]
							groupAnd &= intData[objIdx * STRIDE]
							if (USE_BLINK)
								blinkTime = blinkData[objIdx]
							End
						End
						
						' check if all dropdown targets is down
						if ((groupOr & VISIBLE_MASK) = 0 And (groupOr & DROP_DOWN_MASK) <> 0)
							' award bonus
							bonus += BONUS_DROPDOWN
							
							' light target arrow, group idx same as arrow behavior id
							if (intData[behaviourObjMap[groupIdx] * STRIDE + ID_TYPE] = ARROW)
								blinkData[behaviourObjMap[groupIdx]] = $ffffff
							Else
								intData[behaviourObjMap[groupIdx] * STRIDE] |= VISIBLE_MASK
							End

							' reset dropdowns to visible and collidable
							_or = VISIBLE_MASK | COLLIDABLE_MASK
						End
						
						' check if all rollovers in group are lit
						if ((groupAnd & VISIBLE_MASK) <> 0 and (groupAnd & ROLL_OVER_MASK) <> 0)
							' award bonus
							bonus += BONUS_ROLLOVER
							
							' reset rollovers to hidden and not collidable
							_and = $ff ~ (VISIBLE_MASK | COLLIDABLE_MASK)

							If (USE_GROUP_BONUS)
								' store activation count and time
								groupData[groupIdx*STRIDE+GRP_ACTIVATE_CNT] += 1
								groupData[groupIdx*STRIDE+GRP_ACTIVATE_FRAME_IDX] = frameIdx
							End
							
							If (groupIdx = GROUP_MULTIPLIER)
								' increase multiplier if it's the multiplier group
								multiplier = Min(8, multiplier+1)
								if (USE_MULTIPLIER_TEXT)
									intData[ID_MULTIPLIER_TIME] = frameIdx + 60*3
								End
							Else
								if (USE_GROUP_BONUS)
									if (groupData[groupIdx*STRIDE+GRP_ACTIVATE_CNT] Mod 3 = 0) ' replaced % with mod
										bonus += BONUS_DROPDOWN
										groupData[groupIdx*STRIDE+GRP_BONUS_TIME] = frameIdx + 60 * 30
									End
								End
								' blink target arrow 30 secs, group idx same as arrow behavior id
								blinkData[behaviourObjMap[groupIdx]] = frameIdx + 60 * 30
							End
							
							' blink the rolloevers in 1,5 seconds
							blinkTime = frameIdx + 90
						End

						' store back new element flags
						for Local i:Int=0 Until groupData[groupIdx*2]
							Local objIdx:Int = groupData[groupIdx*2+GRP_FIRST_INDEX]+i
							intData[objIdx * STRIDE] |= _or
							intData[objIdx * STRIDE] &= _and
							
							' generate group colors
							intData[objIdx * STRIDE + ID_COLOR] = c
							if (USE_BLINK)
								blinkData[objIdx] = blinkTime
							End
						Next
					
						' make the arrow color the same as the group
						if (groupIdx > 0)
							intData[behaviourObjMap[groupIdx] * STRIDE + ID_COLOR] = c
						End
						
						' generate pseudo random group colors
						c += c * c
					End ' end iterate groups
				Elseif (state = GAME_OVER And k[VK_NEW_GAME])
					' start loading level if game is over and enter is pressed
					Init()
				End
			End ' end update iterations
			
			' keep the level from scrolling past the top and bottom of the screen 
			if (bally + levely < 200)
				levely = Min<Float>(0, 200-bally)
			End
			if (bally + levely > 400)
				levely = -bally + 400
			End
			
			' calculate the level y coordinate at screen coordinate y 0
			if (USE_GET_HEIGHT)
				levely = Max<Float>(FRAME_HEIGHT-LEVEL_HEIGHT, levely)
			Else
				levely = Max<Float>(FRAME_HEIGHT-LEVEL_HEIGHT, levely)
			End

			' -------------------- draw level -------------------------
			App.RequestRender()
'			
			If (Not BACKGROUND_GRADIENT)
				' fill solid background
				canvas.Color = SetColor(BACKGROUND_COLOR)
				canvas.DrawRect(0, 0, 1024*2, 1024*2)
			End
			
			' draw level 4 pixels higher on the screen if it is pushed 
			Local levely2:Int = levely + (pushed ? -4 Else 0)
			
			' transform coordinate system to level space
			canvas.Translate(0, levely2)
			
			if (BACKGROUND_GRADIENT)
				' fill gradient background
				Local backColor:Int = BACKGROUND_COLOR
				For Local i:Int=0 Until 16
					canvas.Color = SetColor(backColor)
					backColor += $20300
					canvas.DrawRect(0, i*$7f, 1024*2, $7f)
				End
			End

			'g.setFont(font)
			'Rectangle2D bounds = Null
			Local text:String = Null
			
			Local SHADOW_COLOR:Int = $2f2f2f

			' draw objects
			for Local objIdx:Int =0 Until objCount
				' ball shadow
				If (DRAW_BALL_SHADOW)
					' draw ball shadow after sircles and arrows
					if (objIdx = 37)
						canvas.Color = SetColor(SHADOW_COLOR)
						canvas.DrawOval(ballx - BALL_RADIUS + 8, bally - BALL_RADIUS + 8, BALL_RADIUS * 2, BALL_RADIUS * 2)
					End
				End
				
				Local c:Int = intData[objIdx * STRIDE + ID_COLOR]
				objx = intData[objIdx * STRIDE + ID_X]
				objy = intData[objIdx * STRIDE + ID_Y]
				Local linex2:Int = intData[objIdx * STRIDE + ID_X2]
				Local liney2:Int = intData[objIdx * STRIDE + ID_Y2]
				
				' animate bumper by warping the color when its hit
				if ((intData[objIdx * STRIDE] & BUMPER_MASK) <> 0)
					Local color:Int = Min($f, (frameIdx - intData[objIdx * STRIDE + ID_COLLISION_TIME]))
					c = color*BUMPER_COLOR
				End

				If (USE_BLINK)
					if (frameIdx < blinkData[objIdx])
						' object is blinking
						if ((frameIdx & 31) < 15)
							' make object darker 2 times a second 
							c = (c Shr 1) & $7f7f7f
						End 
						' else object is visible and we don't touch it
					Elseif ((intData[objIdx * STRIDE] & VISIBLE_MASK) = 0)
						' make object darker if it is not visible
						c = (c Shr 1) & $7f7f7f
					End
				Else
					' make object darker if it is not visible
					if ((intData[objIdx * STRIDE] & VISIBLE_MASK) = 0)
						c = (c Shr 1) & $7f7f7f
					End
				End

				if (USE_GROUP_BONUS)
					' blink bumpers if their bonus is on
					if ((intData[objIdx * STRIDE] & BUMPER_MASK) <> 0 And groupData[GROUP_BUMPER*STRIDE+GRP_BONUS_TIME] > frameIdx And (frameIdx & 31) < 15)
						c = (c Shr 1) & $7f7f7f
					End
				End				

				if (DRAW_BUMPER_SHADOWS)
					if ((intData[objIdx * STRIDE] & BUMPER_MASK) <> 0 And intData[objIdx * STRIDE + ID_TYPE] = SIRCLE)
						canvas.Color = SetColor(SHADOW_COLOR)
						canvas.DrawOval(objx-linex2+12, objy-linex2+12, linex2+linex2, linex2+linex2)
					End
				End
				
				canvas.Color = SetColor(c)

				' bottom to top flashing animation
				Local flashy:Int = (flashFrameIdx - frameIdx) * 24
				Local pan:Bool = objy > flashy And objy < flashy+200
				if (pan)
					canvas.Color = SetColor($ffffff)
				End
				
				Select (intData[objIdx * STRIDE + ID_TYPE])
				case FLIPPER
					' flippers are always white
					canvas.Color = SetColor($ffffff)
					' pass threw so it will be rendered as line	
						If (USE_GROUP_BONUS)
							If ((frameIdx & 31) < 15 And groupData[GROUP_UPPER_RIGHT*STRIDE+GRP_BONUS_TIME] > frameIdx And (intData[objIdx * STRIDE] & DROP_DOWN_MASK) <> 0 And (intData[objIdx * STRIDE] & VISIBLE_MASK) <> 0)
								canvas.Color = New Color(1,1,1) 'SetColor($ff,$ff,$ff)
							Endif
						Endif
						canvas.DrawLine(objx, objy, linex2, liney2)
						' makes the line 3 pixels thick
						If (USE_THICK_LINES)
							canvas.DrawLine(objx-1, objy, linex2-1, liney2)
							canvas.DrawLine(objx+1, objy, linex2+1, liney2)
							' Speed up Java2D by only drawing lines 2 pixels wide. Does Not save space!
							canvas.DrawLine(objx, objy+1, linex2, liney2+1)
						Endif

				case LINE
					If (USE_GROUP_BONUS)
						if ((frameIdx & 31) < 15 And groupData[GROUP_UPPER_RIGHT*STRIDE+GRP_BONUS_TIME] > frameIdx And (intData[objIdx * STRIDE] & DROP_DOWN_MASK) <> 0 And (intData[objIdx * STRIDE] & VISIBLE_MASK) <> 0) 
							canvas.Color = SetColor($ffffff)
						End
					End
					
					canvas.DrawLine(objx, objy, linex2, liney2)
					
					' makes the line 3 pixels thick
					If (USE_THICK_LINES)
						canvas.DrawLine(objx-1, objy, linex2-1, liney2)
						canvas.DrawLine(objx+1, objy, linex2+1, liney2)
						' Speed up Java2D by only drawing lines 2 pixels wide. Does not save space!
						canvas.DrawLine(objx, objy+1, linex2, liney2+1)
					End
					
				Case SIRCLE
					' this code is optimized
					Local r:Int = linex2

					If (FLASH_SIRCLE_SIZE)
						if (pan)
							r += 5
						End					
					End
						
					canvas.DrawOval(objx-r, objy-r, r+r, r+r)
					if (OUTLINE_SIRCLES)
						canvas.Color = SetColor(0)
						if (USE_GROUP_BONUS)
							if ((frameIdx & 31) < 15 And frameIdx < groupData[GROUP_UPPER_LEFT*STRIDE+GRP_BONUS_TIME] And (intData[objIdx * STRIDE] & ROLL_OVER_MASK) <> 0)
								canvas.Color = SetColor($ffffff)
							End
						End
						canvas.DrawOval(objx-r, objy-r, r+r, r+r)
					End
				case ARROW
					DrawArc(canvas,objx+40, objy+40, 90, 90+45, 45,True,True) 'linex2 * 2, 45)			
					'break no need for a break
				End
			End ' end draw loop
			
			' light the 8 multiplier sircles in its group according to the current multiplier
			canvas.Color = SetColor($ffffff)
			for Local i:Int=0 Until 8
				text = String(i+1)
				canvas.DrawText(text, 484-14, 1260-i*84)				
				intData[(groupData[21]+i)*STRIDE] = (i < multiplier ? VISIBLE_MASK Else 0) 
			Next

			' draw ball 
			if (USE_SHADED_BALL)
				Local c:Int = $5f5f5f
				Local add:Int = 0
				For Local i:Int=0 Until 16 
					canvas.Color = SetColor(c)
					canvas.DrawOval(ballx - BALL_RADIUS + i, bally - BALL_RADIUS+i, BALL_RADIUS * 2 - i*3, BALL_RADIUS * 2 - i*3)
					c += add
					add += $10101
				End
				canvas.Color = SetColor(0)
				canvas.DrawOval(ballx - BALL_RADIUS, bally - BALL_RADIUS, BALL_RADIUS * 2, BALL_RADIUS * 2)
			Else
				canvas.DrawOval(ballx - BALL_RADIUS,bally - BALL_RADIUS, BALL_RADIUS * 2, BALL_RADIUS * 2)
			End

			' update score
			canvas.Color = SetColor($ffffff)
			if (tilt)
				bonus = 0
			End
			bonus *= multiplier
			score += bonus

			if (SHOW_BONUS_TEXT)
				if (bonus > 0)
					intData[ID_BONUS_TEXT] = bonus
					intData[ID_BONUS_X] = ballx
					intData[ID_BONUS_Y] = bally
					intData[ID_BONUS_TIME] = frameIdx + 100
				End
				if (frameIdx < intData[ID_BONUS_TIME])
					text = String(intData[ID_BONUS_TEXT] * 1000)
					canvas.DrawText(text, intData[ID_BONUS_X] - text.Length * 8, intData[ID_BONUS_Y])
					intData[ID_BONUS_Y] -= 1
				End
			End
			
			' translate back to screen space before drawing hud
			canvas.Translate(0, -levely2)
			if (USE_FLASH)
				If (bonus > 0)
					' start flash animation when bonus is awarded
					flashFrameIdx = frameIdx+FLASH_FRAME_IDX
				End
			End

			if (USE_EXTRABALL)
				' award extraball if extra ball score target is reached
				If (score > extraBallTarget)
					' state is stored in the start sircle blink field
'					blinkData[behaviourObjMap[BEHAVIOUR_START]] = $ffffff
					blinkData[START_IDX] = $ffffff
					
					' target doubles each time it is reached
					extraBallTarget *= 2
					
					If (USE_EXTRABALL_TEXT)
						intData[ID_EXTRABALL_TIME] = frameIdx + 60*3
					End
				End
			End
			
			' draw tilt text if board is tilted
			if (tilt)
				text = "TILT"
				canvas.DrawText(text, 479, 120)
			End
			if (USE_EXTRABALL_TEXT)
				If (frameIdx < intData[ID_EXTRABALL_TIME])
					text = "Extraball!"
					canvas.DrawText(text, 441, 160) ' 439, 444
				End
			End
			if (USE_BULLSEYE_TEXT)
				If (frameIdx < intData[ID_BULLSEYE_TIME])
					text = "Bullseye!"
					canvas.DrawText(text, 441, 200) ' no !,446
				End
			End
			if (USE_MULTIPLIER_TEXT)
				If (frameIdx < intData[ID_MULTIPLIER_TIME])
					text = "Multiplier!"
					canvas.DrawText(text, 441, 240)
				End
			End
			
			' draw game over text if game is over
			if (state = GAME_OVER)
				text = "Game Over - Press Enter"
				canvas.DrawText(text, FRAME_HALF_WIDTH-188, 320)
			End
			
			if (USE_ANIMATED_SCORE)
				' animate the score counting up
				intData[ID_DISPLAY_SCORE] += (score * 1000 - intData[ID_DISPLAY_SCORE]) < 8 ? (score*1000 - intData[ID_DISPLAY_SCORE]) else (score * 1000 - intData[ID_DISPLAY_SCORE]) / 8
				text = String(intData[ID_DISPLAY_SCORE])
			Else
				text = String(score * 1000)
			End
			
			canvas.DrawText(text, FRAME_HALF_WIDTH - text.Length*8, 80)

			' flip buffer
		   ' b.show()
		    
		    frameIdx +=1

		    ' wait 16 milliseconds to cap frame rate to 60 fps
'	    	While (System.nanoTime() < lastFrame + 16000)
'	    		Thread.yield()
'	    	Wend
'	    	lastFrame = System.nanoTime()	
	End Method
	
	Method length:Float(x:Float, y:Float)
		Return Sqrt(y*y+x*x)
	End Method

'	 * Sets the k member with the key states.

	'Method processKeyEvent(KeyEvent e)
	'    k[e.getKeyCode()] = (e.getID() = 401)
	'End Method
	
	Method OnKeyEvent( event:KeyEvent ) Override
		If event.Type = EventType.KeyDown

			k[event.Key] = True
		Else
			k[event.Key] = False
		Endif
	End

	Method SetColor:Color(c:Int)
		Return New Color(((c Shr 16) & $ff)/255.0,((c Shr 8) & $ff)/255.0,(c & $ff)/255.0)
	End Method
	
End Class

Function DrawArc(canvas:Canvas,x:Float, y:Float, startAngle:Float, endAngle:Float, radius:Float,closed:Int = False,pie:Int = False)
	Local fx:Float,fy:Float 'first x,y
	Local lx:Float,ly:Float 'last x,y
	Const RATE:Float = Pi/180.0
	If startAngle = endAngle Then Return
	If startAngle > endAngle
		Local ta:Float = endAngle
		endAngle = startAngle
		startAngle = ta
	EndIf
	Local angle:Float = endAngle - startAngle
	If angle > 360.0 angle = 360.0
	
	Local stp:Float = 1/(RATE * radius)
	Local accumAngle:Float = startAngle
	If closed = True
		fx = Cos(accumAngle*RATE) * radius
		fy = Sin(accumAngle*RATE) * radius
	EndIf
	While accumAngle < (startAngle+angle)
					
			lx = Cos(accumAngle*RATE) * radius
			ly = Sin(accumAngle*RATE) * radius
			canvas.DrawPoint( x + lx, y + ly)
			accumAngle += stp
	Wend

	If closed = True
		If pie = True
			canvas.DrawLine(x, y, x + fx, y + fy)
			canvas.DrawLine(x, y, x + lx, y + ly)
		Else
			canvas.DrawLine(x+fx,y+fy,x+lx,y+ly)
		EndIf
	EndIf
End Function 



Function Main()

	New AppInstance
	
	New Pinball
	
	App.Run()
End
