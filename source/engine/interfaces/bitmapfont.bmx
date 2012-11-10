Private
Global global_bitmap_font:TBitmapFont


Public
'------------------------------------------------------------------------------
' Sets the font which DrawBitmapText will use
'------------------------------------------------------------------------------
Function SetGlobalBitmapFont( font:String, size:Int, forceCreation:Int = False )
	Local image_font:TImageFont = LoadImageFont( font, size )
	If Not image_font Then Throw( "Could not load global image-font!" )
	global_bitmap_font = New TBitmapFont
	Local file:String = Left( font, font.length-4 )
	If Not FileType( file ) Or forceCreation
		global_bitmap_font.Create( image_font, file  )
	EndIf
	global_bitmap_font.Load( file )
EndFunction


'------------------------------------------------------------------------------
' Uses the global BitmapFont to draw Text to Screen
'------------------------------------------------------------------------------
Function DrawBitmapText( text:String, x:Float, y:Float, center:Int = False, laufweite:Float = 1.0 )
	If Not global_bitmap_font
		DebugLog( "Could not draw the text ~q" + text + "~q!~nCall SetGlobalBitmapFont(..) first.~n" )
		Return
	EndIf
	global_bitmap_font.Draw( text, x, y, center, laufweite )
EndFunction



'------------------------------------------------------------------------------
' Enables you to draw Text to the screen as TImage
' This code is taken from the Horizon Framework and modified just a bit
' (added documentation, an error check + AutoMidHandle is
' replaced with SetImageHandle)
' All credit goes to the original author
'------------------------------------------------------------------------------
' How to use:
'------------------------------------------------------------------------------
' Local MyFont:TImageFont = LoadImageFont( "Arial.ttf", 16 )
' Local BitFont:TBitmapFont = New TBitmapFont
' BitFont.Create( MyFont, "FontFile" )
' BitFont.Load( "FontFile" )
'------------------------------------------------------------------------------
Type TBitmapFont
	
	Field FontImage:TImage
	Field CharW:Int[255], CharH:Int[255]	
	Field FrameWidth:Int, FrameHeight:Int


'------------------------------------------------------------------------------
' Loads the bitmap of the font
' You have to setup a graphics-context before calling this Method
'------------------------------------------------------------------------------
	Method Load(File:String)
		Local Infostream:TStream = ReadFile(File)
		If (Infostream)
			Local s:String = File+".png"
			Local w:Int = ReadInt(Infostream)
			Local h:Int = ReadInt(Infostream)
			Local f:Int = ReadInt(Infostream) ' Frames
			FrameWidth = w-32
			FrameHeight = h-32
			FontImage = LoadAnimImage(s,w,h,0,f)
			SetImageHandle( FontImage, 0, 0 )
			For Local i:Int=31 To 255
				CharW[i-31] = ReadInt(Infostream)
				CharH[i-31] = ReadInt(Infostream)
			Next	
		Else
			RuntimeError("File " + File + "couldn't be loaded!")	
		EndIf
	End Method
	

'------------------------------------------------------------------------------
' Renders Text to the screen
' center: Aligns the text to the center
' laufweite: Space between the letters
'------------------------------------------------------------------------------	
	Method Draw(t:String,x:Float, y:Float, center:Byte = False, laufweite:Float = 1.0)
		x:-16
		y:-16
		If (FontImage)
			Local offx:Int = 0
			Local charNo:Int
			Local i:Int
			If (center)
				Local w:Int = 0, h:Int = 0
				For i = 1 To t.length
					charNo = Asc(Mid(t,i,1))-31
					If (charNo >= CharW.length Or charNo < 0) Then Continue
					w:+(laufweite*CharW[charNo])
					If CharH[Asc(Mid(t,i,1))-31]>h Then h=CharH[Asc(Mid(t,i,1))-31]
				Next
				x:-(w/2)
				y:-(h/2)
			EndIf
			For i = 1 To t.length
				charNo = Asc(Mid(t,i,1))-31
				If (charNo >= CharW.length Or charNo < 0) Then Continue
				DrawImage (FontImage,x+offx,y,charNo)
				offx:+(laufweite*CharW[charNo])		
			Next
			Return
		EndIf
		Throw( "There is no font loaded for this BitmapFont (" + t + ") !" )
	End Method
	

