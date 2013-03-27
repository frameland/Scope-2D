
'------------------------------------------------------------------------------
' The Camera is used for showing a part of the World to the Player
'------------------------------------------------------------------------------
Type TCamera

'------------------------------------------------------------------------------
' Components
'------------------------------------------------------------------------------
	Field position:TPosition
	Field dist_x:Int, dist_y:Int
	Field view:TSize
	
'------------------------------------------------------------------------------
' Properties
'------------------------------------------------------------------------------
	Field focus:TEntity
	Field screen_center_x:Float
	Field screen_center_y:Float
	
	Field memory_z:Float = 1.0
	Field zoomLerping:Byte = False
	
'------------------------------------------------------------------------------
' Create a new Camera
'------------------------------------------------------------------------------
	Method New()
		position = New TPosition
		view = New TSize
		screen_center_x = CANVAS_WIDTH/2
		screen_center_y = CANVAS_HEIGHT/2
		view.Set( CANVAS_WIDTH, CANVAS_HEIGHT )
	EndMethod
	
'--------------------------------------------------------------------------
' * Update on window resize
'--------------------------------------------------------------------------
	Method OnWindowResize()
		screen_center_x = CANVAS_WIDTH/2
		screen_center_y = CANVAS_HEIGHT/2
		view.Set( CANVAS_WIDTH, CANVAS_HEIGHT )
	End Method
	

'------------------------------------------------------------------------------
' Update the cameras position
'------------------------------------------------------------------------------	
	Method Update()
		Local worldSize:TPosition = TEditor.GetInstance().world.size
		If (position.z < 0.01) Then position.z = 0.01
		If (position.z > 5) Then position.z = 5
		If focus
			Local lerp:Float = 0.15
			position.x:+ (focus.position.x - position.x) * lerp
			position.y:+ (focus.position.y - position.y) * lerp
			If zoomLerping
				Local canvas:Float = Max(CANVAS_WIDTH, CANVAS_HEIGHT) / 1.2
				Local world:Float = Max(worldSize.x, worldSize.y)
				position.z:+ (canvas/world - position.z) * lerp
			EndIf
		EndIf
	EndMethod
	

'------------------------------------------------------------------------------
' Set the Focus-Object of the Camera
'------------------------------------------------------------------------------	
	Method SetFocus( entity:TEntity )
		focus = entity
	EndMethod

	
'------------------------------------------------------------------------------
' Get the Focus-Object of the Camera
'------------------------------------------------------------------------------
	Method GetFocus:TEntity()
		Return focus
	EndMethod
	

'--------------------------------------------------------------------------
' * Resets the view to normal
'--------------------------------------------------------------------------
	Method ResetView()
		position.x = 0
		position.y = 0
		position.z = 1
	End Method
		
EndType
