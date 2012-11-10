'------------------------------------------------------------------------------
' Draws a non-filled Rect with an optional outline-thickness
'------------------------------------------------------------------------------
Function DrawRect2( x:Int, y:Int, w:Int, h:Int, thickness:Int = 1 )
	DrawRect x+thickness,y,w-thickness-thickness,thickness
	DrawRect x+thickness,h+y-thickness,w-thickness-thickness,thickness
	DrawRect x,y,thickness,h
	DrawRect x+w-thickness,y,thickness,h
EndFunction

'------------------------------------------------------------------------------
' Sets color, alpha, blend, rotation and scale to normal
'------------------------------------------------------------------------------
Function ResetDrawing()
	SetColor 255,255,255
	SetAlpha 1.0
	SetBlend ALPHABLEND
	SetRotation( 0.0 )
	SetScale( 1.0, 1.0 )
EndFunction


'------------------------------------------------------------------------------
' Overrides the default image-loading functions
' Throws an Error in Debug-Mode if loaded image = Null 
'------------------------------------------------------------------------------
Function LoadImage2:TImage( url:Object, flags:Int = -1 )
	Local gc:TMax2DGraphics = TMax2DGraphics.Current()
	If (flags = -1) Then flags = gc.auto_imageflags
	Local image:TImage = TImage.Load( url, flags, gc.mask_red, gc.mask_green, gc.mask_blue )
	?debug
	If Not image
		RuntimeError( "TImage from " + url.ToString() + "could not be loaded!" )
	EndIf
	?
	If gc.auto_midhandle Then MidHandleImage image
	Return image
End Function

Function LoadAnimImage2:TImage( url:Object, cell_width:Int, cell_height:Int, first_cell:Int, cell_count:Int, flags:Int = -1 )
	Local gc:TMax2DGraphics = TMax2DGraphics.Current()
	If (flags = -1) Then flags = gc.auto_imageflags
	Local image:TImage=TImage.LoadAnim( url, cell_width, cell_height, first_cell, cell_count, flags, gc.mask_red, gc.mask_green, gc.mask_blue )
	?debug
	If Not image
		RuntimeError( "TImage from " + url.ToString() + "could not be loaded!" )
	EndIf
	?
	If gc.auto_midhandle Then MidHandleImage image
	Return image
End Function


'--------------------------------------------------------------------------
' * Kind of TileImage Function just with boundaries
'--------------------------------------------------------------------------
Function TiledFill( image:TImage, cam:TCamera, rows:Int, columns:Int, startX:Int, startY:Int, endX:Int, endY:Int )
	Local x:Int
	Local y:Int
End Function