'------------------------------------------------------------------------------
' Returns the width of this text
'------------------------------------------------------------------------------	
	Method GetWidth:Int(t:String)
		If (FontImage)
			Local offx:Int = 0			
			Local w:Int = 0
			For Local i:Int = 1 To t.length
				w:+CharW[Asc(Mid(t,i,1))-31]
			Next
			Return w			
		EndIf
	End Method	
	

'------------------------------------------------------------------------------
' Creates a file from the specified TImageFont. This file can then be loaded
' by the Load Method()
' File: name for the output-file
'------------------------------------------------------------------------------	
	Method Create(FromFont:TImageFont, File:String)
		SetImageFont FromFont	
		Local width:Float = 0, height:Float = 0
		FrameWidth = 0
		FrameHeight = 0
		Local i:Int
		For i = 31 To 255
			CharW[i-31] = TextWidth(Chr(i))+32
			CharH[i-31] = TextHeight(Chr(i))+32
			
			If (CharW[i-31]>FrameWidth) Then FrameWidth=CharW[i-31]
			If (CharH[i-31]>FrameHeight) Then FrameHeight=CharH[i-31]
			
			If (CharH[i-31]>height) Then height=CharH[i-31]
			width:+CharW[i-31]			
		Next
		If (FrameWidth>FrameHeight) Then FrameHeight=FrameWidth
		If (FrameHeight>FrameWidth) Then FrameWidth=FrameHeight
		Local offx:Int = 1
		Local offy:Int = 1
		Local xpos:Int = 0
		For i = 31 To 255			
			If offx*FrameWidth>6000
				xpos=offx
				offx=0
				offy:+1
			EndIf				
			offx:+1
		Next
		Local pix:TPixmap = CreatePixmap(FrameWidth*xpos,FrameHeight*offy,PF_RGBA8888)
		SetClsColor 0,0,0
		SetColor 255,255,255
		SetBlend(ALPHABLEND)
		offx=0		
		offy=0
		For i=31 To 255		
			CharW[i-31]:-32
			CharH[i-31]:-32
			If offx>6000
				offx=0
				offy:+FrameHeight
			EndIf
			Cls
			DrawText Chr(i),16,16
			Local s:String=Chr(i)
			Local charpixmap:TPixmap = CreatePixmap(FrameWidth,FrameHeight,PF_RGBA8888)
			charpixmap = GrabPixmap(0,0,FrameWidth, FrameHeight)
			For Local x:Int=0 To FrameWidth-1
				For Local y:Int=0 To FrameHeight-1
					Local pixel:Int = ReadPixel(charpixmap,x,y)
					pixel = (((pixel Shr 16) & $ff) Shl 24) | (255 Shl 16) | (255 Shl 8) | (255 & $ff)
					If PixmapWidth(pix)>offx And PixmapHeight(pix)>y+offy
						WritePixel(pix,offx,offy + y,pixel)
						If i=255
							pixel = $FF00FF00
							WritePixel(pix,offx,offy+y,pixel)
						EndIf
					EndIf
				Next
				offx:+1
			Next
		Next
		SavePixmapPNG(pix,File + ".png", 9)
		Local Infostream:TStream = WriteFile(File)
		If Infostream
			WriteInt(Infostream,FrameWidth)
			WriteInt(Infostream,FrameHeight)
			WriteInt(Infostream,224) ' Frames
			For i=31 To 255
				WriteInt(Infostream, CharW[i-31])
				WriteInt(Infostream, CharH[i-31])
			Next
			CloseFile(Infostream)
		EndIf
	End Method
	
End Type
