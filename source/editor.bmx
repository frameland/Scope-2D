Const WINDOW_MINX:Int = 680
Const WINDOW_MINY:Int = 360
Global CANVAS_WIDTH:Int = 960
Global CANVAS_HEIGHT:Int = 640
Const STANDARD_LAYERS:Int = 10


'------------------------------------------------------------------------------
' Type-Info: GUI Main Type, Used as a Singelton
'------------------------------------------------------------------------------
Type TEditor
	
	Const VERSION:String = "r5"
	
	Global instance:TEditor
	Field window:TGadget
	Field mouse:TGuiMouse
	Field is_ending:Byte = False
	
	'1 = canvas mode, 2 = else, 3 = Graphic Choosing
	Field state:Int = 1
	
	Field editMode:Byte = True
	Field moveMode:Byte = False
	
	Field exp_menu:ExpMenu
	Field exp_toolbar:ExpToolbar
	Field exp_canvas:ExpCanvas
	Field exp_options:ExpOptions
	
	Field world:EditorWorld
	Field WorldState:TWorldState
	
	Field activeWindow:Int = 1
	Field window_about:AboutWindow
	Field window_setLayer:LayerSetterWindow
	Field window_gridSize:GridSizeWindow
	Field window_sceneProps:ScenePropertyWindow
	Field zoomMX:Int
	Field zoomMY:Int
	
'------------------------------------------------------------------------------	
'	Info: Create a New Editor Window
'	Returns: /
'------------------------------------------------------------------------------
	Method New()
		Init()
		CreateTimer( 60 )
		instance = Self
		Local flags:Int = WINDOW_TITLEBAR | WINDOW_CLIENTCOORDS | WINDOW_MENU | WINDOW_CENTER | WINDOW_ACCEPTFILES | WINDOW_RESIZABLE
		?MacOS
			flags = flags | WINDOW_FULLSCREEN
		?
		window = CreateWindow( "Scope 2D",0,0,CANVAS_WIDTH+200,CANVAS_HEIGHT,Null,flags )
		HideGadget( window )
		SetMinWindowSize( window, WINDOW_MINX, WINDOW_MINY )
		world = New EditorWorld
		mouse = New TGuiMouse
		exp_menu = New ExpMenu
		exp_menu.Init( Self )
		exp_toolbar = New ExpToolbar
		exp_toolbar.Init( Self )
		exp_options = New ExpOptions
		exp_options.Init( Self )
		exp_canvas = New ExpCanvas
		exp_canvas.Init( Self )
		WorldState = New TWorldState
		AddHook EmitEventHook, MainHook, Self
		RedrawGadget( window )
		exp_toolbar.SetSelected()
		window_about = New AboutWindow
		window_setLayer = New LayerSetterWindow
		window_gridSize = New GridSizeWindow
		window_sceneProps = New ScenePropertyWindow
		ShowGadget( window )
	EndMethod
	
	
'------------------------------------------------------------------------------	
'	Info: Act on events
'	Returns: /
'------------------------------------------------------------------------------	
	Method OnEvent( event:TEvent )
'--------------------------------------------------------------------------
' * If activeWindow <> 1 (main_window) update another window
'--------------------------------------------------------------------------
		Select activeWindow
			Case 1 'Main Window
				'Do Nothing
			Case 2 'About
				window_about.OnEvent( event )
				Return
			Case 3
				window_setLayer.OnEvent( event )
				Return
			Case 4
				window_gridSize.OnEvent( event )
				Return
			Case 5
				window_sceneProps.OnEvent( event )
				Return
			Default
		End Select
		
		
		Select event.id
'--------------------------------------------------------------------------
' * Close Window
'--------------------------------------------------------------------------			
			Case EVENT_WINDOWCLOSE
				EndProgram()
			Case EVENT_APPTERMINATE
				EndProgram()
'--------------------------------------------------------------------------
' * Request canvas redraw
'--------------------------------------------------------------------------			
			Case EVENT_TIMERTICK
				ToggleCanvas()
				world.cam.Update()
				RedrawGadget( exp_canvas.canvas )
				
			Case EVENT_GADGETPAINT
				exp_canvas.Render()
				
'--------------------------------------------------------------------------
' * MouseWheel
'--------------------------------------------------------------------------
			Case EVENT_MOUSEWHEEL
				If state <> 1 Then Return
				Zoom(-event.data)

