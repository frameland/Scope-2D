'------------------------------------------------------------------------------
' Use this if you want to treat an Integer as Object
' Useful to add Integers to a TList or TMap
'------------------------------------------------------------------------------
Type TInt
	Field value:Int
	
'------------------------------------------------------------------------------
' Get a TInt instance with the specified value
'------------------------------------------------------------------------------
	Function Create:TInt( value:Int )
		Local i:TInt = New TInt
		i.value = value
		Return i
	EndFunction
	
EndType



'------------------------------------------------------------------------------
' Ensures the value to stay inside the specified Range
' If smooth is set to true the value will 'glide' which looks
' better for movement (also the upperLimit, lowerLimit and change
' arguments have to be set to a much smaller value in this case)
'------------------------------------------------------------------------------
Type TRangeValue
	
	Field current_value:Float
	Field upper_limit:Float
	Field lower_limit:Float
	Field change:Float
	Field smooth:Int
	
	Function Create:TRangeValue( upperLimit:Float, lowerLimit:Float, change:Float, smooth:Int = False, startValue:Float = 0)
		Local v:TRangeValue = New TRangeValue
		v.current_value = startValue
		v.upper_limit = upperLimit
		v.lower_limit = lowerLimit
		v.change = change
		v.smooth = smooth
		Return v
	EndFunction
	
	Method Value:Float()
		current_value:+ change
		If (current_value > upper_limit)
			current_value = upper_limit
			change = -change
		ElseIf (current_value < lower_limit)
			current_value = lower_limit
			change = -change
		EndIf
		If (smooth) Then Return current_value
		Return change
	EndMethod
	
	Method Reset()
		current_value = 0
		lower_limit = 0
		upper_limit = 0
		change = 0
		smooth = 0
	EndMethod
	
EndType



'------------------------------------------------------------------------------
' A typical counter which will count from startValue to untilValue
'------------------------------------------------------------------------------
Type TCounter
	
	Field value:Int
	Field step_value:Int
	Field until_value:Int
	Field start_value:Int

'------------------------------------------------------------------------------
' Create a new counter object
' ex: Local my_counter:TCounter = TCounter.Create( 0, 20, 1 )
'------------------------------------------------------------------------------
	Function Create:TCounter( startValue:Int, untilValue:Int, stepValue:Int )
		?debug
		If (startValue = untilValue)
			DebugLog( "Your counter has the same starting and ending value!" )
		ElseIf (startValue < untilValue)
			If (stepValue < 0)
				DebugLog( "Your counter is counting in the wrong direction?~n" +..
				"(Your counter will step in steps of " + stepValue + " so it can't reach " + untilValue+ ")" )
			EndIf
		ElseIf (startValue > untilValue)
			If (stepValue > 0)
				DebugLog( "Your counter is counting in the wrong direction?~n" +..
				"(Your counter will step in steps of +" + stepValue + " so it can't reach " + untilValue+ ")" )
			EndIf
		EndIf
		?
		Local c:TCounter = New TCounter
		c.value = startValue
		c.step_value = stepValue
		c.until_value = untilValue
		c.start_value = startValue
		Return c
	EndFunction

'------------------------------------------------------------------------------
' Returns True if counter is at specified untilValue, else False
'------------------------------------------------------------------------------	
	Method IsThere:Int()
		value:+ step_value
		If (step_value > 0)
			If (value + 1 > until_value)
				value = start_value
				Return True
			EndIf
			Return False
		EndIf
		If (value - 1 < until_value)
			value = start_value
			Return True
		EndIf
		Return False
	EndMethod
	
EndType


'------------------------------------------------------------------------------
' Replaces the default DebugLog Function
'------------------------------------------------------------------------------
Function DebugLog( text:String )
	?debug
		Print( text )
	?
EndFunction



Function AddListToList( destList:TList, addedList:TList, addlast:Int = True )
	Local obj:Object
	If (addlast)
		For obj = EachIn addedList
			destList.AddLast( obj )
		Next
		Return
	EndIf
	For obj = EachIn addedList
		destList.AddFirst( obj )
	Next
EndFunction


Global _start_messure_time:Int
Function StartMessuring()
	_start_messure_time = Millisecs()
End Function
Function EndMessuring( msg:String = "" )
	Print msg + " :: " + (Millisecs() - _start_messure_time)
End Function



'--------------------------------------------------------------------------
' * Set via GadgetSensitivity: Only allow Numbers as Input
'--------------------------------------------------------------------------
Function NumberFilter:Int(event:TEvent,context:Object)
	If (event.data >= 48) And (event.data <= 57)
		Return 1
	ElseIf (event.data = KEY_BACKSPACE) Or (event.data = KEY_DELETE) Or (event.data = KEY_LEFT) Or (event.data = KEY_RIGHT) Or (event.data = KEY_ENTER)
		Return 1
	EndIf
	Return 0
End Function

Function FloatNumberFilter:Int(event:TEvent,context:Object)
	If (event.data >= 48) And (event.data <= 57)
		Return 1
	ElseIf (event.data = KEY_BACKSPACE) Or (event.data = KEY_DELETE) Or (event.data = KEY_PERIOD) Or (event.data = KEY_LEFT) Or (event.data = KEY_RIGHT) Or (event.data = KEY_ENTER) Or (event.data = KEY_TAB)
		Return 1
	EndIf
	Return 0
End Function

Function WordFilter:Int(event:TEvent,context:Object)
	If (event.data >= 48) And (event.data <= 57)
		Return 1
	ElseIf (event.data >= 65 And event.data <= 90) Or (event.data >= 97 And event.data <= 122)
		Return 1
	ElseIf (event.data = KEY_BACKSPACE) Or (event.data = KEY_DELETE) Or (event.data = KEY_PERIOD) Or (event.data = KEY_LEFT) Or (event.data = KEY_RIGHT) Or (event.data = KEY_TAB)
		Return 1
	EndIf
	Return 0
End Function

Function FormatedFloat:String (number:Float)
	Local t:String = String (number)
	Local i:Int = t.Find (t)
	If i = -1 Return t
	Return t[0..i+4]
End Function

