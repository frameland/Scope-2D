'--------------------------------------------------------------------------
' * Manage SceneFiles: Load/Save
'--------------------------------------------------------------------------
Type SceneFile
	
	Global _instance:SceneFile
	Field templateSprite:TEntity = New TEntity
	Field templateProp:SceneProperty = New SceneProperty
	Field lineNr:Int = 2
	Field currentlyOpened:String
	
'--------------------------------------------------------------------------
' * Singleton
'--------------------------------------------------------------------------
	Function Instance:SceneFile()
		If Not _instance
			_instance = New SceneFile
		EndIf
		Return _instance
	End Function
	

'--------------------------------------------------------------------------
' * Show File requester and then call Load()
'--------------------------------------------------------------------------
	Method Open( path:String = "" )
		If path = "" Then
			path = RequestFile("Please Choose a SceneFile ...", ":css", False, MapWorkingDir)
		EndIf
		If path Then
			If Not LoadCss ( path )
				path = ""
				currentlyOpened = ""
				Return
			EndIf
		EndIf
		currentlyOpened = path
		Local prop:SceneProperty
		If (SceneProperty.List.Count() > 1)
			prop = SceneProperty (SceneProperty.List.First())
			If (GadgetText (prop.labelProperty) = "") prop.Remove()
		EndIf
		
		'Hack to update View
		TEditor.GetInstance().exp_canvas.OnWindowResize(TEditor.GetInstance())
		TEditor.GetInstance().world.gfxChooseWorld.OnResize()
		
	End Method
	

'--------------------------------------------------------------------------
' * Load
'--------------------------------------------------------------------------
	Method LoadCss:Byte (path:String)
		Local file:ConfigFile = New ConfigFile
		file.Load (path)
		If Not TEditor.GetInstance().world.NewScene()
			Return False
		EndIf

		Local general:CssBlock = file.GetBlock ("General")
		If Not general
			AppTitle = "Couldn't load map " + path + "."
			Notify "It is not well formated."
			Return False
		EndIf
		Local world:EditorWorld = TEditor.GetInstance().world
		world.size.Set (general.GetInt("Width"), general.GetInt("Height"))
		world.SetMaxLayers (general.GetInt("Layers"))
		
		Local props:CssBlock = file.GetBlock ("Properties")
		If props
			Local propWindow:ScenePropertyWindow = TEditor.GetInstance().window_SceneProps
			Local key:String
			For key = EachIn props.Properties.Keys()
				propWindow.AddPropertyWithValue (key, props.Get (key))
			Next
		EndIf
		
		Local block:CssBlock
		For block = EachIn file.Blocks.Values()
			If block.id.StartsWith ("sprite")
				CreateSpriteCss (block)
			EndIf
		Next
		
		Return True
	End Method

	Method CreateSpriteCss (data:CssBlock)
		Local entity:TEntity = New TEntity
		Local prop:String
		For prop = EachIn data.Properties.Keys()
			Select prop
				Case "name"
					entity.name = data.Get ("name")
				Case "x"
					entity.position.x = data.GetInt ("x")
				Case "y"
					entity.position.y = data.GetInt ("y")
				Case "image"
					entity.SetImage (GfxWorkingDir + data.Get ("image"))
				Case "scalex"
					entity.scale.sx = data.GetFloat ("scalex", 1.0)
				Case "scaley"
					entity.scale.sy = data.GetFloat ("scaley", 1.0)
				Case "flipX"
					entity.flipH = data.GetInt ("flipX")
				Case "flipY"
					entity.flipV = data.GetInt ("flipY")
				Case "rotation"
					entity.rotation = data.GetFloat ("rotation")
				Case "alpha"
					entity.color.a = data.GetFloat ("alpha", 1.0)
				Case "red"
					entity.color.r = data.GetInt ("red", 255)
				Case "green"
					entity.color.g = data.GetInt ("green", 255)				
				Case "blue"
					entity.color.b = data.GetInt ("blue", 255)
				Case "layer"
					entity.layer = data.GetInt ("layer", 1)
				Case "parallax"
					entity.parallax = data.GetInt ("parallax", 0)
				Default
			End Select
		Next
		TEditor.GetInstance().world.AddEntity (entity)
	End Method
	
	
'--------------------------------------------------------------------------
' * Save SceneFile: If file already exist it gets overwritten
'--------------------------------------------------------------------------
	Method Save()
		Local name:String
		If (currentlyOpened = "")
			name = RequestFile( "Name your file ...",, True, MapWorkingDir)
			If name = "" Then Return
		Else
			name = currentlyOpened
		EndIf
		name = NameCssFile (name)
		currentlyOpened = name
		WriteCssFile( name )
	End Method

	Method SaveAs()
		Local name:String
		name = RequestFile( "Name your file ...",, True, MapWorkingDir)
		If name = "" Then Return
		name = NameCssFile (name)
		currentlyOpened = name
		WriteCssFile( name )
	End Method
	
	Method NameCssFile:String (name:String)
		name = StripExt (name)
		name = name + ".css"
		Return name
	End Method
	
	Method NameXmlFile:String (name:String)
		name = StripExt (name)
		name = name + ".xml"
		Return name
	End Method
	
	
