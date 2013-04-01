Global GfxWorkingDir:String
Global MapWorkingDir:String
Global IsDeveloper:Int

'------------------------------------------------------------------------------
' Editing Mode
'------------------------------------------------------------------------------
Type EditorWorld Extends TWorld

	Field editor:TEditor
	Field gfxChooseWorld:TGraphicChooseWorld
	Field rect_selection:RectSelection
	Field size:TPosition 'Size of the World in Pixels
	Field centerObject:TEntity 'always in the center
	Field Polys:TList = New TList
	Field Events:TList = New TList
	
	Field useParallaxKey:Byte = 0
	Field parallaxSpeed:Float
	Field pressingParallaxKey:Byte = False
	
	Field shouldOpenAutomatically:String
	
'------------------------------------------------------------------------------
' Initialize the World
'------------------------------------------------------------------------------	
	Method Init()
		LoadConfig()
		
		editor = TEditor.GetInstance()
		rect_selection = New RectSelection
		gfxChooseWorld = New TGraphicChooseWorld
		size = New TPosition
		size.Set (2000,1000)
		centerObject = New TEntity
		gfxChooseWorld.Init()
		SetMaxLayers( STANDARD_LAYERS )
		
		'Ensure there is no lag in the beginning
		Local canvas:TGadget = editor.exp_canvas.canvas
		Render()
		DrawRect( 0, 0, canvas.width, canvas.height )
		Delay 10
		
		ResetView()
	EndMethod
	
	Method LoadConfig()
		Local config:ConfigFile = New ConfigFile
		config.Load ("source/ressource/config.css")
		Local block:CssBlock = config.GetBlock("Config")
		GfxWorkingDir = block.Get("gfxdir")
		MapWorkingDir = block.Get("mapdir")
		IsDeveloper = block.GetInt("isDev", 0)
		If (GfxWorkingDir = "") Or (MapWorkingDir = "")
			AppTitle = "Configuration Error!"
			Notify ("You first have to set the gfx and map directory.")
			OpenUrl ("source/ressource/config.css")
			End
		EndIf
		If block.Contains("LastOpen")
			shouldOpenAutomatically = ""
			Local lastOpened:String = block.Get("LastOpen")
			If FileType(lastOpened) = 1
				shouldOpenAutomatically = lastOpened
			EndIf
		EndIf
	End Method
	
	
'------------------------------------------------------------------------------
' Update Different Modes
'------------------------------------------------------------------------------
	Method Update()
		If editor.state = 3
			gfxChooseWorld.Update()
			Return
		EndIf
		If editor.state <> 1 Then Return
		
		If editor.moveMode
			If editor.mouse.Dragging
				If editor.mouse.lastDown = MOUSE_LEFT
					cam.position.x = cam.position.x - editor.mouse.XDisplacement()
					cam.position.y = cam.position.y - editor.mouse.YDisplacement()
				'ElseIf RIGHT MOUSE? zooming like in maya / use right-click to place sprites
				EndIf
			EndIf
			Return
		EndIf
		
		Select editor.exp_toolbar.mode
			Case MODE_EDIT
				If Not editor.exp_menu.ParallaxingActive And editor.mouse.lastDown = MOUSE_LEFT
					UpdateEditMode()
				EndIf
			Case MODE_COLLISION
				If editor.mouse.lastDown = MOUSE_LEFT
					UpdateCollisionMode()
				EndIf
			Case MODE_EVENT
				If editor.mouse.lastDown = MOUSE_LEFT
					UpdateEventMode()
				Endif
			Default
				Throw ("EditorWorld.Update: Unknown Mode (should be 0,1,2)")
		End Select
	EndMethod

	Method UpdateEditMode()
		Select editor.exp_toolbar.selected
			Case 0
				UpdateSelection()
			Case 1
				If (NrOfSelectedEntities() = 0)
					UpdateSelection()
					If (NrOfSelectedEntities() = 1)
						editor.mouse.removeSelectionOnUp = True
					EndIf
				EndIf
				UpdateMove()
			Case 2
				If (NrOfSelectedEntities() = 0)
					UpdateSelection()
					If (NrOfSelectedEntities() = 1)
						editor.mouse.removeSelectionOnUp = True
					EndIf
				EndIf
				UpdateScaling()
			Case 3
				If (NrOfSelectedEntities() = 0)
					UpdateSelection()
					If (NrOfSelectedEntities() = 1)
						editor.mouse.removeSelectionOnUp = True
					EndIf
				EndIf
				UpdateRotating()
			Default
		EndSelect
	End Method
	
	Method UpdateCollisionMode()
		Select editor.exp_toolbar.selected
			Case 0
				UpdateSelection()
			Case 1
				If (NrOfSelectedEntities() = 0)
					UpdateSelection()
					If (NrOfSelectedEntities() = 1)
						editor.mouse.removeSelectionOnUp = True
					EndIf
				EndIf
				UpdateMove()
			Case 2
				If (NrOfSelectedEntities() = 0)
					UpdateSelection()
					If (NrOfSelectedEntities() = 1)
						editor.mouse.removeSelectionOnUp = True
					EndIf
				EndIf
				UpdateScaling()
			Case 3
				If (NrOfSelectedEntities() = 0)
					UpdateSelection()
					If (NrOfSelectedEntities() = 1)
						editor.mouse.removeSelectionOnUp = True
					EndIf
				EndIf
				UpdateRotating()
			Default
		EndSelect
	End Method
	
	Method UpdateEventMode()
		Select editor.exp_toolbar.selected
			Case 0
				UpdateSelection()
			Case 1
				If (NrOfSelectedEntities() = 0)
					UpdateSelection()
					If (NrOfSelectedEntities() = 1)
						editor.mouse.removeSelectionOnUp = True
					EndIf
				EndIf
				UpdateMove()
			Case 2
				If (NrOfSelectedEntities() = 0)
					UpdateSelection()
					If (NrOfSelectedEntities() = 1)
						editor.mouse.removeSelectionOnUp = True
					EndIf
				EndIf
				UpdateScaling()
			Default
		EndSelect
	End Method
	
	Method UpdateParallaxView()
		Select useParallaxKey
			Case KEY_LEFT
				cam.position.x:- parallaxSpeed
			Case KEY_RIGHT
				cam.position.x:+ parallaxSpeed
			Case KEY_UP
				cam.position.y:- parallaxSpeed
			Case KEY_DOWN
				cam.position.y:+ parallaxSpeed
			Default
		End Select
	End Method
	
	
