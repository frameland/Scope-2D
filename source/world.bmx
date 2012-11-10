Global GfxWorkingDir:String
Global MapWorkingDir:String

'------------------------------------------------------------------------------
' Editing Mode
'------------------------------------------------------------------------------
Type EditorWorld Extends TWorld

	Field editor:TEditor
	Field NameList:TMap
	Field gfxChooseWorld:TGraphicChooseWorld
	Field rect_selection:RectSelection
	Field size:TPosition 'Size of the World in Pixels
	Field Polys:TList = New TList
	
'------------------------------------------------------------------------------
' Initialize the World
'------------------------------------------------------------------------------	
	Method Init()
		LoadConfig()
		
		editor = TEditor.GetInstance()
		rect_selection = New RectSelection
		gfxChooseWorld = New TGraphicChooseWorld
		size = New TPosition
		size.Set (2500,1000)
		gfxChooseWorld.Init()
		SetMaxLayers( 5 )
		NameList = New TMap
		
		'Ensure there is no lag in the beginning
		Local canvas:TGadget = editor.exp_canvas.canvas
		Render()
		DrawRect( 0, 0, canvas.width, canvas.height )
		Flip 0
		Delay 10
	EndMethod
	
	Method LoadConfig()
		Local config:ConfigFile = New ConfigFile
		config.Load ("source/ressource/config.css")
		GfxWorkingDir = config.Get ("Config", "gfxdir")
		MapWorkingDir = config.Get ("Config", "mapdir")
		If (GfxWorkingDir = "") Or (MapWorkingDir = "")
			AppTitle = "Configuration Error!"
			Notify ("You first have to set the gfx and map directory.")
			OpenUrl ("source/ressource/config.css")
			End
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
				If editor.mouse.lastDown = MOUSE_LEFT
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
		Local distance:Float = 10000
		
		If mouse.Dragging
			If Not rect_selection.started Then
				rect_selection.StartSelection( mouse.WorldCoordX(), mouse.WorldCoordY() )
			EndIf
			If mouse.MultiSelect <> True
				TSelection.ClearSelected( List )
			EndIf
			rect_selection.Update(  mouse.WorldCoordX(), mouse.WorldCoordY() )
			For entity = EachIn List
				If Not IsInView( entity )
					Continue
				EndIf
				If rect_selection.IsInSelection( entity )
					entity.selection.isSelected = True
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
		Local grid:Int = 1
		If editor.exp_menu.gridSwitch
			grid = editor.exp_menu.gridSize
		EndIf
		Local x:Int
		Local y:Int
		'  + entity.image.width/2 -> means that it will snap to edges
		' remove to snap to center
		If ButtonState( editor.exp_options.move_MoveStraight )
			If Pos( editor.mouse.XDisplacement() ) > Pos( editor.mouse.YDisplacement() )
				'Move X
				For entity = EachIn List
					If entity.selection.isSelected
						x = Int( entity.memory_position.x + editor.mouse.XDisplacement() )
						y = Int( entity.memory_position.y )
						If (grid > 1)
							entity.position.Set( x - (x Mod grid) + entity.size.width/2, y - (y Mod grid) + entity.size.height/2 )
						Else
							entity.position.Set( x - (x Mod grid), y - (y Mod grid) )
						EndIf
					EndIf
				Next
			Else 'Move Y
				For entity = EachIn List
					If entity.selection.isSelected
						x = Int( entity.memory_position.x )
						y = Int( entity.memory_position.y + editor.mouse.YDisplacement() )
						If (grid > 1)
							entity.position.Set( x - (x Mod grid) + entity.size.width/2, y - (y Mod grid) + entity.size.height/2 )
						Else
							entity.position.Set( x - (x Mod grid), y - (y Mod grid) )
						EndIf
					EndIf
				Next
			EndIf
				
		Else 'Move in all Directions
			For entity = EachIn List
				If entity.selection.isSelected
					x = Int( entity.memory_position.x + editor.mouse.XDisplacement() )
					y = Int( entity.memory_position.y + editor.mouse.YDisplacement() )
					If (grid > 1)
						entity.position.Set( x - (x Mod grid) + entity.size.width/2, y - (y Mod grid) + entity.size.height/2 )
					Else
						entity.position.Set( x - (x Mod grid), y - (y Mod grid) )
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
				angle = angle Mod 360
				If ButtonState(editor.exp_options.rotate_Snap)
					value = 22.5 'change!!! to let it be moddable
					angle:- (angle Mod value)
				EndIf
				entity.SetRotation( TrimFloat(angle) )
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
				If keepAspect 'Scaling both, x + y axis
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
				dummy.image = entity.image
				dummy.texturePath = entity.texturePath
				dummy.rotation = entity.rotation
				dummy.color.SetRGB( entity.color.r, entity.color.g, entity.color.b )
				dummy.color.a = entity.color.a
				dummy.size.Set( entity.size.width, entity.size.height )
				dummy.collision = entity.collision.GetCopy( dummy )
				dummy.layer = entity.layer
				dummy.name = entity.name
				dummy.frame = entity.frame
				dummy.visible = entity.visible
				dummy.active = entity.active
				dummy.selection.Init( dummy )
				If editor.exp_toolbar.mode = MODE_EDIT
					AddEntity( dummy )
				ElseIf editor.exp_toolbar.mode = MODE_COLLISION
					AddPoly (dummy)
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
		Select editor.exp_toolbar.mode
			Case MODE_EDIT
				renderedSprites = RenderEditMode()
			Case MODE_COLLISION
				RenderCollisionMode()
			Case MODE_EVENT
				RenderEventMode()
			Default
		End Select
		RenderWorldBorder()
		
		'DebugRender( renderedSprites )
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
		'Render Events
	End Method
	
	
	Method DebugRender( renderedSprites:Int )
		Local height:Int = 4
		ResetDrawing()
		SetHandle 0,0
		SetColor 0, 0, 0
		SetAlpha 1
		DrawText "Fps: " + GetFps(), 4, height
		height:+16
		DrawText "Sprites OnScreen: " + renderedSprites, 4, height
		height:+ 16
		DrawText ("Sprites: " + EntityList.Count(), 4, height)
	End Method
	
	Method RenderWorldBorder()
		If Not editor.exp_menu.xySwitch Then Return
		
		'Lines
		Local pos:Float
		ResetDrawing()
		SetAlpha 1.0
		SetColor 190,190,190
		Local lengthX:Float = (size.x-cam.position.x)*cam.position.z+cam.screen_center_x + cam.border
		Local lengthY:Float = (size.y-cam.position.y)*cam.position.z+cam.screen_center_y + cam.border
		pos = (-cam.position.y * cam.position.z + cam.screen_center_y)
		DrawRect (0, pos, lengthX, 1)
		pos = (-cam.position.x * cam.position.z + cam.screen_center_x)
		DrawRect (pos, 0, 1, lengthY)
		pos = ((size.y - cam.position.y) * cam.position.z + cam.screen_center_y)
		DrawRect (0, pos, lengthX, 1)
		pos = ((size.x - cam.position.x) * cam.position.z + cam.screen_center_x)
		DrawRect (pos, 0, 1, lengthY)
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
		SetAlpha 0.15
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
		cam.position.x = 0.0
		cam.position.y = 0.0
		cam.position.z = 1.0
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
		EndIf
		Return Null
	End Method
	
	Method OnRightClick()
		Select editor.exp_toolbar.mode
			Case MODE_EDIT
				
			Case MODE_COLLISION
				CreatePoly()
			Case MODE_EVENT
				
			Default
		End Select
	End Method

	Method CreatePoly:TEntity (selectMe:Byte = True)
		Local poly:TEntity = New TEntity
		poly.SetImage ("source/ressource/rect.png")
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