'--------------------------------------------------------------------------
' * Write Css SceneFile to disk
' * Only saves what's different from standard values
'--------------------------------------------------------------------------
	Method WriteCssFile (fileName:String)
		Local world:EditorWorld = TEditor.GetInstance().world
		Local stream:TStream = WriteStream( fileName )
		If Not stream
			RuntimeError ("Could not open filesetream " + fileName + " to save map to disk.")
		EndIf

		stream.WriteString (GetSceneProperties() + "~n")
		
		Local sc:String = ";"
		Local text:String
		Local entity:TEntity
		Local i:Int
		Local layerCounter:Int
		
		'Sprites
		For layerCounter = 1 To world.MAX_LAYERS
			For entity = EachIn Self.GetSprites()
				If (entity.layer <> layerCounter) Continue 
				i:+1
				stream.WriteString( "sprite" + i + "{" )
				Local p:Int
				If entity.position.x <> 0.0 Then stream.WriteString( "x:" + Int(entity.position.x) + sc)
				If entity.position.y <> 0.0 Then stream.WriteString( "y:" + Int(entity.position.y) + sc)
				p = String(entity.scale.sx).Find(".")
				If entity.scale.sx <> 1.0 	Then stream.WriteString( "scalex:" + String(entity.scale.sx)[..p+3] + sc)
				p = String(entity.scale.sy).Find(".")
				If entity.scale.sy <> 1.0 	Then stream.WriteString( "scaley:" + String(entity.scale.sy)[..p+3] + sc)
				p = String(entity.rotation).Find(".")
				If entity.rotation <> 0.0 	Then stream.WriteString( "rotation:" + String(entity.rotation)[..p+3] + sc)
				p = String(entity.color.a).Find(".")
				If entity.color.a <> 1.0 	Then stream.WriteString( "alpha:" + String(entity.color.a)[..p+3] + sc)
				If entity.color.r <> 255	Then stream.WriteString( "red:" + entity.color.r + sc)
				If entity.color.g <> 255	Then stream.WriteString( "green:" + entity.color.g + sc)
				If entity.color.b <> 255	Then stream.WriteString( "blue:" + entity.color.b + sc)
				
				If entity.flipH 			Then stream.WriteString( "flipX:" + Int(entity.flipH) + sc)
				If entity.flipV 			Then stream.WriteString( "flipY:" + Int(entity.flipH) + sc)
				If entity.parallax <> 0		Then stream.WriteString( "parallax:" + entity.parallax + sc)
					
				If entity.visible <> 1		Then stream.WriteString( "visible:" + entity.visible + sc )
				If entity.layer > 1 		Then stream.WriteString( "layer:"   + entity.layer + sc )
				If entity.name		 		Then stream.WriteString( "name:"    + entity.name  + sc )

				If entity.texturePath
					If entity.texturePath.StartsWith(GfxWorkingDir) Then
						text = entity.texturePath[GfxWorkingDir.Length..]
					Else
						text = entity.texturePath
					EndIf
					stream.WriteString( "image:" + text + sc )
				EndIf

				stream.WriteString ("}~n")
			Next
		Next
		
		stream.Close()
	End Method
	
	Method GetSceneProperties:String(format:String = "css")
		Local returnString:String
		Local prop:String
		Local val:String
		Local i:SceneProperty
		
		Select format
			Case "css"
				returnString:+ "General{"
				returnString:+ "Width:" + Int (TEditor.GetInstance().world.size.x) + ";"
				returnString:+ "Height:" + Int (TEditor.GetInstance().world.size.y) + ";"
				returnString:+ "Layers:" + TEditor.GetInstance().world.MAX_LAYERS + ";"
				returnString:+ "Sprites:" + GetSprites().Count() + ";"
				returnString:+"}"
				If SceneProperty.size > 1
					returnString = returnString + "~nProperties{"
					For i = EachIn SceneProperty.List
						prop = GadgetText (i.labelProperty)
						If (prop = "Property") Or (prop = "") Continue
						val = GadgetText (i.labelValue)
						returnString = returnString + prop + ":" + val + ";"
					Next
					returnString = returnString + "}"
				EndIf

				Local j:NormalSceneProperty
				For j = EachIn SceneProperty.List
			        prop = GadgetText (j.labelProperty)
			        val = GadgetText (j.labelValue)
			        returnString = returnString + "~n" + prop + "{value:" + val + ";}"
				Next
				
			Case "xml"
				returnString:+ "<General>~n"
				returnString:+ "<Width>" + Int (TEditor.GetInstance().world.size.x) + "</Width>"
				returnString:+ "<Height>" + Int (TEditor.GetInstance().world.size.y) + "</Height>"
				returnString:+ "<Layers>" + TEditor.GetInstance().world.MAX_LAYERS + "</Layers>"
				returnString:+ "<Sprites>" + GetSprites().Count() + "</Sprites>"
				returnString:+ "~n</General>"
				If SceneProperty.size > 1
					returnString = returnString + "~n<Properties>~n"
					For i = EachIn SceneProperty.List
						prop = GadgetText (i.labelProperty)
						If (prop = "Property") Or (prop = "") Continue
						val = GadgetText (i.labelValue)
						returnString = returnString + "<" + prop + ">" + val + "</" + prop + ">"
					Next
					returnString = returnString + "~n</Properties>"
				EndIf

				Local j:NormalSceneProperty
				For j = EachIn SceneProperty.List
			        prop = GadgetText (j.labelProperty)
			        val = GadgetText (j.labelValue)
			        returnString = returnString + "~n<" + prop + ">" + val + "</" + prop + ">"
				Next
			Default
		End Select
		
		Return returnString
	End Method
	
	Method ExportAsXml()
		Local name:String
		name = RequestFile( "Name your file ...",, True, MapWorkingDir)
		name = NameXmlFile(name)
		If name = "" Then Return

		Local world:EditorWorld = TEditor.GetInstance().world
		Local stream:TStream = WriteStream(name)
		If Not stream
			RuntimeError ("Could not open filesetream " + name + " to export map to disk.")
		EndIf

		stream.WriteString (GetSceneProperties("xml") + "~n")
		
		Local text:String
		Local entity:TEntity
		Local i:Int
		Local layerCounter:Int
		
		'Sprites
		For layerCounter = 1 To world.MAX_LAYERS
			For entity = EachIn Self.GetSprites()
				If (entity.layer <> layerCounter) Continue 
				i:+1
				stream.WriteString( "<sprite>~n")
				Local p:Int
				If entity.position.x <> 0.0 Then stream.WriteString( "<x>" + Int(entity.position.x) + "</x>")
				If entity.position.y <> 0.0 Then stream.WriteString( "<y>" + Int(entity.position.y) + "</y>")
				p = String(entity.scale.sx).Find(".")
				If entity.scale.sx <> 1.0 	Then stream.WriteString( "<scalex>" + String(entity.scale.sx)[..p+3] + "</scalex>")
				p = String(entity.scale.sy).Find(".")
				If entity.scale.sy <> 1.0 	Then stream.WriteString( "<scaley>" + String(entity.scale.sy)[..p+3] + "</scaley>")
				p = String(entity.rotation).Find(".")
				If entity.rotation <> 0.0 	Then stream.WriteString( "<rotation>" + String(entity.rotation)[..p+3] + "</rotation>")
				p = String(entity.color.a).Find(".")
				If entity.color.a <> 1.0 	Then stream.WriteString( "<alpha>" + String(entity.color.a)[..p+3] + "</alpha>")
				If entity.color.r <> 255	Then stream.WriteString( "<red>" + entity.color.r + "</red>")
				If entity.color.g <> 255	Then stream.WriteString( "<green>" + entity.color.g + "</green>")
				If entity.color.b <> 255	Then stream.WriteString( "<blue>" + entity.color.b + "</blue>")
				
				If entity.flipH 			Then stream.WriteString( "<flipX>" + Int(entity.flipH) + "</flipX>")
				If entity.flipV 			Then stream.WriteString( "<flipY>" + Int(entity.flipH) + "</flipY>")
				If entity.parallax <> 0		Then stream.WriteString( "<parallax>" + entity.parallax + "</parallax>")
					
				If entity.visible <> 1		Then stream.WriteString( "<visible>" + entity.visible + "</visible>" )
				If entity.layer > 1 		Then stream.WriteString( "<layer>"   + entity.layer + "</layer>" )
				If entity.name		 		Then stream.WriteString( "<name>"    + entity.name  + "</name>" )

				If entity.texturePath
					If entity.texturePath.StartsWith(GfxWorkingDir) Then
						text = entity.texturePath[GfxWorkingDir.Length..]
					Else
						text = entity.texturePath
					EndIf
					stream.WriteString( "<image>" + text + "</image>" )
				EndIf

				stream.WriteString ("~n</sprite>~n")
			Next
		Next
		
		stream.Close()
	End Method


