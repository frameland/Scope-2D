'------------------------------------------------------------------------------
' Update All Animations
'------------------------------------------------------------------------------
Function UpdateAnimations()
	Local anim:TAnimationStrip
	For anim = EachIn TAnimationStrip.AnimationList
		anim.Update()
	Next
EndFunction



'------------------------------------------------------------------------------
' TAnimationStrip
' Create an animation with a series of images 
'------------------------------------------------------------------------------
Type TAnimationStrip

'------------------------------------------------------------------------------
' Has all animations
'------------------------------------------------------------------------------
	Global AnimationList:TList = New TList
	

'------------------------------------------------------------------------------
' counter: is increasing the frame number when a speciefied time elapsed
' speed: how much time is between one animation frame and the next (in FPS)
' next_update: time in Millisecs when the counter should increase next time
' link: for faster removing of the animation
' is_playing: When False the animation will not play
' executed_loops: how many times the animation has been played completely
' max_loops: how many times is the animation allowed to play
'------------------------------------------------------------------------------	
	Field counter:TCounter
	Field speed:Int
	Field next_update:Int
	Field link:TLink
	Field is_playing:Int
	Field executed_loops:Int
	Field max_loops:Int
	

'------------------------------------------------------------------------------
' Create a new Animation
'------------------------------------------------------------------------------	
	Method Create:TAnimationStrip( frames:Int, speedFps:Int = 25, nrOfLoops:Int = -1  )
		counter = TCounter.Create( 0, frames, 1 )
		speed = 1000/speedFps
		next_update = Millisecs() + speed
		max_loops = nrOfLoops
		is_playing = True
		link = AnimationList.AddLast( Self )
		Return Self
	EndMethod


'------------------------------------------------------------------------------
' Updates the frame count (when enough time elapsed, dependent on speed)
' Automatically called from UpdateAnimations
'------------------------------------------------------------------------------
	Method Update()
		If Not is_playing Then Return
		If (Millisecs() > next_update)
			If counter.IsThere()
				executed_loops:+ 1
				If (executed_loops+1 > max_loops) And (max_loops <> -1)
					executed_loops = 0
					Stop()
				EndIf
			EndIf
			next_update = Millisecs() + speed
		EndIf
	EndMethod


'------------------------------------------------------------------------------
' Use this with DrawImage to get the frame to draw
'------------------------------------------------------------------------------	
	Method GetFrame:Int()
		Return counter.value
	EndMethod
	

'------------------------------------------------------------------------------
' Pauses the animation (update will be skipped)
'------------------------------------------------------------------------------
	Method Stop()
		is_playing = False
	EndMethod
	

'------------------------------------------------------------------------------
' Resumes Animation
'------------------------------------------------------------------------------
	Method Resume()
		is_playing = True
	EndMethod
	
	
'------------------------------------------------------------------------------
' Returns True when the animation is playing, else False
'------------------------------------------------------------------------------
	Method IsPlaying:Int()
		Return is_playing
	EndMethod
	
	
'------------------------------------------------------------------------------
' Set how fast the animation should play (in Fps)
'------------------------------------------------------------------------------
	Method SetSpeed( value:Int )
		speed = 1000/value
	EndMethod
	
	
EndType
