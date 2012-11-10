'------------------------------------------------------------------------------
' A gamepad you can assign buttons to
' A TGamePad can either be a keyboard or a gamepad
'------------------------------------------------------------------------------
' How to use:
' pad:TGamePad = New TGamePad
' pad.AddButton( "Shoot", KEY_SPACE )
' pad.AddButton( "MoveLeft", KEY_LEFT )
'------------------------------------------------------------------------------
Type TGamePad

'------------------------------------------------------------------------------
' This Map holds all TGamePad's
'------------------------------------------------------------------------------
	Field ButtonMap:TMap = New TMap


'------------------------------------------------------------------------------
' Needed to know what kind of Gamepad it is
'------------------------------------------------------------------------------
	Const GAMEPAD:Int = 1
	Const KEYBOARD:Int = 2
	Field type_of_pad:Int = KEYBOARD
	

'------------------------------------------------------------------------------
' Add a button to the gamepad
' If the name of the button allready exists, the keycode will be added
' to the speciefied button (so you can use more than 1 key on a button)
'------------------------------------------------------------------------------
	Method AddButton( name:String, keycode:Int )
		Local button:TGamePadButton
		If ( ButtonMap.Contains( name ) )
			button = TGamePadButton( ButtonMap.ValueForKey( name ) )
		EndIf
		If (button = Null)
			button = New TGamePadButton
		EndIf
		button.AddKey( keycode )
		ButtonMap.Insert( name, button )
	EndMethod
	

'------------------------------------------------------------------------------
' Remove the button with the speciefied name
' If keycode is specified you can remove a keycode from a button
' instead of the whole button
'------------------------------------------------------------------------------
	Method RemoveButton( name:String, keycode:Int = -1 )
		Local button:TGamePadButton
		If ( ButtonMap.Contains( name ) )
			button = TGamePadButton( ButtonMap.ValueForKey( name ) )
		EndIf
		If (button = Null)
			DebugLog("There is no gamepad button with the name " + name + ".")
			Return
		EndIf
		If (keycode = -1)
			ButtonMap.Remove( name )
		Else
			_RemoveKeyFromButton( name, keycode )
		EndIf
	EndMethod
	
	
'------------------------------------------------------------------------------
' Update all Buttons
'------------------------------------------------------------------------------	
	Method Poll()
		Local button:TGamePadButton
		If ( PadType() = KEYBOARD )
			For button = EachIn ButtonMap.Values()
				button.UpdateKeys()
			Next
			Return
		ElseIf ( PadType() = GAMEPAD )
			'For button = EachIn ButtonMap.Values()
			'	button.UpdateJoys()
			'Next
			'TODO---------------------------------------<<<<
			Return
		EndIf
		Throw( "The type of this gamepad is unknown! Use SetPadType()!" )
	EndMethod
	
	
'------------------------------------------------------------------------------
' Check if a specific button is currently pressed down
' Return True if pressed down, else False
' (also returns False, when the specified button was not found)
'------------------------------------------------------------------------------
	Method IsDown:Int( name:String )
		If Not ButtonMap.Contains( name ) Then Return False
		Return TGamePadButton( ButtonMap.ValueForKey( name ) ).IsDown()		
	EndMethod
	
	
'------------------------------------------------------------------------------
' Check if a specific button has been hit
' Return True if hit, else False
' (also returns False, when the specified button was not found)
'------------------------------------------------------------------------------	
	Method IsHit:Int( name:String )
		If Not ButtonMap.Contains( name ) Then Return False
		Return TGamePadButton( ButtonMap.ValueForKey( name ) ).IsHit()
	EndMethod
	

'------------------------------------------------------------------------------
' Set the gamepad type
'------------------------------------------------------------------------------
	Method SetPadType( value:Int )
		If (PadType() <> value)
			DebugLog( "Creating new gamepad ...~nResetting all data ..." )
			Reset()
			type_of_pad = value
		EndIf
	EndMethod
	

'------------------------------------------------------------------------------
' Get the gamepad type
'------------------------------------------------------------------------------
	Method PadType:Int()
		Return type_of_pad
	EndMethod
	

'------------------------------------------------------------------------------
' Reset the gamepad to its initial state (clearing all keys)
'------------------------------------------------------------------------------
	Method Reset()
		ButtonMap.Clear()
	EndMethod
	
	
	'Private
	Method _RemoveKeyFromButton( name:String, keycode:Int )
		Local button:TGamePadButton
		If ( ButtonMap.Contains( name ) )
			button = TGamePadButton( ButtonMap.ValueForKey( name ) )
		Else
			DebugLog( "You want to remove a key from button " + name + ".~n"..
			+ "However, this button does not exist ..." )
			Return
		EndIf
		Local i:TInt
		For i = EachIn button.KeyList
			If (i.value = keycode)
				button.KeyList.Remove( i )
				Return
			EndIf
		Next
		DebugLog( "There was no keycode that could be removed from button " + name + "." )
	EndMethod
		
EndType





'------------------------------------------------------------------------------
' A button for TGamePad
'------------------------------------------------------------------------------
Type TGamePadButton

'------------------------------------------------------------------------------
' KeyList contains all keycodes as TInt that is associated with this button
'------------------------------------------------------------------------------
	Field KeyList:TList = New TList
	

'------------------------------------------------------------------------------
' Indicates if button has been pressed/hit; use IsDown()/IsHit() instead
'------------------------------------------------------------------------------
	Field is_down:Int = False
	Field is_hit:Int = False
	

'------------------------------------------------------------------------------
' Returns True if button is down, else False
'------------------------------------------------------------------------------
	Method IsDown:Int()
		Return is_down
	EndMethod
	
	
'------------------------------------------------------------------------------
' Returns KeyHits if button is down, else False
'------------------------------------------------------------------------------	
	Method IsHit:Int()
		Return is_hit
	EndMethod
	

'------------------------------------------------------------------------------
' Update the state of the button
'------------------------------------------------------------------------------	
	Method UpdateKeys()
		is_hit  = False
		is_down = False
		Local i:TInt
		Local hit:Int
		For i = EachIn KeyList
			hit = KeyHit( i.value )
			If hit
				is_hit = hit
			ElseIf KeyDown( i.value )
				is_down = True
			EndIf
		Next
	EndMethod
	
	
	'Method UpdateJoys()
	'	
	'EndMethod


'------------------------------------------------------------------------------
' Add a single key to the button
' Throws an Error in Debug-Mode if key has allready been assigned
'------------------------------------------------------------------------------	
	Method AddKey( keycode:Int )
		Local i:TInt = New TInt
		i.value = keycode
		?debug
		For Local k:TInt = EachIn KeyList
			If (i.value = k.value)
				Throw( "The speciefied keycode (" + i.value + ")"..
				+ " has allready been assigned to this Gamepad!~n"..
				+ "(You used AddKey twice with the same keycode)" )
			EndIf			
		Next
		?
		KeyList.AddLast( i )
	EndMethod
	
EndType

