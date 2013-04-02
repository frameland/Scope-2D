Type ExpCanvas Extends TEditorExpansion
	
	Field canvas:TGadget
	Field world:EditorWorld

'--------------------------------------------------------------------------
' * Initialize the canvas
'--------------------------------------------------------------------------	
	Method Init( editor:TEditor )
		SetGraphicsDriver GLMax2DDriver()
		canvas = CreateCanvas( 0,0,CANVAS_WIDTH,CANVAS_HEIGHT,editor.window )
		SetGadgetLayout canvas,1,1,1,1
		Local sep:TGadget = CreateLabel("",CANVAS_WIDTH,0,1,CANVAS_HEIGHT,editor.window,LABEL_SEPARATOR)
		SetGadgetLayout sep, 0, 1, 1, 1
		SetGraphics CanvasGraphics( canvas )
		SetClsColor 250,250,250
		world = editor.world
		world.Init()
	EndMethod

'--------------------------------------------------------------------------
' * Resize Canvas properly to the window
'--------------------------------------------------------------------------
	Method OnWindowResize( editor:TEditor )
		SetGadgetShape( canvas, 0, 0, CANVAS_WIDTH, CANVAS_HEIGHT )
		SetGraphics CanvasGraphics( canvas )
		SetGadgetLayout canvas, 1, 1, 1, 1
		Render()
	End Method

'--------------------------------------------------------------------------
' * Render all sprites in the world
'--------------------------------------------------------------------------
	Method Render()
		Cls()
		SetViewport( 0, 0, canvas.width, canvas.height )
		SetOrigin( 0, 0 )
		ResetDrawing()
		world.Render()
		Flip 1
	End Method
	
End Type