'--------------------------------------------------------------------------
' * Update/Execute the different Tools/Actions
'--------------------------------------------------------------------------
	Method UpdateSelection()
		Local List:TList = GetRightEntityList()
		
		Local entity:TEntity
		Local mouseOverEntity:TEntity
		Local mouse:TGuiMouse = editor.mouse
		Local highlithed:Int = 0
		Local distance:Float = 1000000
		
		If mouse.Dragging
			If Not rect_selection.started Then
				rect_selection.StartSelection( mouse.WorldCoordX(), mouse.WorldCoordY() )
			EndIf
			If mouse.MultiSelect <> True
				TSelection.ClearSelected( List )
			EndIf
			rect_selection.Update(  mouse.WorldCoordX(), mouse.WorldCoordY() )
			For entity = EachIn List
				If IsInView(entity) And rect_selection.IsInSelection( entity )
					entity.selection.isSelected = True
				Else
					If Not mouse.MultiSelect
						entity.selection.isSelected = False
					EndIf
				EndIf
			Next
			Return
		EndIf
		
		For entity = EachIn List
			If Not IsInView( entity )
				Continue
			EndIf
			If entity.selection.OverlapCheck( mouse.WorldCoordX(), mouse.WorldCoordY() )
				If DistanceOfPoints( mouse.WorldCoordX(), mouse.WorldCoordY(), entity.position.x, entity.position.y ) < distance
					distance = DistanceOfPoints( mouse.WorldCoordX(), mouse.WorldCoordY(), entity.position.x, entity.position.y )
					mouseOverEntity = entity
				EndIf
			EndIf		
		Next
		If Not mouseOverEntity
			If mouse.IsDown() 'Empty area click to deselect
				TSelection.ClearSelected(List)
			EndIf
			editor.exp_options.UpdatePropsUI()
			Return
		EndIf
		If mouse.IsDown()
			Local alreadySelected:Byte = mouseOverEntity.selection.isSelected
			If mouse.MultiSelect <> True
				TSelection.ClearSelected( List )
			EndIf
			If alreadySelected
				mouseOverEntity.selection.isSelected = False
			Else
				mouseOverEntity.selection.isSelected = True
				editor.exp_options.ShowTransformAttributes (mouseOverEntity)
			EndIf
			TSelection.ClearHighlighted( List )
		Else 'just MouseOver
			TSelection.ClearHighlighted( List )
			mouseOverEntity.selection.isOverlapping = True
		EndIf
		editor.exp_options.UpdatePropsUI()
	End Method

	Method UpdateMove()
		If Not editor.mouse.Dragging Then Return
		
		Local List:TList = GetRightEntityList()
		
		Local entity:TEntity
		Local x:Int
		Local y:Int

		If ButtonState( editor.exp_options.move_MoveStraight )
			If Pos( editor.mouse.XDisplacement() ) > Pos( editor.mouse.YDisplacement() )
				'Move X
				For entity = EachIn List
					If entity.selection.isSelected
						x = Int( entity.memory_position.x + editor.mouse.XDisplacement() )
						y = Int( entity.memory_position.y )
						entity.position.Set(x, y)
					EndIf
				Next
				If editor.exp_toolbar.mode = MODE_COLLISION And entity.name <> ""
					Local entityCollision:TEntity = GetEntityById (entity.name)
					If entityCollision
						Local difX:Int = entity.memory_position.x - entity.position.x
						entityCollision.position.Set (entityCollision.memory_position.x - difX, entityCollision.memory_position.y)
					EndIf
				EndIf
			Else 'Move Y
				For entity = EachIn List
					If entity.selection.isSelected
						x = Int( entity.memory_position.x )
						y = Int( entity.memory_position.y + editor.mouse.YDisplacement() )
						entity.position.Set(x, y)
					EndIf
					If editor.exp_toolbar.mode = MODE_COLLISION And entity.name <> ""
						Local entityCollision:TEntity = GetEntityById (entity.name)
						If entityCollision
							Local difY:Int = entity.memory_position.y - entity.position.y
							entityCollision.position.Set (entityCollision.memory_position.x, entityCollision.memory_position.y - difY)
						EndIf
					EndIf
				Next
			EndIf
				
		Else 'Move in all Directions
			For entity = EachIn List
				If entity.selection.isSelected
					x = Int( entity.memory_position.x + editor.mouse.XDisplacement() )
					y = Int( entity.memory_position.y + editor.mouse.YDisplacement() )
					entity.position.Set(x, y)
					If editor.exp_toolbar.mode = MODE_COLLISION And entity.name <> ""
						Local entityCollision:TEntity = GetEntityById (entity.name)
						If entityCollision
							Local difX:Int = entity.memory_position.x - entity.position.x
							Local difY:Int = entity.memory_position.y - entity.position.y
							entityCollision.position.Set (entityCollision.memory_position.x - difX, entityCollision.memory_position.y - difY)
						EndIf
					EndIf
				EndIf
			Next
		EndIf
	End Method
	
	Method UpdateRotating()
		If Not editor.mouse.Dragging Then Return
		
		Local List:TList = GetRightEntityList()
		
		Local entity:TEntity
		Local angle:Float
		Local value:Float
		For entity = EachIn List
			If entity.selection.isSelected
				angle = entity.memory_rotation + editor.mouse.XDisplacement()
				
				'Clamp angle
				If (angle > 180)
					angle :- 360
				EndIf
				If (angle < -180)
		            angle :+ 360;
				EndIf
				
				If ButtonState(editor.exp_options.rotate_Snap)
					value = 22.5
					angle:- (angle Mod value)
				EndIf
				entity.SetRotation(angle)
			EndIf
		Next
	End Method
	
	Method UpdateScaling()
		If Not editor.mouse.Dragging Then Return
			
		Local List:TList = GetRightEntityList()
		
		Local entity:TEntity
		Local scaleFactorX:Float
		Local scaleFactorY:Float
		Local aspectRatio:Float
		Local keepAspect:Byte = ButtonState( editor.exp_options.scale_KeepAspect )
		For entity = EachIn List
			If entity.selection.isSelected
				If editor.exp_toolbar.mode = MODE_COLLISION 'Scaling x only
					scaleFactorX = entity.memory_scale.sx + editor.mouse.XDisplacement() / 50
					If scaleFactorX < 0.05 Then scaleFactorX = 0.05
					scaleFactorY = 1.0
				ElseIf keepAspect Or editor.exp_toolbar.mode = MODE_EVENT 'Scaling both, x + y axis
					aspectRatio = entity.memory_scale.sx / entity.memory_scale.sy
					scaleFactorX = entity.memory_scale.sx + editor.mouse.XDisplacement() / 50
					scaleFactorY = scaleFactorX / aspectRatio
					If scaleFactorX < 0.05 Then scaleFactorX = 0.05
					If scaleFactorY < 0.05 Then scaleFactorY = 0.05
				Else 'Scaling x and y individually
					scaleFactorX = entity.memory_scale.sx + editor.mouse.XDisplacement() / 50
					If scaleFactorX < 0.05 Then scaleFactorX = 0.05
					scaleFactorY = entity.memory_scale.sy - editor.mouse.YDisplacement() / 50
					If scaleFactorY < 0.05 Then scaleFactorY = 0.05
				EndIf
				entity.SetScale( TrimFloat(scaleFactorX), TrimFloat(scaleFactorY) )
			EndIf
		Next
	End Method
	
	Method ExecuteFlipping( horizontal:Int )
		If editor.state <> 1 Then Return
		If editor.mouse.Dragging Then Return
		
		Local List:TList = GetRightEntityList()
		
		SaveState()
		Local entity:TEntity
		For entity = EachIn List
			If entity.selection.isSelected
				If horizontal
					entity.flipH = Not entity.flipH
				Else 'vertical
					entity.flipV = Not entity.flipV
				EndIf
			EndIf
		Next
	End Method

	Method RemoveEntities()
		Local List:TList = GetRightEntityList()
		SaveState()
		Local entity:TEntity
		For entity = EachIn List
			If entity.selection.isSelected Then
				If editor.exp_toolbar.mode = MODE_EVENT
				        Local mapDir:String = ExtractDir(SceneFile.Instance().currentlyOpened)
				        DeleteFile(mapDir + "/on_action/" + entity.name + ".script")
				        DeleteFile(mapDir + "/on_enter/" + entity.name + ".script")
				EndIf
				entity.Remove()
			EndIf
		Next
		editor.exp_options.UpdatePropsUI()
	End Method
	
	Method CloneEntities()
		Local List:TList = GetRightEntityList()
		SaveState()
		Local entity:TEntity
		Local dummy:TEntity
		Local dx:Int = 10
		Local dy:Int = 10
		Local CloneList:TList = New TList
		For entity = EachIn List
			If entity.selection.isSelected Then
				dummy = New TEntity
				dummy.position.Set( entity.position.x + dx, entity.position.y + dy )
				dummy.scale.Set( entity.scale.sx, entity.scale.sy )
				dummy.flipH = entity.flipH
				dummy.flipV = entity.flipV
				dummy.image = entity.image
				dummy.texturePath = entity.texturePath
				dummy.rotation = entity.rotation
				dummy.color.SetRGB( entity.color.r, entity.color.g, entity.color.b )
				dummy.color.a = entity.color.a
				dummy.size.Set( entity.size.width, entity.size.height )
				dummy.collision = entity.collision.GetCopy( dummy )
				dummy.isParticle = entity.isParticle
				dummy.isBaseline = entity.isBaseline
				dummy.allowObjectTriggering = entity.allowObjectTriggering
				dummy.inFront = entity.inFront
				dummy.layer = entity.layer
				dummy.name = entity.name
				dummy.visible = entity.visible
				dummy.parallax = entity.parallax
				dummy.selection.Init( dummy )
				If editor.exp_toolbar.mode = MODE_EDIT
					AddEntity( dummy )
				ElseIf editor.exp_toolbar.mode = MODE_COLLISION
					AddPoly (dummy)
				ElseIf editor.exp_toolbar.mode = MODE_EVENT
					AddEvent (dummy)
				EndIf
				CloneList.AddLast( dummy )
			EndIf
		Next
		TSelection.ClearSelected( List )
		For entity = EachIn CloneList
			entity.selection.SetSelected()
		Next
		editor.exp_options.UpdatePropsUI()
	End Method
	
	Method ChangeEntityLayer (increment:Byte = False)
		If (editor.state <> 1) Or (editor.exp_toolbar.mode <> MODE_EDIT) Then Return
		SaveState()
		Local entity:TEntity
		If increment
			For entity = EachIn EntityList
				If entity.selection.isSelected
					entity.layer :+ 1
					entity.layer = Min (entity.layer, MAX_LAYERS)
				EndIf
			Next
		Else
			For entity = EachIn EntityList
				If entity.selection.isSelected
					entity.layer :- 1
					entity.layer = Max (entity.layer, 1)
				EndIf
			Next
		EndIf
		editor.exp_options.UpdatePropsUI()
	End Method
	
	
