'------------------------------------------------------------------------------
' With this Interface you can control how many logic-updates( Ups ) your
' program executes per second.
' Also you can specify how many frames per second( Fps ) are rendered.
'------------------------------------------------------------------------------
' How to use:
'------------------------------------------------------------------------------
'Graphics 640,480
'Local interface:TFixedTiming = New TFixedTiming
'While Not KeyDown(KEY_ESCAPE)
'	If interface.TimeToUpdate() 
'		interface.StartUpdate()
'		Update() '-------> Here goes your Update() Function
'		interface.FinishUpdate()
'	EndIf
'	If interface.TimeToRender()
'		interface.StartRendering()
'		Render() '-------> Here goes your Render() Function
'		interface.FinishRendering()
'	EndIf
'Wend
'------------------------------------------------------------------------------


Type TFixedTiming


'------------------------------------------------------------------------------
' Standard Ups and Fps
'------------------------------------------------------------------------------	
	Const STANDARD_UPS:Int = 125
	Const STANDARD_FPS:Int = 30


'------------------------------------------------------------------------------
' Needed for calculating
'------------------------------------------------------------------------------
	Field ups:Int
	Field fps:Int
	Field setted_ups:Int
	Field setted_fps:Int
	Field current_ups:Int
	

'------------------------------------------------------------------------------
' Contains the time in MilliSecs() when the next update should occur
'------------------------------------------------------------------------------
	Field next_ups: Int
	Field next_fps: Int
	

'------------------------------------------------------------------------------
' Contains the time how long an Update() or Render() process took
'------------------------------------------------------------------------------
	Field update_time:Int
	Field render_time:Int
	

'------------------------------------------------------------------------------
' Needed for calculating the current_ups and for updating purposes
'------------------------------------------------------------------------------
	Field ups_counter:Int
	Field ups_tolerance:Int
	


'------------------------------------------------------------------------------
' Initialize to standard values
'------------------------------------------------------------------------------
	Method New()
		SetUps( STANDARD_UPS )
		SetFps( STANDARD_FPS )
		SetTolerance( 5 )
	EndMethod
	

'------------------------------------------------------------------------------
' Set the fixed Fps value
'------------------------------------------------------------------------------
	Method SetFps( value:Int )
		setted_fps = value
		fps = 1000/value
	EndMethod


'------------------------------------------------------------------------------
' Set the fixed Ups value
'------------------------------------------------------------------------------
	Method SetUps( value:Int )
		setted_ups = value
		ups = 1000/value
	EndMethod


'------------------------------------------------------------------------------
' Set the tolerance value for the ups to be behind (in MilliSecs)
'------------------------------------------------------------------------------
	Method SetTolerance( value:Int )
		ups_tolerance = value
	EndMethod
	


'------------------------------------------------------------------------------
' Check if the logic/rendering has to be updated
' Returns True if update is needed, else False
'------------------------------------------------------------------------------
	Method TimeToUpdate:Int()
		If MilliSecs() > next_ups
			Return True
		EndIf
		Return False
	EndMethod
	
	Method TimeToRender:Int()
		If MilliSecs() > next_fps
			Return True
		EndIf
		Return False
	EndMethod


'------------------------------------------------------------------------------
' Use this before updating/rendering
'------------------------------------------------------------------------------
	Method StartUpdate()
		update_time = MilliSecs()
	EndMethod

	Method StartRendering()
		render_time = MilliSecs()
	EndMethod
	
	
'------------------------------------------------------------------------------
' Use this after updating/rendering
' FinishUpdate() Returns the number of MilliSecs left for the the next Update
'------------------------------------------------------------------------------
	Method FinishUpdate:Int()
		update_time = MilliSecs() - update_time
		next_ups = MilliSecs() + ups - 1 - update_time
		If _NewSecond()
			current_ups = ups_counter
			ups_counter = 0
		EndIf
		ups_counter:+1
		Return ups - update_time - render_time
	EndMethod	
	
	Method FinishRendering()
		render_time = MilliSecs() - render_time
		next_fps = MilliSecs() + fps - 1 - render_time
	EndMethod
	
	