'--------------------------------------------------------------------------
' * Getters
'--------------------------------------------------------------------------
	Method GetSprites:TList()
		Local sprites:TList = New TList
		Local e:TEntity
		For e = EachIn TEditor.GetInstance().world.EntityList
			sprites.AddLast (e)
		Next
		Return sprites
	End Method
	
End Type






















'--------------------------------------------------------------------------
' * Configfile
'--------------------------------------------------------------------------
Type ConfigFile
	
	Field Blocks:TMap '<String,CssBlock>
	
	Method New()
		checkingProperties = False
		Blocks = New TMap
	End Method
	
	Method Load (path:String)
		Local file:String = LoadString (path)
		file = " " + file
		If file = "" Then Throw ("FileHandler: CssFileHandler.Load: File " + path + " could not be loaded!")
		
		Local startIndex:Int
		Local endIndex:Int
		Local name:String
		Local props:String
		Local match:Int

		Local prop:String
		Local value:String
		Local block:CssBlock

		While True
			startIndex = MatchChar (file, START_BRACKET, endIndex)
			If (startIndex = -1)
				Exit
			EndIf
			name = file[endIndex+1..startIndex].Trim()
			endIndex = MatchChar (file, END_BRACKET, startIndex)
			If (endIndex = -1)
				Exit
			EndIf
			
			block = New CssBlock
			block.Init (name)
			Blocks.Insert (name, block)
			props = TrimDown(file[startIndex+1..endIndex])
			Local lastIndex:Int = 0
			While True
				match = MatchChar (props, COLON, lastIndex)
				If match = -1
					Exit
				EndIf
				prop = props[lastIndex..match]
				lastIndex = match + 1

				match = MatchChar (props, SEMICOLON, lastIndex)
				
				If match = -1
					Exit
				EndIf
				value = props[lastIndex..match]
				lastIndex = match + 1
				block.SetKeyAndValue (prop, value)
			Wend
			
		Wend
	End Method

	Method Get:String (selector:String, prop:String)
		Return CssBlock (Blocks.ValueForKey (selector)).Get (prop)
	End Method
	
	Method Exists:Int (selector:String)
		Return Blocks.Contains (selector)
	End Method
	
	Method GetBlock:CssBlock (selector:String)
		Return CssBlock (Blocks.ValueForKey (selector))
	End Method
	
	Field checkingProperties:Byte
	
	Const START_BRACKET:Int = 123
	Const END_BRACKET:Int   = 125
	Const SEMICOLON:Int     = 59
	Const NEWLINE:Int       = 10
	Const WHITESPACE:Int    = 32
	Const TAB:Int           = 9
	Const COLON:Int         = 58
	