'--------------------------------------------------------------------------
' * Helper Function for Moving Entities 1 Pixel with ArrowKeys
'--------------------------------------------------------------------------
	Method ProcessPixelMoving (key:Int)
		If editor.state <> 1
			Return
		EndIf
		If (NrOfSelectedEntities() = 0)
			Return
		EndIf
		Local List:TList = GetRightEntityList()
		Local entity:TEntity
		For entity = EachIn List
			If (entity.selection.isSelected)
				Select (key)
					Case KEY_LEFT
						entity.position.x:-1
					Case KEY_RIGHT
						entity.position.x:+1
					Case KEY_UP
						entity.position.y:-1
					Case KEY_DOWN
						entity.position.y:+1
					Default
				End Select
			EndIf
		Next
	EndMethod
	
'--------------------------------------------------------------------------
' * Save properties before executing operations
'--------------------------------------------------------------------------
	Method InitOperation( id:Int)
		Local List:TList = GetRightEntityList()
		Local entity:TEntity
		Select id
			Case 1,2,3
				SaveState()
			Default
		End Select
		For entity = EachIn List
			Select id
				Case 1
					entity.SavePosition()
					If editor.exp_toolbar.mode = MODE_COLLISION And entity.name <> ""
						Local colEntity:TEntity = GetEntityById(entity.name)
						If colEntity
							colEntity.SavePosition()
						EndIf
					EndIf
				Case 2
					entity.SaveScale()
				Case 3
					entity.SaveRotation()
				Default
			End Select
		Next
	End Method
	
	