'--------------------------------------------------------------------------
' * MouseMove
'--------------------------------------------------------------------------
			Case EVENT_MOUSEMOVE
				mouse.UpdateCoords( event.x, event.y )
				If mouse.IsDown() And mouse.Dragging = False
					mouse.StartDrag()
					If state = 1
						If Not moveMode
							world.InitOperation( exp_toolbar.selected)
						Else
							world.cam.memory_z = world.cam.position.z
						EndIf
					EndIf
				EndIf
				world.Update()
				zoomMX = mouse.WorldCoordX()
				zoomMY = mouse.WorldCoordY()
				exp_options.UpdateTransforms()
				
'--------------------------------------------------------------------------
' * MouseDown
'--------------------------------------------------------------------------
			Case EVENT_MOUSEDOWN
				If event.data = MOUSE_LEFT
					mouse.lastDown = MOUSE_LEFT
					mouse.SetDown()
					If (event.source = exp_options.labelRed) Or (event.source = exp_options.labelGreen) Or (event.source = exp_options.labelBlue)
						If (world.NrOfSelectedEntities() > 0) And (editMode = True)
							exp_options.SetColor()
							mouse.SetUp()
						EndIf
					ElseIf (event.source = exp_options.labelLayer)
						window_setLayer.Show()
					EndIf
					exp_options.UpdateTransforms()
				ElseIf event.data = MOUSE_RIGHT
					mouse.lastDown = MOUSE_RIGHT
					mouse.SetDown()
					world.OnRightClick()
				ElseIf event.data = MOUSE_MIDDLE
					mouse.lastDown = MOUSE_LEFT
					mouse.SetDown()
					moveMode = True
				EndIf
				world.Update()
				
'--------------------------------------------------------------------------
' * MouseUp
'--------------------------------------------------------------------------
			Case EVENT_MOUSEUP
				mouse.SetUp()
				If (mouse.removeSelectionOnUp)
					If exp_toolbar.mode = MODE_EDIT
						TSelection.ClearSelected( world.EntityList )
					ElseIf exp_toolbar.mode = MODE_COLLISION
						TSelection.ClearSelected( world.Polys)
					EndIf
					mouse.removeSelectionOnUp = False
				EndIf
				If world.rect_selection.started Then
					world.rect_selection.EndSelection()
				EndIf
				If event.data = MOUSE_MIDDLE
					moveMode = False
				EndIf
				world.Update()
				If state <> 1 Then Return
				
'--------------------------------------------------------------------------
' * Mouse Enter
'--------------------------------------------------------------------------
			Case EVENT_MOUSEENTER
				Select event.source
					Case exp_options.labelRed, exp_options.labelGreen, exp_options.labelBlue
						If (world.NrOfSelectedEntities() > 0) And (editMode = True)
							SetPointer( POINTER_HAND )
						EndIf
					Case exp_canvas.canvas
						If Not editMode Then
							Return
						EndIf
						If exp_toolbar.selected = 0
							SetPointer( POINTER_DEFAULT )
						ElseIf exp_toolbar.selected = 1
							SetPointer( POINTER_SIZEALL )
						ElseIf exp_toolbar.selected = 2
							If ButtonState(exp_options.scale_KeepAspect)
								SetPointer( POINTER_SIZEWE )
							Else
								SetPointer( POINTER_SIZENESW )
							EndIf
						ElseIf exp_toolbar.selected = 3
							SetPointer( POINTER_SIZEWE )
						EndIf
					Case (exp_options.labelLayer)
						SetPointer( POINTER_HAND )
					Default
				End Select
				
'--------------------------------------------------------------------------
' * Mouse Leave
'--------------------------------------------------------------------------
			Case EVENT_MOUSELEAVE
				Select event.source
					Case exp_options.labelRed, exp_options.labelGreen, exp_options.labelBlue, exp_options.labelLayer
						SetPointer( POINTER_DEFAULT )
					Case exp_canvas.canvas
						SetPointer( POINTER_DEFAULT )
					Default
				End Select
				
