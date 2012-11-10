Type ExpMenu Extends TEditorExpansion
	
	Field editor:TEditor
	
'--------------------------------------------------------------------------
' * Menu Entries
'--------------------------------------------------------------------------
	Field file:TGadget
	Field edit:TGadget
	Field view:TGadget
	Field game:TGadget
	Field help:TGadget
	
	Field view_grid:TGadget
	Field view_axis:TGadget
	
	Const M_FILE:Int = 1
	Const M_EDIT:Int = 2
	Const M_VIEW:Int = 3
	Const M_GAME:Int = 4
	Const M_HELP:Int = 5
	
	Const M_NEW:Int = 11
	Const M_OPEN:Int = 12
	Const M_RECENT:Int = 13
	Const M_SAVE:Int = 14
	Const M_SAVEAS:Int = 15
	Const M_QUIT:Int = 16
	Const M_SCENE_SETTINGS:Int = 17
	
	Const M_UNDO:Int = 21
	Const M_REDO:Int = 22
	Const M_CLONE:Int = 23
	Const M_DELETE:Int = 24
	Const M_SELECTALL:Int = 25
	Const M_SELECTNONE:Int = 26
	Const M_FLIP_VERTICAL:Int = 27
	Const M_FLIP_HORIZONTAL:Int = 28
	Const M_FILL:Int = 29 
	
	Const M_RESETVIEW:Int = 31
	Const M_SHOWGRID:Int = 32
	Const M_GRIDSIZE:Int = 34
	Const M_XYAXIS:Int = 33
	
	Const M_PLAY:Int = 51
	Const M_SCRIPTING:Int = 52
	Const M_SETTINGS:Int = 53
	
	Const M_HELPUSER:Int = 61
	Const M_ABOUT:Int = 62
	
	Field gridSize:Int = 64
	Field gridSwitch:Byte = False
	Field xySwitch:Byte = True
	
'--------------------------------------------------------------------------
' * Initialize menu
'--------------------------------------------------------------------------	
	Method Init( editor:TEditor )
		Self.editor = editor
		file = CreateMenu( "Scene", M_FILE,  WindowMenu( editor.window ) )
		edit = CreateMenu( "Edit", M_FILE,  WindowMenu( editor.window ) )
		view = CreateMenu( "View", M_FILE,  WindowMenu( editor.window ) )
		'game = CreateMenu( "Game", M_FILE,  WindowMenu( editor.window ) )
		help = CreateMenu( "Help", M_FILE,  WindowMenu( editor.window ) )
		'file
		CreateMenu( "New", M_NEW, file, KEY_N, MODIFIER_COMMAND )
		CreateMenu( "Open...", M_OPEN, file, KEY_O, MODIFIER_COMMAND )
		CreateMenu( "", 0, file )
		CreateMenu( "Save", M_SAVE, file, KEY_S, MODIFIER_COMMAND )
		CreateMenu( "Save As...", M_SAVEAS, file, KEY_S, MODIFIER_COMMAND|MODIFIER_SHIFT )
		CreateMenu( "", 0, file )
		CreateMenu( "Properties", M_SCENE_SETTINGS, file )
		?Win32
		CreateMenu( "", 0, file )
		CreateMenu( "Quit", M_QUIT, file, KEY_Q, MODIFIER_COMMAND )
		?
		'edit
		CreateMenu( "Undo", M_UNDO, edit, KEY_Z, MODIFIER_COMMAND )
		CreateMenu( "Redo", M_REDO, edit,KEY_Z, MODIFIER_COMMAND|MODIFIER_SHIFT )
		CreateMenu( "", 0, edit )
		CreateMenu( "Clone", M_CLONE, edit, KEY_C, MODIFIER_COMMAND )
		CreateMenu( "Delete", M_DELETE, edit, KEY_BACKSPACE )
		CreateMenu( "", 0, edit )
		CreateMenu( "Flip Horizontally", M_FLIP_HORIZONTAL, edit )
		CreateMenu( "Flip Vertically", M_FLIP_VERTICAL, edit )
		CreateMenu( "", 0, edit )
		CreateMenu( "Select All", M_SELECTALL, edit, KEY_A, MODIFIER_COMMAND )
		CreateMenu( "Select None", M_SELECTNONE, edit, KEY_D, MODIFIER_COMMAND )
		'view
		CreateMenu( "Reset View", M_RESETVIEW, view, KEY_R, MODIFIER_COMMAND  )
		CreateMenu( "", 0, view )
		view_axis = CreateMenu( "Hide Border", M_XYAXIS, view )
		CreateMenu( "", 0, view )
		view_grid = CreateMenu( "Show Grid", M_SHOWGRID, view )
		CreateMenu( "Set Grid Size...", M_GRIDSIZE, view )
		'game
		'CreateMenu( "Play", M_PLAY, game )
		'CreateMenu( "Script Editor", M_SCRIPTING, game )
		'CreateMenu( "", 0, game )
		'CreateMenu( "Settings", M_SETTINGS, game )
		'help
		CreateMenu( "Docs", M_HELPUSER, help )
		CreateMenu( "", 0, help )
		CreateMenu( "About", M_ABOUT, help )
		UpdateWindowMenu( editor.window )
	EndMethod
	