'------------------------------------------------------------------------------
' Render Entities + Selection in Viewfield
'------------------------------------------------------------------------------	
	Method Render()
		If editor.state = 3 Or gfxChooseWorld.outroActive
			gfxChooseWorld.Render()
			Return
		EndIf
		
		ResetDrawing()
		RenderGrid()
		
		Local renderedSprites:Int
		If editor.exp_menu.ParallaxingActive
			RenderParallaxView()
		Else
			Select editor.exp_toolbar.mode
				Case MODE_EDIT
					renderedSprites = RenderEditMode()
				Case MODE_COLLISION
					RenderCollisionMode()
				Case MODE_EVENT
					RenderEventMode()
				Default
			End Select
		EndIf
		
		RenderWorldBorder()
		DebugRender( renderedSprites )
	EndMethod
	
	Method RenderEditMode:Int()
		Local renderedSprites:Int
		Local highlighted:TEntity
		
		Local i:TEntity
		For Local layer:Int = 1 To MAX_LAYERS
			For i = EachIn EntityList
				If (i.layer = layer) And IsInView(i)
					i.Render( cam )
					renderedSprites:+ 1
					If i.selection.isSelected
						i.selection.Render( cam )
					ElseIf i.selection.isOverlapping
						highlighted = i
					EndIf
				EndIf
			Next
		Next
		
		If highlighted
			SetScale( highlighted.scale.sx * cam.position.z, highlighted.scale.sy * cam.position.z )
			SetRotation( highlighted.rotation )
			highlighted.selection.Render( cam )
		EndIf
		
		If editor.mouse.Dragging And editor.exp_toolbar.selected = 0
			rect_selection.Render( cam )
		EndIf
		
		Return renderedSprites
	End Method
	
	Method RenderCollisionMode()
		Local i:TEntity
		For Local layer:Int = 1 To MAX_LAYERS
			For i = EachIn EntityList
				If (i.layer = layer) And IsInView(i)
					i.Render( cam )
				EndIf
			Next
		Next
		
		Local highlighted:TEntity
		For i = EachIn Polys
			If IsInView (i)
				i.Render (cam)
				If i.selection.isSelected
					i.selection.Render( cam )
				ElseIf i.selection.isOverlapping
					highlighted = i
				EndIf
			EndIf
		Next
		
		If highlighted
			SetScale( highlighted.scale.sx * cam.position.z, highlighted.scale.sy * cam.position.z )
			SetRotation( highlighted.rotation )
			highlighted.selection.Render( cam )
		EndIf
		
		If editor.mouse.Dragging And editor.exp_toolbar.selected = 0
			rect_selection.Render( cam )
		EndIf
	End Method
	
	Method RenderEventMode()
		Local i:TEntity
		For Local layer:Int = 1 To MAX_LAYERS
			For i = EachIn EntityList
				If (i.layer = layer) And IsInView(i)
					i.Render( cam )
				EndIf
			Next
		Next
		
		Local highlighted:TEntity
		For i = EachIn Events
			If IsInView (i)
				i.Render (cam)
				If i.selection.isSelected
					i.selection.Render( cam )
				ElseIf i.selection.isOverlapping
					highlighted = i
				EndIf
			EndIf
		Next
		
		If highlighted
			SetScale( highlighted.scale.sx * cam.position.z, highlighted.scale.sy * cam.position.z )
			highlighted.selection.Render( cam )
		EndIf
		
		If editor.mouse.Dragging And editor.exp_toolbar.selected = 0
			rect_selection.Render( cam )
		EndIf
	End Method
	
	Method RenderParallaxView()
		Local i:TEntity
		For Local layer:Int = 1 To MAX_LAYERS
			For i = EachIn EntityList
				If (i.layer = layer) And (i.parallax = 0)
					If IsInView(i)
						i.Render(cam, False)
					EndIf
				ElseIf (i.layer = layer)
					i.Render(cam, True)
				EndIf
			Next
		Next
		
		'Parallax InfoButton
		ResetDrawing()
		SetColor(100, 100, 130)
		DrawRect(CANVAS_WIDTH-109, 7, 94, 22)
		SetColor(200, 200, 250)
		DrawRect(CANVAS_WIDTH-108, 8, 92, 20)
		SetColor(50,50,100)
		DrawText("Parallax", CANVAS_WIDTH-94, 11)
	End Method
	
	
	Method DebugRender( renderedSprites:Int )
		Local height:Int = 4
		ResetDrawing()
		SetHandle 0,0
		SetColor 120, 120, 120
		SetAlpha 1
		DrawText("CamX:" + Int(cam.position.x), 4, height)
		height:+ 16
		DrawText("CamY:" + Int(cam.position.y), 4, height)
		height:+ 16
		DrawText("CamZoom:" + FormatedFloat(cam.position.z), 4, height)
		height:+ 16
		DrawText ("Sprites: " + EntityList.Count(), 4, height)
	End Method
	
	Method RenderWorldBorder()
		If Not editor.exp_menu.xySwitch Then Return
		ResetDrawing()
		SetAlpha 1.0
		SetColor 120,120,120
		Local x:Int = cam.screen_center_x - (cam.position.x * cam.position.z)
		Local y:Int = cam.screen_center_y - (cam.position.y * cam.position.z)
		Local w:Int = size.x * cam.position.z
		Local h:Int = size.y * cam.position.z
		DrawRect2 (x+1, y+1, w, h)
	End Method
	
	Method RenderGrid()
		If Not editor.exp_menu.gridSwitch Then Return
		ResetDrawing()
		SetColor 180,180,180
		Local x:Int
		Local y:Int
		Local i:Int
		Local gridSize:Float = editor.exp_menu.gridSize
		Local width:Int = CANVAS_WIDTH / gridSize / cam.position.z
		Local height:Int = CANVAS_HEIGHT / cam.position.z / gridSize
		Local camx:Int = cam.position.x * cam.position.z
		Local camy:Int = cam.position.y * cam.position.z
		Local startPoint:Int = -width/2 + cam.position.x/gridSize - 1
		Local endPoint:Int = width/2 + cam.position.x/gridSize + 1
		SetAlpha 0.35
		For i = startPoint To endPoint
			x = (i*gridSize)*cam.position.z - camx + cam.screen_center_x
			DrawLine x,0,x,CANVAS_HEIGHT
		Next
		startPoint = -height/2 + cam.position.y/gridSize - 1
		endPoint = height/2 + cam.position.y/gridSize + 1
		For i = startPoint To endPoint
			y = (i*gridSize)*cam.position.z - camy + cam.screen_center_y
			DrawLine 0,y,CANVAS_WIDTH,y
		Next
	End Method