'------------------------------------------------------------------------------
' Returns True if the Ups is not running at the set value, else False
'------------------------------------------------------------------------------
	Method UpsLagging:Int()
		If current_ups < (setted_ups - ups_tolerance) Return True
		Return False
	EndMethod
	

	'Private: Returns True if a new second begun, else False
	Method _NewSecond:Int()
		Global ms:Int = MilliSecs()
		If ms + 999 < MilliSecs()
			ms = MilliSecs()
			Return True
		EndIf
		Return False
	EndMethod
		
EndType






Global instance_fixed_timing:TFixedTiming

'------------------------------------------------------------------------------
' Functional Wrappers for TFixedTiming
'------------------------------------------------------------------------------
Function InitFixedTiming()
	If instance_fixed_timing Then RuntimeError( "You have already called InitFixedTiming()" )
	instance_fixed_timing = New TFixedTiming
EndFunction


Function SetUpsRate( value:Int )
	?debug
	If Not instance_fixed_timing Then RuntimeError( "Call InitFixedTiming() before using any timing functions!" )
	?
	instance_fixed_timing.SetUps( value:Int )
EndFunction


Function GetUpsRate:Int()
	?debug
	If Not instance_fixed_timing Then RuntimeError( "Call InitFixedTiming() before using any timing functions!" )
	?
	Return instance_fixed_timing.current_ups
EndFunction


Function GetSettedUps:Int()
	?debug
	If Not instance_fixed_timing Then RuntimeError( "Call InitFixedTiming() before using any timing functions!" )
	?
	Return instance_fixed_timing.setted_ups
EndFunction


Function SetFpsRate( value:Int )
	?debug
	If Not instance_fixed_timing Then RuntimeError( "Call InitFixedTiming() before using any timing functions!" )
	?
	instance_fixed_timing.SetFps( value:Int )
EndFunction


Function SetUpsTolerance( value:Int )
	?debug
	If Not instance_fixed_timing Then RuntimeError( "Call InitFixedTiming() before using any timing functions!" )
	?
	instance_fixed_timing.SetTolerance( value:Int )
EndFunction


Function TimeToUpdate:Int()
	?debug
	If Not instance_fixed_timing Then RuntimeError( "Call InitFixedTiming() before using any timing functions!" )
	?
	Return instance_fixed_timing.TimeToUpdate()
EndFunction


Function TimeToRender:Int()
	?debug
	If Not instance_fixed_timing Then RuntimeError( "Call InitFixedTiming() before using any timing functions!" )
	?
	Return instance_fixed_timing.TimeToRender()
EndFunction


Function StartUpdate()
	?debug
	If Not instance_fixed_timing Then RuntimeError( "Call InitFixedTiming() before using any timing functions!" )
	?
	instance_fixed_timing.StartUpdate()
EndFunction


Function StartRendering()
	?debug
	If Not instance_fixed_timing Then RuntimeError( "Call InitFixedTiming() before using any timing functions!" )
	?
	instance_fixed_timing.StartRendering()
EndFunction


Function FinishUpdate:Int()
	?debug
	If Not instance_fixed_timing Then RuntimeError( "Call InitFixedTiming() before using any timing functions!" )
	?
	Return instance_fixed_timing.FinishUpdate()
EndFunction


Function FinishRendering()
	?debug
	If Not instance_fixed_timing Then RuntimeError( "Call InitFixedTiming() before using any timing functions!" )
	?
	instance_fixed_timing.FinishRendering()
EndFunction


Function UpsLagging:Int()
	?debug
	If Not instance_fixed_timing Then RuntimeError( "Call InitFixedTiming() before using any timing functions!" )
	?
	Return instance_fixed_timing.UpsLagging()
EndFunction