'--------------------------------------------------------------------------
' * Keys
'--------------------------------------------------------------------------	
			Case EVENT_KEYDOWN
				moveMode = False
				Select event.data
					Case KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN
						world.ProcessPixelMoving (event.data)
					Case KEY_Q
						exp_toolbar.OnClick (7)
					Case KEY_W
						exp_toolbar.OnClick (8)
					Case KEY_E
						exp_toolbar.OnClick (9)
					Case KEY_R
						exp_toolbar.OnClick (10)

					Case KEY_1
						exp_toolbar.OnClick (12)
					Case KEY_2
						exp_toolbar.OnClick (13)
					Case KEY_3
						exp_toolbar.OnClick (14)
						
					Case KEY_Y, KEY_Z
						world.Undo()
					
					Case KEY_D
						world.ChangeEntityLayer (False)
					Case KEY_F
						world.ChangeEntityLayer (True)
					
					Case KEY_LSHIFT
						If state <> 1 Then Return
						exp_options.ToggleExtra( Self )
					Case KEY_BACKSPACE, KEY_DELETE
						world.RemoveEntities()
					Case KEY_SPACE
						GoToChooseMode()
					Case 91, KEY_LALT '91 is command
						moveMode = True
					Case KEY_F1
						DebugStop()
					Case KEY_TAB	
						If state = 3
							world.gfxChooseWorld.NextPage()
						EndIf
					Default
				End Select
			Case EVENT_KEYUP
				Select event.data
					Case 91, KEY_LALT
						moveMode = False
					Default
				End Select
				world.cam.Update()
			
'--------------------------------------------------------------------------
' * Gadgetaction
'--------------------------------------------------------------------------		
			Case EVENT_GADGETACTION
				Select event.source
'--------------------------------------------------------------------------
' * Toolbar
'--------------------------------------------------------------------------
					Case exp_toolbar.toolbar
						exp_toolbar.OnClick( event.data )
'--------------------------------------------------------------------------
' * Options
'--------------------------------------------------------------------------
					Case exp_options.select_MultiSelect
						mouse.MultiSelect = ButtonState( exp_options.select_MultiSelect )
'--------------------------------------------------------------------------
' * Properties
'--------------------------------------------------------------------------
					Case exp_options.prop_Name
						exp_options.SetName()
					Case exp_options.prop_Layer
						exp_options.SetLayer()
					Case exp_options.prop_Red
						exp_options.SetRed()
					Case exp_options.prop_Green
						exp_options.SetGreen()
					Case exp_options.prop_Blue
						exp_options.SetBlue()
					Case exp_options.prop_Alpha
						exp_options.SetAlpha()
					Case exp_options.propIsFrontSprite
						exp_options.ChangeTypeOfEntity()
					Case exp_options.objectTriggering
						exp_options.SetObjectTriggering()
					Case exp_options.openScriptButtonEnter
						exp_options.OpenScript ("on_enter")
					Case exp_options.openScriptButtonAction
						exp_options.OpenScript ("on_action")
					Case exp_options.okButton
						exp_options.SetTransforms()
					Default
						'RuntimeError "Unrecognized Event: " + CurrentEvent.ToString()
				End Select

'--------------------------------------------------------------------------
' * Menu
'--------------------------------------------------------------------------				
			Case EVENT_MENUACTION
				exp_menu.OnEvent( event.data )
'--------------------------------------------------------------------------
' * Resizing Window
'--------------------------------------------------------------------------
			Case EVENT_WINDOWSIZE
				CANVAS_WIDTH = ClientWidth(window)-200
				CANVAS_HEIGHT = ClientHeight(window)
				world.cam.OnWindowResize()
				exp_canvas.OnWindowResize( Self )
				world.gfxChooseWorld.OnResize()

'--------------------------------------------------------------------------
' * Darg'n Drop
'--------------------------------------------------------------------------
			Case EVENT_WINDOWACCEPT
				Local filepath:String = event.extra.ToString()
				Local extension:String = ExtractExt( filepath )
				If extension = "xml"
					SceneFile.Instance().Open( filepath )
				EndIf
				
'--------------------------------------------------------------------------
' * Something went wrong
'--------------------------------------------------------------------------				
			Default
				'RuntimeError "Unrecognized Event: " + CurrentEvent.ToString()
		EndSelect
		
	EndMethod
	
	