'--------------------------------------------------------------------------
' * Overwrite original AddEntity to make sure there is no name twice
'--------------------------------------------------------------------------
	Method AddEntity( entity:TEntity )
		entity.link = EntityList.AddLast( entity )
		entity.name = UniqueEntityName( entity.name )
	End Method
	
	Method AddPoly (poly:TEntity)
		poly.link = Polys.AddLast (poly)
	End Method
	
	
'--------------------------------------------------------------------------
' * Make sure there is no name twice
'--------------------------------------------------------------------------
	Method UniqueEntityName:String( name:String )
		If name = "" Then Return ""
		While NameList.Contains( name )
			name = name + "_copy"
		Wend
		NameList.Insert( name, name )
		Return name
	End Method
	
EndType





'--------------------------------------------------------------------------
' ** Choosing a graphic and place it inside the world
'--------------------------------------------------------------------------
Type TGraphicChooseWorld
	
	Const EDGE_DISTANCE_X:Int = 160
	Const EDGE_DISTANCE_Y:Int = 20
	Const CONTENT_SIZE:Int = 112
	Const IMAGE_MAXSIZE:Float = 108
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
	
'------------------------------------------------------------------------------
' Init: Load bg-Image + world graphics
'------------------------------------------------------------------------------	
	Method Init()
		editor = TEditor.GetInstance()
		arrow = LoadImage("source/ressource/arrow.png")
		MidHandleImage( arrow )
		LoadGraphics()
		OnResize()
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
				If id = i
					SetAlpha 0.8*introAlpha
				Else
					SetAlpha 1.0*introAlpha
				EndIf
				DrawImage image, XPos(i), YPos(i)
				scaleX = 1.0
				scaleY = 1.0
			EndIf
		Next
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


'--------------------------------------------------------------------------
' * Creates an Entity in the middle of the screen
'--------------------------------------------------------------------------
	Method CreateEntity()
		Local entity:TEntity = New TEntity
		Local posX:Float = savedMouseX'editor.world.cam.position.X
		Local posY:Float = savedMouseY'editor.world.cam.position.Y
		entity.SetPosition( posX, posY )
		entity.SetImage ( GraphicsPath[SelectedGraphic()] )
		TSelection.ClearSelected( editor.world.EntityList )
		entity.selection.isSelected = True
		editor.world.AddEntity( entity )
		editor.GoToChooseMode()
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


