
Type Grafx2
	
	Global width:Int
	Global height:Int
	Global fullscreen:Int
	Global origin_x:Int
	Global origin_y:Int
	
	Function Setup(  w:Int, h:Int, fscreen:Int = False  )
		width = w
		height = h
		fullscreen = fscreen
		If (Not fullscreen)
			Graphics( width, height )
			Return
		EndIf
		Local desk_width:Int = DesktopWidth()
		Local desk_height:Int = DesktopHeight()
		Local desk_aspect:Float = Float(desk_width)/desk_height
		Local game_aspect:Float = Float(width)/height
		Local virtual_width:Float
		Local virtual_height:Float
		Local scale:Float
		
		Select True
'------------------------------------------------------------------------------
' Widescreen : Left + Right Borders
'------------------------------------------------------------------------------
			Case desk_aspect > game_aspect
				scale = Float(desk_height)/height
				virtual_width = Float(desk_width) / scale
				virtual_height = height
				origin_x = (virtual_width - width) / 2.0
				origin_y = 0
'------------------------------------------------------------------------------
' Tall Screen
'------------------------------------------------------------------------------
			Case game_aspect > desk_aspect
				

'------------------------------------------------------------------------------
' Same : No Borders
'------------------------------------------------------------------------------				
			Default
				
		EndSelect
		Graphics( DesktopWidth(), DesktopHeight(), DesktopDepth(), DesktopHertz() )
		'MasterScale.Set( scale )
		'SetVirtualResolution( virtual_width, virtual_height )
		SetOrigin( 0,0 )
	EndFunction
	
	Function Flip( sync:Int = -1 )
		SetColor( 0, 0, 0 )
		Flip sync
	EndFunction
	
EndType

















Private

Global _width:Int,_height:Int
Global _fullscreen:Int
Global _originX#,_originY#
Global _box1:TBox
Global _box2:TBox


Type Grafx

	Function SetRes(width:Int,height:Int,fullscreen:Int)
	
		_width      = width
		_height     = height
		_fullscreen = fullscreen

		Select _fullscreen
			Case 0		'Windowed Mode
				Graphics _width,_height
				
			Case 1		'Widescreen Mode
				
				Local physWidth:Int  = DesktopWidth()
				Local physHeight:Int = DesktopHeight()
				Local physRatio# = Float physWidth / physHeight
				Local gameRatio# = Float _width / _height
				Local scale#
				Local virtWidth#,virtHeight#
				
				Select True
				
					Case physRatio > gameRatio		'Wide Screen
						scale 		= Float physHeight / _height
						virtWidth 	= Float physWidth / scale
						virtHeight 	= _height
						_originX 	= (virtWidth - _width) / 2.0
						_originY 	= 0
						_box1 		= TBox.Create(-_originX,0,_originX,_height)
						_box2 		= TBox.Create(_width,0,_originX,_height)
						print "Wide"
					Case physRatio < gameRatio		'Tall Screen
						scale 		= Float physWidth / _width
						virtWidth 	= _width
						virtHeight 	= Float physHeight / scale
						_originX 	= 0
						_originY 	= (virtHeight - _height) / 2.0
						_box1 		= TBox.Create(0,-_originY,_width,_originY)
						_box2 		= TBox.Create(0,_height,_width,_originY)
						print "Tall"
					Default					'Same Ratio
						virtWidth  	= _width
						virtHeight 	= _height
						_originX 	= 0
						_originY 	= 0
						print "Same"
				End Select
				
				Graphics physWidth,physHeight,DesktopDepth(),DesktopHertz()
				SetVirtualResolution virtWidth,virtHeight
				SetOrigin _originX,_originY

			Default		'Invalid Mode
				RuntimeError("Error: Invalid Fullscreen Mode.")
		End Select
	
	End Function

	Function SetFullscreen:Int( fullscreen:Int )	'Switch between windowed and fullscreen on-the-fly
		If fullscreen < 0 Or fullscreen > 1 Return False
		_fullscreen = fullscreen
		SetRes(_width,_height,_fullscreen)
		Return True
	End Function

	Function GFlip( sync:Int = -1 )
		SetColor 0,0,0
		If _box1 Then DrawRect(_box1.x,_box1.y,_box1.w,_box1.h)
		If _box2 Then DrawRect(_box2.x,_box2.y,_box2.w,_box2.h)
		SetColor( 255, 255, 255 )
		Flip sync
	End Function

	Function Width:Int()
		Return _width
	End Function

	Function Height:Int()
		Return _height
	End Function

	Function Fullscreen:Int()
		Return _fullscreen
	End Function

End Type

Function GMouseX:Int()
	Return VirtualMouseX() - _originX
End Function

Function GMouseY:Int()
	Return VirtualMouseY() - _originY
End Function

Type TBox
	Field x#,y#,w#,h#
	Function Create:TBox(x#,y#,w#,h#)
		Local box:TBox = New TBox
		box.x = x
		box.y = y
		box.w = w
		box.h = h
		Return box
	End Function
End Type



Public
'------------------------------------------------------------------------------
' Init the Graphics Mode
'------------------------------------------------------------------------------
Function SetupGraphics( width:Int, height:Int, fullscreen:Int = False )
	Grafx.SetRes( width, height, fullscreen )
EndFunction


'------------------------------------------------------------------------------
' Toggle between Fullscreen and Windowed Mode
'------------------------------------------------------------------------------
Function ToggleFullscreen()
	Grafx.SetFullscreen( Not Grafx.Fullscreen() )
EndFunction


'------------------------------------------------------------------------------
' Use this instead of Flip
'------------------------------------------------------------------------------
Function GFlip( sync:Int = -1 )
	ResetDrawing()
	Grafx.GFlip( sync )
EndFunction
