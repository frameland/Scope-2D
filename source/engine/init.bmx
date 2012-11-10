'------------------------------------------------------------------------------
' Start the core-services of the engine
'------------------------------------------------------------------------------
Function StartEngine()
	SeedRnd( Millisecs() )
	SetupGraphics( 800,600 )
	AutoMidhandle True
	InitFixedTiming()
EndFunction


'------------------------------------------------------------------------------
' Display Type
'------------------------------------------------------------------------------
Type TDisplay
	
	Field graphics_object:TGraphics
	
	Field width:Int
	Field height:Int
	Field depth:Int
	Field hertz:Int
	Field flags:Int
	Field fullscreen:Int
	Field sync:Int
	
	Field number_of_res:Int = 5
	Field WantedWidth:Int[5]
	Field WantedHeight:Int[5]
	
	Field STD_GFX_DRIVER:String = "OpenGL"
	Field STD_WINDOWS_DRIVER:String = "DirectX9" 'DirectX7,DirectX9,OpenGL
	Field GFX_DRIVER:String
	Field GFX_DRIVER_FLAGS:Int = GRAPHICS_BACKBUFFER 
	

'------------------------------------------------------------------------------
' A new TDisplay automatically sets it's GraphicsDriver
' See the above STD_ and GFX_ variables
'------------------------------------------------------------------------------	
	Method New()
		?Win32
			GFX_DRIVER = STD_WINDOWS_DRIVER
			If GFX_DRIVER = "DirectX9"
				SetGraphicsDriver( D3D7Max2DDriver(), GFX_DRIVER_FLAGS )
			ElseIf GFX_DRIVER = "DirectX7"
				SetGraphicsDriver( D3D9Max2DDriver(), GFX_DRIVER_FLAGS )
			ElseIf GFX_DRIVER = "OpenGL"
				GlShareContexts()
				SetGraphicsDriver( GLMax2DDriver(), GFX_DRIVER_FLAGS )
			EndIf
		?Not Win32
			GFX_DRIVER = STD_GFX_DRIVER
			GlShareContexts()
			SetGraphicsDriver( GLMax2DDriver(), GFX_DRIVER_FLAGS )
		?
	EndMethod
	

'------------------------------------------------------------------------------
' Close current Display
'------------------------------------------------------------------------------
	Method Close()
		CloseGraphics( graphics_object )
		DisablePolledInput()
	EndMethod
	
	
'------------------------------------------------------------------------------
' Sets the display to the given values
'------------------------------------------------------------------------------	
	Method Setup( width:Int = 800, height:Int = 600, depth:Int = 0,..
	hertz:Int = 60, flags:Int = 0 )
		If (graphics_object)
			Close()
		EndIf
		If (depth) Then fullscreen = True
		If GraphicsModeExists( width, height, depth, hertz )
			graphics_object = CreateGraphics( width, height, depth, hertz, flags )
			If graphics_object
				SetGraphics( graphics_object )
				EnablePolledInput()
				Return
			Else
				DebugLog( "The graphics Object could not be created.~n" +..
				"Trying to set another Mode ..." )
			EndIf
		Else
			DebugLog( "The specified Graphics-Mode is not available.~n" +..
			"Trying to set another Mode ..." )
		EndIf
		Set( fullscreen )
	EndMethod
	

'------------------------------------------------------------------------------
' Takes into account all WantedResolution's and sets the Mode accordingly
'------------------------------------------------------------------------------
	Method Set( fullscreen:Int = False )
		Local mode:TGraphicsMode
		Local i:Int
		Local depth:Int
		For mode = EachIn Supported() 'Look if there is a Mode which was set wanted
			For i = 0 Until number_of_res
				If WantedWidth[i] = mode.width
					If (WantedHeight[i] = mode.height)
						If (fullscreen)
							If (GraphicsModeExists( mode.width, mode.height, 32, mode.hertz ))
								depth = 32
							ElseIf (GraphicsModeExists( mode.width, mode.height, 24, mode.hertz ))
								depth = 24
							EndIf
						Else
							depth = 0
						EndIf
						graphics_object = CreateGraphics( mode.width, mode.height,..
						depth, mode.hertz, 0 )
						If graphics_object
							If (depth) Then fullscreen = True
							SetGraphics( graphics_object )
							EnablePolledInput()
							Return
						EndIf
					EndIf
				EndIf
			Next
		Next
		For mode = EachIn Supported() 'If not set the the first best mode you encounter
			If (fullscreen)
				If (GraphicsModeExists( mode.width, mode.height, 32, mode.hertz ))
					depth = 32
				ElseIf (GraphicsModeExists( mode.width, mode.height, 24, mode.hertz ))
					depth = 24
				EndIf
			EndIf
			graphics_object = CreateGraphics( mode.width, mode.height,..
			depth, mode.hertz, 0 )
			If graphics_object
				If (depth) Then fullscreen = True
				SetGraphics( graphics_object )
				EnablePolledInput()
				Return
			EndIf
		Next
	EndMethod
	

'------------------------------------------------------------------------------
' 
'------------------------------------------------------------------------------
	Method GoFullscreen()
		If (fullscreen)
			Setup( width,height,0,hertz,flags)
		Else
			If (GraphicsModeExists( width, height, 32, hertz ))
				Setup( width,height,32,hertz,flags )
			ElseIf (GraphicsModeExists( width, height, 24, hertz ))
				Setup( width,height,24,hertz,flags )
			EndIf
		EndIf
	EndMethod
	
	
'------------------------------------------------------------------------------
' If you want specific resolutions set them with this function
' Be aware that Set() automatically sets the higher resolution
'------------------------------------------------------------------------------	
	Method InsertWantedResolution( width:Int, height:Int )
		Global counter:Int = 0
		If (counter > number_of_res-1)
			DebugLog( "TDisplay: If you want to use more resolutions increase the value of number_of_res (also the arrays WantedWidth/Height)!" )
			Return
		EndIf
		WantedWidth[counter]  = width
		WantedHeight[counter] = height
		counter:+ 1
	EndMethod
	

'------------------------------------------------------------------------------
' Returns supported Graphics-Modes as a TList
'------------------------------------------------------------------------------
	Method Supported:TList()
		Return TList.FromArray( GraphicsModes() )
	EndMethod
	
EndType