'--------------------------------------------------------------------------
' * Helpers
'--------------------------------------------------------------------------
	Method NrOfSelectedEntities:Int()
		Local List:TList = GetRightEntityList()
		If Not List Return 0
			
		Local entity:TEntity
		Local counter:Int = 0
		For entity = EachIn List
			If entity.selection.isSelected
				counter:+ 1
			EndIf
		Next
		Return counter
	End Method

	Method GetSelectedEntity:TEntity()
		Local List:TList = GetRightEntityList()
		
		Local entity:TEntity
		For entity = EachIn List
			If entity.selection.isSelected
				Return entity
			EndIf
		Next
		Return Null
	End Method

	Method ResetView()
		cam.SetFocus(centerObject)
		cam.zoomLerping = True
	End Method

	Method NewScene:Int()
		If Not EntityList.IsEmpty()
			AppTitle = "Close current Scene?"
			If Proceed("All unsaved progress will be lost.") <> 1
				Return False
			EndIf			
		EndIf
		ResetView()
		EntityList.Clear()
		Polys.Clear()
		Events.Clear()
		editor.WorldState.ClearAll()
		SceneProperty.Clear()
		NormalSceneProperty.Clear()
		gfxChooseWorld.page = 0
		SceneFile.Instance().currentlyOpened = ""
		Return True
	End Method
	
	Method SaveState()
		If editor.state > 2 Then Return
		editor.WorldState.ClearRedoList()
		If editor.mouse.lastDown = MOUSE_LEFT Then
			editor.WorldState.Save( editor.world.EntityList )
		EndIf
	End Method
	
	Method GetRightEntityList:TList()
		If Not editor
			Return Null
		EndIf
		If editor.exp_toolbar.mode = MODE_EDIT
			Return EntityList
		ElseIf editor.exp_toolbar.mode = MODE_COLLISION
			Return Polys
		ElseIf editor.exp_toolbar.mode = MODE_EVENT
			Return Events
		EndIf
		Return Null
	End Method
	
	Method GetEntityById:TEntity (id:String)
		For Local entity:TEntity = EachIn EntityList
			If entity.name = id
				Return entity
			EndIf
		Next
		Return Null
	End Method
	
	