'--------------------------------------------------------------------------
' * Act when menu item clicked
'--------------------------------------------------------------------------
	Method OnEvent( event:Int )
		Select event
			'file
			Case M_NEW
				editor.world.NewScene()
			Case M_OPEN
				SceneFile.Instance().Open()
			Case M_SAVE
				SceneFile.Instance().Save()
			Case M_SAVEAS
				SceneFile.Instance().SaveAs()
			Case M_SCENE_SETTINGS
				editor.window_sceneProps.Show()
			?Win32
			Case M_QUIT
				editor.EndProgram()
			?
			'edit
			Case M_UNDO
				editor.world.Undo()
			Case M_REDO
				editor.world.Redo()
			Case M_CLONE
				editor.world.CloneEntities()
				If editor.exp_options.currentGadget = 6
					editor.exp_options.ChangeTab( 6 )
				EndIf
			Case M_DELETE
				editor.world.RemoveEntities()
				RedrawGadget( editor.window )
			Case M_FLIP_HORIZONTAL
				editor.world.ExecuteFlipping( True )
			Case M_FLIP_VERTICAL
				editor.world.ExecuteFlipping( False )
			Case M_SELECTALL
				If editor.exp_toolbar.mode = MODE_EDIT
					TSelection.SelectAll (editor.world.EntityList)
				ElseIf editor.exp_toolbar.mode = MODE_COLLISION
					TSelection.SelectAll (editor.world.Polys)
				EndIf
				RedrawGadget( editor.window )
				editor.exp_options.UpdatePropsUI()
			Case M_SELECTNONE
				If editor.exp_toolbar.mode = MODE_EDIT
					TSelection.ClearSelected (editor.world.EntityList)
				ElseIf editor.exp_toolbar.mode = MODE_COLLISION
					TSelection.ClearSelected (editor.world.Polys)
				EndIf
				RedrawGadget( editor.window )
				editor.exp_options.UpdatePropsUI()
			'view
			Case M_RESETVIEW
				editor.world.ResetView()
				RedrawGadget( editor.window )
			Case M_XYAXIS
				If xySwitch = False
					xySwitch = True
					SetGadgetText( view_axis, "Hide Border" )
				Else
					xySwitch = False
					SetGadgetText( view_axis, "Show Border" )
				EndIf
				UpdateWindowMenu( editor.window )
				RedrawGadget( editor.window )
			Case M_SHOWGRID
				If gridSwitch = False
					gridSwitch = True
					SetGadgetText( view_grid, "Hide Grid" )
				Else
					gridSwitch = False
					SetGadgetText( view_grid, "Show Grid" )
				EndIf
				UpdateWindowMenu( editor.window )
				RedrawGadget( editor.window )
			Case M_GRIDSIZE
				editor.window_gridSize.Show()
			'help
			Case M_ABOUT
				editor.window_about.Show()
			Case M_HELPUSER
				OpenURL ("http://scope2d.com/docs.html")
			Default
			End Select
	End Method
	
'--------------------------------------------------------------------------
' * Disable Menu
'--------------------------------------------------------------------------
	Method Disable()
		DisableMenu( file )
		DisableMenu( edit )
		DisableMenu( view )
		UpdateWindowMenu( editor.window )
	End Method
	
	Method Enable()
		EnableMenu( file )
		EnableMenu( edit )
		EnableMenu( view )
		UpdateWindowMenu( editor.window )
	End Method	
	
End Type