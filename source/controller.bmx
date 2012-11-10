Type TController
	
	Field W:Int, S:Int, A:Int, D:Int
	Field PLUS:Int, MINUS:Int
	
	Method IsDown:Int( id:Int )
		Select id
			Case KEY_W; Return W
			Case KEY_S; Return S
			Case KEY_A; Return A
			Case KEY_D; Return D
			Case KEY_PLUS; Return PLUS
			Case KEY_MINUS; Return MINUS
			Default; Return False
		End Select
	End Method
	
	Method SetPressed( id:Int )
		Select id
			Case KEY_W; W = True
			Case KEY_S; S = True
			Case KEY_A; A = True
			Case KEY_D; D = True
			Case KEY_PLUS; PLUS = True
			Case KEY_MINUS; MINUS = True
			Default; Return
		End Select
	End Method
	
	Method SetReleased( id:Int )
		Select id
			Case KEY_W; W = False
			Case KEY_S; S = False
			Case KEY_A; A = False
			Case KEY_D; D = False
			Case KEY_PLUS; PLUS = False
			Case KEY_MINUS; MINUS = False
			Default; Return
		End Select
	End Method
	
	Method Reset()
		W = False
		S = False
	    A = False
		D = False
		PLUS = False
		MINUS = False
	EndMethod
	
End Type


Private

Global MOVE_SPEED:Float = 10
Const ACCELERATION:Float = 0.9
Global direction:Int

Function ProcessKeyInput( editor:TEditor )
	If editor.pad.IsDown( KEY_W )
		direction = KEY_W
		MOVE_SPEED = 12.0
		editor.world.cam.position.y :- MOVE_SPEED/editor.world.cam.position.z
		Return
	ElseIf editor.pad.IsDown( KEY_S )
		direction = KEY_S
		MOVE_SPEED = 12.0
		editor.world.cam.position.y :+ MOVE_SPEED/editor.world.cam.position.z
		Return
	ElseIf editor.pad.IsDown( KEY_A )
		direction = KEY_A
		MOVE_SPEED = 12.0
		editor.world.cam.position.x :- MOVE_SPEED/editor.world.cam.position.z
		Return
	ElseIf editor.pad.IsDown( KEY_D )
		direction = KEY_D
		MOVE_SPEED = 12.0
		editor.world.cam.position.x :+ MOVE_SPEED/editor.world.cam.position.z
		Return
	EndIf
	MOVE_SPEED:- ACCELERATION
	If MOVE_SPEED < 0.2 Then
		MOVE_SPEED = 0.0
		Return
	EndIf
	If direction = KEY_W
		editor.world.cam.position.y :- MOVE_SPEED/editor.world.cam.position.z
	ElseIf direction = KEY_S
		editor.world.cam.position.y :+ MOVE_SPEED/editor.world.cam.position.z
	ElseIf direction = KEY_A
		editor.world.cam.position.x :- MOVE_SPEED/editor.world.cam.position.z
	ElseIf direction = KEY_D
		editor.world.cam.position.x :+ MOVE_SPEED/editor.world.cam.position.z
	EndIf
End Function