'--------------------------------------------------------------------------
' * Right Click Create
'--------------------------------------------------------------------------
	Method OnRightClick()
		Select editor.exp_toolbar.mode
			Case MODE_EDIT
				gfxChooseWorld.RecreateLastEntity (editor.mouse.WorldCoordX(), editor.mouse.WorldCoordY())
				editor.exp_options.UpdatePropsUI()
			Case MODE_COLLISION
				CreatePoly()
				editor.exp_options.UpdatePropsUI()
			Case MODE_EVENT
				CreateEvent()
				editor.exp_options.UpdatePropsUI()
			Default
		End Select
	End Method

	Method CreatePoly:TEntity (selectMe:Byte = True)
		Local poly:TEntity = New TEntity
		poly.SetImage ("source/ressource/rect.png", 0)
		poly.color.a = 0.7
		poly.SetColor (200, 100, 100)
		poly.SetPosition (editor.mouse.WorldCoordX(), editor.mouse.WorldCoordY())
		If selectMe
			TSelection.ClearSelected (Polys)
			editor.exp_options.OnTabChange()
			editor.exp_options.ShowTransformAttributes (poly)
			poly.selection.isSelected = True
		EndIf
		AddPoly (poly)
		Return poly
	End Method

	Method CreateEvent:TEntity (selectMe:Byte = True)
		Local event:TEntity = New TEntity
		event.SetImage ("source/ressource/event.png", 0)
		event.color.a = 0.7
		event.SetColor (232, 214, 108)
		event.SetPosition (editor.mouse.WorldCoordX(), editor.mouse.WorldCoordY())
		If selectMe
			TSelection.ClearSelected (Events)
			editor.exp_options.OnTabChange()
			editor.exp_options.ShowTransformAttributes (event)
			event.selection.isSelected = True
		EndIf
		AddEvent (event)
		Return event
	End Method
	
	
'--------------------------------------------------------------------------
' * Undo/Redo
'--------------------------------------------------------------------------
	Method Undo()
		If editor.exp_toolbar.mode <> MODE_EDIT
			Return
		EndIf
		editor.WorldState.Undo (EntityList)
		editor.exp_options.ChangeTab( editor.exp_toolbar.selected )
		editor.exp_options.UpdatePropsUI()
		RedrawGadget( editor.window )
	End Method
	
	Method Redo()
		If editor.exp_toolbar.mode <> MODE_EDIT
			Return
		EndIf
		editor.WorldState.Redo (EntityList)
		editor.exp_options.ChangeTab( editor.exp_toolbar.selected )
		editor.exp_options.UpdatePropsUI()
		RedrawGadget( editor.window )
	End Method
	
'--------------------------------------------------------------------------
' * Do before world ends
'--------------------------------------------------------------------------
	Method OnExit()
	EndMethod
	
	Method SetMaxLayers(value:Int)
		Super.SetMaxLayers(value)
		SetSliderRange(editor.exp_options.prop_Layer, 1, MAX_LAYERS)
	End Method
	
	
'--------------------------------------------------------------------------
' * Overwrite original AddEntity to make sure there is no name twice
'--------------------------------------------------------------------------
	Method AddEntity( entity:TEntity )
		entity.link = EntityList.AddLast( entity )
	End Method
	
	Method AddPoly (poly:TEntity)
		poly.link = Polys.AddLast (poly)
	End Method
	
	Method AddEvent (event:TEntity)
		event.link = Events.AddLast (event)
	End Method
	
EndType





'--------------------------------------------------------------------------
' ** Choosing a graphic and place it inside the world
'--------------------------------------------------------------------------
Type TGraphicChooseWorld
	
	Const EDGE_DISTANCE_X:Int = 160
	Const EDGE_DISTANCE_Y:Int = 20
	Const CONTENT_SIZE:Int = 150
	Const IMAGE_MAXSIZE:Float = 120
	Field COLUMNS:Int
	Field PAGE_ITEMS:Int
	
	Field editor:TEditor
	Field arrow:TImage
	Field GraphicsArray:TImage[]
	Field GraphicsPath:String[]
	Field gfxLength:Int = 0
	Field page:Int = 0
	Field highlightLeft:Int = False
	Field highlightRight:Int = False
	
	Field introActive:Int = True
	Field outroActive:Int = False
	Field introAlpha:Float
	
	Field savedMouseX:Int
	Field savedMouseY:Int
	Field lastCreated:Int 'Gfx index of the last created entity
	
'------------------------------------------------------------------------------
' Init: Load bg-Image + world graphics
'------------------------------------------------------------------------------	
	Method Init()
		editor = TEditor.GetInstance()
		arrow = LoadImage("source/ressource/arrow.png")
		MidHandleImage( arrow )
		LoadGraphics()
		OnResize()
		Render()
	EndMethod

'--------------------------------------------------------------------------
' * Load all images from data folder
'--------------------------------------------------------------------------
	Method LoadGraphics()
		Local files:String[] = LoadDir (GfxWorkingDir)
		GraphicsArray = New TImage[files.Length]
		GraphicsPath = New String[files.Length]
		For Local i:Int = 0 Until files.Length
			If files[i].EndsWith(".png") Or files[i].EndsWith(".jpg")
				Local fileNoExtension:String = files[i][..files[i].Length-3]
				If FileType (GfxWorkingDir + fileNoExtension + "txt") = 1
					'Load Atlas
					Continue
				EndIf
				GraphicsPath[gfxLength] = GfxWorkingDir + files[i]
				GraphicsArray[gfxLength] = TManagedImage.Load( GraphicsPath[gfxLength] )
				MidHandleImage( GraphicsArray[gfxLength] )
				gfxLength:+ 1
			EndIf
		Next
	End Method
	