End Type



'--------------------------------------------------------------------------
' * An element of a Css File
'--------------------------------------------------------------------------
Type CssBlock
	
	Field id:String
	Field Properties:TMap
	
	Method Init (id:String)
		Self.id = id
		Properties = New TMap
	End Method
	
	Method SetKeyAndValue (key:String, value:String)
		Properties.Insert (key, value)
	End Method
	
	Method Get:String (propName:String)
		Return String (Properties.ValueForKey (propName))
	End Method
	
	Method GetInt:Int (propName:String, defaultValue:Int = 0)
		Local result:Int = String (Properties.ValueForKey (propName)).ToInt()
		If IsNan (result)
			Return defaultValue
		EndIf
		Return result
	End Method
	
	Method GetFloat:Float (propName:String, defaultValue:Float = 0.0)
		Local result:Float = String (Properties.ValueForKey (propName)).ToFloat()
		If IsNan (result)
			Return defaultValue
		EndIf
		Return result
	End Method
	
	Method GetArray:String[] (propName:String, delimiter:String = ",")
		Local value:String = String (Properties.ValueForKey (propName))
		If value = ""
			Return New String[1]
		EndIf
		Local arr:String[] = value.Split (delimiter)
		For Local i:Int = 0 Until arr.Length
			arr[i] = arr[i].Trim()
		Next
		Return arr
	End Method
	
	Method Contains:Int (propName:String)
		Return Properties.Contains (propName)
	End Method
	
	Method ToString:String()
		Local lineBreak:Byte = True
		Local buffer:String = id + "{"
		Local text:String
		For text = EachIn Properties.Keys()
			If lineBreak
				buffer:+ "~n~t" + text + ":" + String(Properties.ValueForKey(text)) + ";"
			Else
				buffer = buffer + text + ":" + String(Properties.ValueForKey(text)) + ";"
			EndIf
		Next
		If lineBreak Then buffer:+"~n"
		buffer = buffer + "}~n"
		Return buffer
	End Method
	
EndType



Function MatchChar:Int (text:String, char:Int, startPos:Int)
	For Local i:Int = startPos Until text.Length
		If text[i] = char
			Return i
		EndIf
	Next
	Return -1
End Function

Function TrimDown:String (text:String)
	Local newText:String
	newText = text.Trim()
	newText = newText.Replace ("~n", "")
	newText = newText.Replace ("~t", "")
	Return newText
End Function
