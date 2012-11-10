Type TGuiMouse
	
	Field x:Float
	Field y:Float
	Field beginX:Float
	Field beginY:Float
	Field down:Int
	Field up:Int
	Field Dragging:Int = False
	Field MultiSelect:Int = False
	Field cam:TCamera
	Field lastDown:Int = MOUSE_LEFT
	
	Field removeSelectionOnUp:Int = False
	
'--------------------------------------------------------------------------
' * Init
'--------------------------------------------------------------------------
	Method New()
		
cam = TEditor.GetInstance().world.cam
	End Method
	
'--------------------------------------------------------------------------
' * Update Coordinates
'--------------------------------------------------------------------------
	Method UpdateCoords( mx:Int, my:Int )
		x = mx
		y = my
		If x >= CANVAS_WIDTH Then
			x = CANVAS_WIDTH-1
		ElseIf x < 0
			x = 0
		EndIf
		If y >= CANVAS_HEIGHT Then
			y = CANVAS_HEIGHT-1
		ElseIf y < 0
			y = 0
		EndIf
	End Method

'--------------------------------------------------------------------------
' * Get World Coordinates
'--------------------------------------------------------------------------
	Method WorldCoordX:Float()
		Return (x - cam.screen_center_x) / cam.position.z + cam.position.x
	End Method
	
	Method WorldCoordY:Float()
		Return (y - cam.screen_center_y) / cam.position.z + cam.position.y
	End Method
	
'--------------------------------------------------------------------------
' * Set Mouse Status
'--------------------------------------------------------------------------	
	Method SetDown()
		up = False
		down = True
	End Method
	
	Method SetUp()
		up = True
		down = False
		Dragging = False
	End Method

'--------------------------------------------------------------------------
' * Get Mouse Status
'--------------------------------------------------------------------------
	Method IsDown:Int()
		Return down
	End Method
	
	Method IsUp:Int()
		Return up
	End Method

'--------------------------------------------------------------------------
' * Dragging
'--------------------------------------------------------------------------
	Method StartDrag()
		beginX = WorldCoordX()
		beginY = WorldCoordY()
		Dragging = True
	End Method
	
	Method XDisplacement:Float()
		Return WorldCoordX() - beginX
	End Method
	
	Method YDisplacement:Float()
		Return WorldCoordY() - beginY
	End Method
	
	
End Type