'--------------------------------------------------------------------------
' * Call when coming from state = 1 (editor mode)
'--------------------------------------------------------------------------
	Method OnEnter()
		editor.exp_toolbar.Disable()
		editor.exp_menu.Disable()
		editor.exp_options.Disable()
		introActive = True
		outroActive = False
		introAlpha = 0.0
		savedMouseX = editor.mouse.WorldCoordX()
		savedMouseY = editor.mouse.WorldCoordY()
		SetPointer( POINTER_DEFAULT )
	End Method
	
	Method OnExit()
		editor.exp_toolbar.Enable()
		editor.exp_menu.Enable()
		editor.exp_options.Enable()
		outroActive = True
		introActive = False
		introAlpha = 1.0
		editor.exp_options.UpdatePropsUI()
	End Method
	
'------------------------------------------------------------------------------
' Update all Logic
'------------------------------------------------------------------------------
	Method Update()
		If PointInRect( editor.mouse.x, editor.mouse.y, 20, CANVAS_HEIGHT/2-50, 100, 100 ) 'Left page
			highlightLeft = True
			If editor.mouse.IsDown() Then PreviousPage(); editor.mouse.SetUp()
			Return
		ElseIf PointInRect( editor.mouse.x, editor.mouse.y, CANVAS_WIDTH-120, CANVAS_HEIGHT/2-50, 100, 100 ) 'Right page
			highlightRight = True
			If editor.mouse.IsDown() Then NextPage(); editor.mouse.SetUp()
			Return
		Else
			highlightLeft = False
			highlightRight = False
		EndIf
		If editor.mouse.IsDown()
			If SelectedGraphic() <> -1
				editor.WorldState.Save( editor.world.EntityList )
				editor.WorldState.ClearRedoList()
				CreateEntity()
				editor.mouse.SetUp()
				Repeat
					editor.exp_toolbar.ActivateNextTool( editor )
				Until editor.exp_toolbar.selected = 1
			Else
				editor.GoToChooseMode()
			EndIf
		EndIf
	EndMethod
	
'------------------------------------------------------------------------------
' Render Entities + Selection in Viewfield
'------------------------------------------------------------------------------	
	Method Render()
		ResetDrawing()
		If introActive Then
			introAlpha:+ 0.25
			If introAlpha > 1.0 Then
				introActive = False
				introAlpha = 1.0
			EndIf
		ElseIf outroActive Then
			introAlpha:- 0.25
			If introAlpha < 0.01 Then
				outroActive = False
				introAlpha = 0.0
				Return
			EndIf
		EndIf
		
		SetAlpha introAlpha
		SetColor 240,240,240
		DrawRect 140, 0, CANVAS_WIDTH - 280, CANVAS_HEIGHT'-30
		SetColor 140,140,140
		DrawRect 140,0,1,CANVAS_HEIGHT'-30
		DrawRect CANVAS_WIDTH - 140,0,1,CANVAS_HEIGHT'-30
		DrawRect 140,CANVAS_HEIGHT,CANVAS_WIDTH-280,1
		SetColor 255,255,255
		
		Local i:Int
		Local maxVal:Int
		Local image:TImage
		Local scaleX:Float = 1.0
		Local scaleY:Float = 1.0
		Local from:Int = page * PAGE_ITEMS
		Local finish:Int = from + PAGE_ITEMS
		If finish > gfxLength
			finish = gfxLength
		EndIf
		If gfxLength > PAGE_ITEMS
			If highlightLeft
				SetAlpha 1.0*introAlpha
			Else
				SetAlpha 0.5*introAlpha
			EndIf
			DrawImage arrow, 70, CANVAS_HEIGHT/2
			If highlightRight
				SetAlpha 1.0*introAlpha
			Else
				SetAlpha 0.5*introAlpha
			EndIf
			SetScale -1.0, 1.0
			DrawImage arrow, CANVAS_WIDTH-70, CANVAS_HEIGHT/2
		EndIf
		ResetDrawing()
		Local id:Int = SelectedGraphic()
		For i = from Until finish
			image = GraphicsArray[i]
			If image
				maxVal = Max( image.width, image.height )
				If maxVal > IMAGE_MAXSIZE Then
					If maxVal = image.width Then
						scaleX = IMAGE_MAXSIZE / image.width
						scaleY = scaleX
					ElseIf maxVal = image.height
						scaleY = IMAGE_MAXSIZE / image.height
						scaleX = scaleY
					EndIf
				EndIf
				SetScale scaleX, scaleY
				DrawImage image, XPos(i), YPos(i)
				scaleX = 1.0
				scaleY = 1.0
			EndIf
		Next
		
		RenderEntityBorder()
		RenderSelected(id)
		
		ResetDrawing()
		SetOrigin(0,0)
		
		'Draw Page Nr
		SetColor 50,50,50
		If page > NrOfPages()
			page = NrOfPages()
		EndIf
		Local text:String = "Page " + (page+1) + " / " + (NrOfPages()+1)
		SetAlpha 0.7
		DrawText (text, CANVAS_WIDTH/2-TextWidth(text)/2, CANVAS_HEIGHT-22 )
	EndMethod

	Method RenderSelected(index:Int)
		If index = -1 Return
		Local image:TImage = GraphicsArray[index]
		If Not image Return
		SetAlpha (0.8*introAlpha)
		SetColor(62, 133, 226)
		SetScale (1.0, 1.0)
		DrawRect2(XPos(index) - IMAGE_MAXSIZE/2 - 4, YPos(index)-IMAGE_MAXSIZE/2 - 4, IMAGE_MAXSIZE + 8, IMAGE_MAXSIZE + 8, 2)
		SetAlpha (0.2 * introAlpha)
		SetBlend (LIGHTBLEND)
		DrawRect(XPos(index) - IMAGE_MAXSIZE/2, YPos(index)-IMAGE_MAXSIZE/2, IMAGE_MAXSIZE, IMAGE_MAXSIZE)
		SetBlend (ALPHABLEND)
		SetColor(255, 255, 255)
	End Method
	
	Method RenderEntityBorder()
		SetScale (1, 1)
		SetAlpha (1 * introAlpha)
		SetColor (200, 200, 200)
		Local from:Int = page * PAGE_ITEMS
		Local finish:Int = from + PAGE_ITEMS
		Local IMAGE_HALF:Int = IMAGE_MAXSIZE / 2.0
		If finish > gfxLength
			finish = gfxLength
		EndIf
		For Local i:Int = from Until finish
			DrawRect2 (XPos(i) - IMAGE_HALF, YPos(i) - IMAGE_HALF, IMAGE_MAXSIZE, IMAGE_MAXSIZE)
		Next
	End Method
	
	
