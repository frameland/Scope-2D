'--------------------------------------------------------------------------
' ** Reperesents a Selection around an Entity
'--------------------------------------------------------------------------
Type TSelection
	
	Global currentlySelected:Int
	
	Field isOverlapping:Int = False
	Field isSelected:Int = False
	Field entity:TEntity
	Field radius:Int
	Field cam:TCamera
	
'--------------------------------------------------------------------------
' * Init
'--------------------------------------------------------------------------
	Method Init( ent:TEntity )
		entity = ent
		radius = (Max( entity.size.width, entity.size.height ) * 0.5)
		cam = TEditor.GetInstance().world.cam
	End Method
	
	Method UpdateRadius()
		radius = Max(entity.size.width, entity.size.height)* 0.5
	End Method

'--------------------------------------------------------------------------
' * Check for overlap
'--------------------------------------------------------------------------
	Method OverlapCheck:Int( x:Float, y:Float )
		If entity.collision.CollidesWithPoint( x, y ) Then
			isOverlapping = True
			Return True
		EndIf
		isOverlapping = False
		Return False
	End Method

'--------------------------------------------------------------------------
' * Render
'--------------------------------------------------------------------------	
	Method Render( cam:TCamera )
		If isSelected And isOverlapping
			SetColor( 255, 200, 200 )
		ElseIf isSelected
			SetColor( 255, 0, 0 )
		ElseIf isOverlapping
			SetColor( 0, 255, 0 )
		EndIf
		SetAlpha( 1 )
		SetBlend( ALPHABLEND )
		SetHandle( entity.image.width/2, entity.image.height/2 )
		
			glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
			glEnable( GL_LINE_SMOOTH )
		
		Local x:Float = (entity.position.x - cam.position.x) * cam.position.z + cam.screen_center_x
		Local y:Float = (entity.position.y - cam.position.y) * cam.position.z + cam.screen_center_y
		
		DrawRect(x, y, entity.image.width, entity.image.height)

			glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
			glDisable (GL_LINE_SMOOTH)

		SetHandle 4, 4
		Local scale:Float = Max(cam.position.z, 0.6)
		SetScale(scale, scale)
		DrawRect(x, y, 5, 5)
		SetHandle 0,0
	End Method
	
	
'--------------------------------------------------------------------------
' * Set selected State
'--------------------------------------------------------------------------
	Method SetSelected()
		isSelected = True
		isOverlapping = False
	End Method
	
	Method SetHighlighted()
		isSelected = False
		isOverlapping = True
	End Method
	
'--------------------------------------------------------------------------
' * Clear
'--------------------------------------------------------------------------
	Function ClearSelected( List:TList )
		currentlySelected = 0
		TEditor.GetInstance().world.SaveState()
		Local entity:TEntity
		For entity = EachIn List
			entity.selection.isSelected = False		
		Next
	End Function
	
	Function ClearHighlighted( List:TList )
		Local entity:TEntity
		For entity = EachIn List
			entity.selection.isOverlapping = False		
		Next
	End Function
	
	Function SelectAll( List:TList )
		TEditor.GetInstance().world.SaveState()
		Local entity:TEntity
		For entity = EachIn List
			entity.selection.isOverlapping = False
			entity.selection.isSelected = True
		Next
	End Function
	
End Type


'--------------------------------------------------------------------------
' ** Used for MultiSelection
'--------------------------------------------------------------------------
Type RectSelection
	
	Field startX:Int, endX:Int
	Field startY:Int, endY:Int
	Field started:Byte = False
	
	Method StartSelection( sx:Int, sy:Int )
		startX = sx
		startY = sy
		started = True
	End Method
	
	Method EndSelection()
		started = False
	End Method
	
	Method Update( mouseX:Int, mouseY:Int )
		endX = mouseX
		endY = mouseY
	End Method
	
	Method IsInSelection:Byte( entity:TEntity )
		Local realStartX:Float
		Local realStartY:Float
		Local width:Float
		Local height:Float
		If startX < endX
			realStartX = startX
			width = endX - startX
		Else
			realStartX = endX
			width = startX - endX
		EndIf
		If startY < endY
			realStartY = startY
			height = endY - startY
		Else
			realStartY = endY
			height = startY -endY
		EndIf
		If PointInRect( entity.position.x, entity.position.y, realStartX, realStartY, width, height  ) 'startX, startY, endX-startX, endY-startY
			Return True
		EndIf
		Return False
	End Method
	
	Method Render( cam:TCamera )
		ResetDrawing()
		SetColor 0, 255, 0
		glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
		DrawRect( (startX * cam.position.z) - (cam.position.x * cam.position.z) + cam.screen_center_x,..
		(startY * cam.position.z) - (cam.position.y * cam.position.z) + cam.screen_center_y,..
        -(startX-endX)* cam.position.z, -(startY-endY)* cam.position.z )
		glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
	End Method
	
End Type




