
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
	
	Field border:Int
	Field memory_z:Float = 1.0
	
'------------------------------------------------------------------------------
' Create a new Camera
'------------------------------------------------------------------------------
	Method New()
		position = New TPosition
		view = New TSize
		screen_center_x = CANVAS_WIDTH/2
		screen_center_y = CANVAS_HEIGHT/2
		view.Set( CANVAS_WIDTH, CANVAS_HEIGHT )
		border = 5
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
		If (position.z < 0.1) Then position.z = 0.1
		If (position.z > 5) Then position.z = 5
		If focus
			position.x = focus.position.x
			position.y = focus.position.y
		EndIf

		'Camera will stop at outer borders of world
		If (position.x > worldSize.x)
			position.x = worldSize.x
		EndIf
		If (position.y > worldSize.y)
			position.y = worldSize.y
		EndIf
		
		'Camera stops before 0,0 border
		If (position.x < (CANVAS_WIDTH/2.0)/position.z-(border/position.z))
			position.x = (CANVAS_WIDTH/2.0)/position.z-(border/position.z)
		EndIf
		If (position.y < (CANVAS_HEIGHT/2.0)/position.z-(border/position.z))
			position.y = (CANVAS_HEIGHT/2.0)/position.z-(border/position.z)
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