'--------------------------------------------------------------------------
' * Creates an Entity in the middle of the screen
'--------------------------------------------------------------------------
	Method CreateEntity()
		Local entity:TEntity = New TEntity
		Local posX:Float = savedMouseX'editor.world.cam.position.X
		Local posY:Float = savedMouseY'editor.world.cam.position.Y
		entity.SetPosition( posX, posY )
		entity.SetLayer (editor.world.MAX_LAYERS/2)
		lastCreated = SelectedGraphic()
		entity.SetImage ( GraphicsPath[lastCreated] )
		TSelection.ClearSelected( editor.world.EntityList )
		entity.selection.isSelected = True
		editor.world.AddEntity( entity )
		editor.GoToChooseMode()
		editor.exp_options.OnTabChange()
		SetPointer( POINTER_SIZEALL )
		editor.exp_options.ShowTransformAttributes (entity)
	End Method
	
	Method RecreateLastEntity (posX:Int, posY:Float)
		Local entity:TEntity = New TEntity
		entity.SetPosition( posX, posY )
		entity.SetImage ( GraphicsPath[lastCreated] )
		entity.SetLayer (editor.world.MAX_LAYERS/2)
		TSelection.ClearSelected( editor.world.EntityList )
		entity.selection.isSelected = True
		editor.world.AddEntity( entity )
		editor.exp_options.OnTabChange()
		SetPointer( POINTER_SIZEALL )
		editor.exp_options.ShowTransformAttributes (entity)
	End Method
	
'--------------------------------------------------------------------------
' * Go to next/previous page
'--------------------------------------------------------------------------
	Method NextPage()
		If page >= NrOfPages()
			page = 0
		Else
			page:+ 1
		EndIf
	End Method
	
	Method PreviousPage()
		If page = 0
			page = NrOfPages()
		Else
			page:- 1
		EndIf
	End Method

'--------------------------------------------------------------------------
' * Get total amount of pages
'--------------------------------------------------------------------------
	Method NrOfPages:Int()
		If gfxLength Mod PAGE_ITEMS = 0 Then
			Return gfxLength/PAGE_ITEMS - 1
		EndIf
		Return gfxLength/PAGE_ITEMS
	End Method

'--------------------------------------------------------------------------
' * Get Render Position
'--------------------------------------------------------------------------
	Method XPos:Float( id:Int )
		Return EDGE_DISTANCE_X + CONTENT_SIZE/2 + (id Mod COLUMNS) * CONTENT_SIZE
	End Method
	
	Method YPos:Float( id:Int )
		Return EDGE_DISTANCE_Y + CONTENT_SIZE/2 + (id / COLUMNS) * CONTENT_SIZE - (page * CONTENT_SIZE * (PAGE_ITEMS/COLUMNS))
	End Method

'--------------------------------------------------------------------------
' * Returns the id of the selected Graphics
'--------------------------------------------------------------------------
	Method SelectedGraphic:Int()
		If Not MouseInSelectionArea() Return -1
		Local realX:Int = (editor.mouse.x - EDGE_DISTANCE_X) / CONTENT_SIZE
		Local realY:Int = (editor.mouse.y - EDGE_DISTANCE_Y) / CONTENT_SIZE
		Local result:Int = (realY * COLUMNS) + realX + (page * PAGE_ITEMS)
		If result <= gfxLength-1
			If result < ((page+1)*PAGE_ITEMS)
				Return result
			EndIf
		EndIf
		Return -1
	End Method

'--------------------------------------------------------------------------
' * Returns True if Mouse is in Area to select Graphic
'--------------------------------------------------------------------------
	Method MouseInSelectionArea:Int()
		If (editor.mouse.x > EDGE_DISTANCE_X) And (editor.mouse.x < EDGE_DISTANCE_X + editor.exp_canvas.canvas.ClientWidth() - EDGE_DISTANCE_X - EDGE_DISTANCE_X)..
			And (editor.mouse.y > EDGE_DISTANCE_Y) And (editor.mouse.y < EDGE_DISTANCE_Y + editor.exp_canvas.canvas.ClientHeight() - EDGE_DISTANCE_Y - EDGE_DISTANCE_Y)
			Return True
		EndIf
		Return False
	End Method
	
	
'--------------------------------------------------------------------------
' * Update variables for rendering
'--------------------------------------------------------------------------
	Method OnResize()
		COLUMNS = (editor.exp_canvas.canvas.ClientWidth() - (EDGE_DISTANCE_X*2)) / CONTENT_SIZE
		PAGE_ITEMS = COLUMNS * ((editor.exp_canvas.canvas.ClientHeight() - (EDGE_DISTANCE_Y*2)) / CONTENT_SIZE)
	End Method
	
End Type