'--------------------------------------------------------------------------
' * Set canvas active or not
'--------------------------------------------------------------------------
	Method ToggleCanvas()
		Local realX:Int = DesktopMouseX() - window.xpos
		If realX < CANVAS_WIDTH
			If ActiveGadget() <> exp_canvas.canvas Then
				ActivateGadget( exp_canvas.canvas )
				If state = 2 Then state = 1
			EndIf
		Else
			If state = 3 Then Return
			If ActiveGadget() = exp_canvas.canvas Then
				ActivateGadget( exp_options.panel )
				state = 2
			EndIf
		EndIf
	End Method


'--------------------------------------------------------------------------
' * Go to gfxChooser or back (with SPACE)
'--------------------------------------------------------------------------
	Method GoToChooseMode()
		If (state = 1) And (exp_toolbar.mode = MODE_EDIT) 
			editMode = False
			state = 3
			world.gfxChooseWorld.OnEnter()
		ElseIf state = 3
			editMode = True
			state = 1
			world.gfxChooseWorld.OnExit()
			If exp_toolbar.selected = 0
				SetPointer( POINTER_DEFAULT )
			ElseIf exp_toolbar.selected = 1
				SetPointer( POINTER_SIZEALL )
			ElseIf exp_toolbar.selected = 2
				If ButtonState(exp_options.scale_KeepAspect)
					SetPointer( POINTER_SIZEWE )
				Else
					SetPointer( POINTER_SIZENESW )
				EndIf
			ElseIf exp_toolbar.selected = 3
				SetPointer( POINTER_SIZEWE )
			EndIf
		EndIf
	End Method
	
'--------------------------------------------------------------------------
' * Zoom In/Out
'--------------------------------------------------------------------------
	Method Zoom( eventData:Int )
		If world.cam.position.x > zoomMX
			world.cam.position.x:- (world.cam.position.x-zoomMX)/20
		Else
			world.cam.position.x:+ (zoomMX-world.cam.position.x)/20
		EndIf
		If world.cam.position.y > zoomMY                         
			world.cam.position.y:- (world.cam.position.y-zoomMY)/20
		Else
			world.cam.position.y:+ (zoomMY-world.cam.position.y)/20
		EndIf
		If eventData > 0
			world.ZoomOut(1+eventData/100.0)
		ElseIf eventData < 0
			world.ZoomIn(1+eventData/100.0)
		EndIf
	End Method
	
'--------------------------------------------------------------------------
' * Hook Function so everything happens realtime
'--------------------------------------------------------------------------
	Function MainHook:Object( id:Int, data:Object, context:Object )
		Local event:TEvent = TEvent( data )
		If event = Null Then Return Null
		Local editor:TEditor = TEditor(context)
		editor.OnEvent( event )
		Return data
	End Function


'------------------------------------------------------------------------------	
'	Info: This Method provides a way for setting some initial Values
'	Returns: /
'------------------------------------------------------------------------------
	Method Init()
		AutoImageFlags (MIPMAPPEDIMAGE|FILTEREDIMAGE)
		SetGraphicsDriver( GLMax2DDriver(), GRAPHICS_BACKBUFFER )
		GLShareContexts()
	EndMethod
	
	
'------------------------------------------------------------------------------	
'	Info: 
'	Returns: True if the Program should Quit
'------------------------------------------------------------------------------
	Method Ending:Byte()
		Return Self.is_ending
	EndMethod
	
	
'------------------------------------------------------------------------------	
'	Info: Ends the Program (user may have to confirm)
'	Returns: /
'------------------------------------------------------------------------------	
	Method EndProgram()
		If world.EntityList.IsEmpty() Then
			Self.is_ending = True
			Return
		EndIf
		AppTitle = "Quit Scope 2D?"
		If Proceed("All unsaved progress will be lost") = 1
			Self.is_ending = True
		EndIf
	EndMethod
	
	
'------------------------------------------------------------------------------	
'	Info: Returns the current TEditor Object or a newly created if no exists
'------------------------------------------------------------------------------	
	Function GetInstance:TEditor()
		If instance Then Return instance Else Return (New TEditor)
	EndFunction
	
EndType




'------------------------------------------------------------------------------
' Type-Info: Every Expansion of TEditor has to expand on this Type
'------------------------------------------------------------------------------
Type TEditorExpansion Abstract
	Field editor_reference:TEditor
	Method Init( editor:TEditor ) Abstract
EndType
