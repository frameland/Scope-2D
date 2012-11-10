'--------------------------------------------------------------------------
' * Manage SceneFiles: Load/Save
'--------------------------------------------------------------------------
Type SceneFile
	
	Global _instance:SceneFile
	Field templateSprite:TEntity = New TEntity
	Field templatePoly:Int[8]
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
			If Not Load( path )
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
	End Method
	
	
'--------------------------------------------------------------------------
' * Save SceneFile: If file already exist it gets overwritten
'--------------------------------------------------------------------------
	Method Save()
		Local name:String
		If (currentlyOpened = "") Or (FileType(currentlyOpened) <> 1) Then
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
	
'--------------------------------------------------------------------------
' * Write XML SceneFile to disk
' * Only saves what's different from standard values
'--------------------------------------------------------------------------
	Method WriteFile( fileName:String )
		Local world:EditorWorld = TEditor.GetInstance().world
		Local stream:TStream = WriteStream( fileName )
		stream.WriteString( "<Scene>~n" )
		stream.WriteString( GetSceneProperties() )
		Local entity:TEntity
		Local p:Int
		Local text:String
		For entity = EachIn world.EntityList
			stream.WriteString( "~t<Sprite>~n" )
			p = String(entity.position.x).Find(".")
			If entity.position.x <> 0.0 Then stream.WriteString( "~t~t<x>" + String(entity.position.x)[..p] + "</x>~n" )
			p = String(entity.position.y).Find(".")
			If entity.position.y <> 0.0 Then stream.WriteString( "~t~t<y>" + String(entity.position.y)[..p] + "</y>~n" )
			p = String(entity.scale.sx).Find(".")
			If entity.scale.sx <> 1.0 	Then stream.WriteString( "~t~t<scaleX>" + String(entity.scale.sx)[..p+3] + "</scaleX>~n" )
			p = String(entity.scale.sy).Find(".")
			If entity.scale.sy <> 1.0 	Then stream.WriteString( "~t~t<scaleY>" + String(entity.scale.sy)[..p+3] + "</scaleY>~n" )
			p = String(entity.rotation).Find(".")
			If entity.rotation <> 0.0 	Then stream.WriteString( "~t~t<rotation>" + String(entity.rotation)[..p+3] + "</rotation>~n" )
			p = String(entity.color.a).Find(".")
			If entity.color.a <> 1.0 	Then stream.WriteString( "~t~t<alpha>" + String(entity.color.a)[..p+3] + "</alpha>~n" )
			If entity.color.r <> 255	Then stream.WriteString( "~t~t<red>" + entity.color.r + "</red>~n" )
			If entity.color.g <> 255	Then stream.WriteString( "~t~t<green>" + entity.color.g + "</green>~n" )
			If entity.color.b <> 255	Then stream.WriteString( "~t~t<blue>" + entity.color.b + "</blue>~n" )
			If entity.texturePath
				If entity.texturePath.StartsWith(GfxWorkingDir) Then
					text = entity.texturePath[GfxWorkingDir.Length..]
				Else
					text = entity.texturePath
				EndIf
				stream.WriteString( "~t~t<image>" + text + "</image>~n" )
			EndIf
			If entity.visible <> 1		Then stream.WriteString( "~t~t<visible>" + entity.visible + "</visible>~n" )
			If entity.active <> 0 		Then stream.WriteString( "~t~t<active>" + entity.active + "</active>~n" )
			If entity.layer > 1 		Then stream.WriteString( "~t~t<layer>" + entity.layer + "</layer>~n" )
			If entity.frame <> 0 		Then stream.WriteString( "~t~t<frame>" + entity.frame + "</frame>~n" )
			If entity.name		 		Then stream.WriteString( "~t~t<name>" + entity.name + "</name>~n" )
			stream.WriteString( "~t</Sprite>~n" )
		Next
		stream.WriteString( "</Scene>")
		stream.Close()
	End Method
	
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
		For entity = EachIn world.EntityList
			i:+1
			stream.WriteString( "sprite" + i + "{" )
			Local p:Int
			If entity.position.x <> 0.0 Then stream.WriteString( "x:" + Int(entity.position.x) + sc)
			If entity.position.y <> 0.0 Then stream.WriteString( "y:" + Int(entity.position.y) + sc)
			p = String(entity.scale.sx).Find(".")
			If entity.scale.sx <> 1.0 	Then stream.WriteString( "scalex:" + String(entity.scale.sx)[..p+3] + sc)
			p = String(entity.scale.sy).Find(".")
			If entity.scale.sy <> 1.0 	Then stream.WriteString( "scaley:" + String(entity.scale.sy)[..p+3] + sc)
			If entity.rotation <> 0.0 	Then stream.WriteString( "rotation:" + Int(entity.rotation) + sc)
			p = String(entity.color.a).Find(".")
			If entity.color.a <> 1.0 	Then stream.WriteString( "alpha:" + String(entity.color.a)[..p+3] + sc)
			If entity.color.r <> 255	Then stream.WriteString( "red:" + entity.color.r + sc)
			If entity.color.g <> 255	Then stream.WriteString( "green:" + entity.color.g + sc)
			If entity.color.b <> 255	Then stream.WriteString( "blue:" + entity.color.b + sc)
			
			If entity.visible <> 1		Then stream.WriteString( "visible:" + entity.visible + sc )
			If entity.active <> 0 		Then stream.WriteString( "active:"  + entity.active  + sc )
			If entity.layer <> 1 		Then stream.WriteString( "layer:"   + entity.layer + sc )
			If entity.frame <> 0 		Then stream.WriteString( "frame:"   + entity.frame + sc )
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
		
		i = 0
		For entity = EachIn world.Polys
			i:+1
			stream.WriteString ("poly" + i + "{data:")
			Local verts:Int[] = entity.GetVertices()
			For Local i:Int = 0 Until verts.Length-1
				stream.WriteString (verts[i] + ",")
			Next
			stream.WriteString (verts[verts.Length-1])
			stream.WriteString (";}~n")
		Next
		
		stream.Close()
	End Method
	
	Method GetSceneProperties:String()
		Local returnString:String = "General{"
		Local prop:String
		Local val:String
		Local i:SceneProperty
		Local j:NormalSceneProperty
		For j = EachIn NormalSceneProperty.List
			prop = GadgetText (j.labelProperty)
			val = GadgetText (j.labelValue)
			returnString = returnString + prop + ":" + val + ";"
		Next
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
		
		Return returnString
	End Method
	

'--------------------------------------------------------------------------
' * Load an xml file (Scene-File) -> uses a handwritten xml-parser
'--------------------------------------------------------------------------	
	Method Load( path:String )
		LoadCss (path)
		Return
		
		'Deprecated
		Rem
		Local xmlString:String = LoadString( path )
		If Not xmlString Then Throw "Could not find the xml file " + path + " you wanted to load!"
		If Not TEditor.GetInstance().world.NewScene()
			Return
		EndIf
		Local header:String = "<Scene>"
		Local lastLine:String = "</Scene>"
		xmlString = xmlString[header.Length..xmlString.Length-lastLine.Length]
		Local file:String[] = xmlString.Split("~n")
		Local index:Int = 0
		Local i:Int
		Local name:String
		Local line:String
		Local isCreating:Int = False
		Local typeOfSprite:String
		For line = EachIn file
			If line = "" Then Continue 'empty line
			If line.StartsWith("<!--") 'comment
				If line.EndsWith("-->")
					Continue
				EndIf
				Throw "Invalid comment on line: " + lineNr
			EndIf
			index = line.Find("<")
			i = line.Find(">",index)
			name = line[index+1..i]
			If (index = -1) Or (i = -1) Then Throw "Error with Tags on Line: " + lineNr
			If line.Length <= i+1 'if beginning tag without end tag on same line
				If Not name.StartsWith("/")
					typeOfSprite = name
				Else
					CreateSprite( typeOfSprite )
					typeOfSprite = ""
				EndIf
			Else
				SetValue( line, name, typeOfSprite )
			EndIf
			lineNr =+ 1
		Next
		EndRem
	End Method
	
	Method LoadCss:Byte (path:String)
		Local file:ConfigFile = New ConfigFile
		file.Load (path)
		If Not TEditor.GetInstance().world.NewScene()
			Return False
		EndIf
		
		Local general:CssBlock = file.GetBlock ("General")
		If Not general
			Notify "Couldn't load map " + path + ". It's not well formated."
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
			ElseIf block.id.StartsWith ("poly")
				CreatePolyCss (block)
			EndIf
		Next
		
		Return True
	End Method

	Method CreatePolyCss (data:CssBlock)
		Local array:String[] = data.GetArray ("data")
		Local verts:Int[array.Length]
		For Local i:Int = 0 Until verts.Length
			verts[i] = Int (array[i])
		Next
		Local poly:TEntity = TEditor.GetInstance().world.CreatePoly (False)
		Local sX:Float = DistanceOfPoints (verts[0], verts[1], verts[2], verts[3]) / poly.image.width
		Local sY:Float = DistanceOfPoints (verts[0], verts[1], verts[4], verts[5]) / poly.image.height
		poly.SetScale (sx, sy)
		poly.rotation = AngleOfPoints (verts[0], verts[1], verts[2], verts[3])
		Local x:Float = (verts[0] + verts[2] + verts[4] + verts[6]) / 4.0 + 0.5
		Local y:Float = (verts[1] + verts[3] + verts[5] + verts[7]) / 4.0 + 0.5
		poly.SetPosition (x, y)
	End Method
	
	Method CreateSpriteCss (data:CssBlock)
		Local entity:TEntity = New TEntity
		Local prop:String
		For prop = EachIn data.Properties.Keys()
			Select prop
				Case "x"
					entity.position.x = data.GetInt ("x")
				Case "y"
					entity.position.y = data.GetInt ("y")
				Case "image"
					entity.SetImage (GfxWorkingDir + data.Get ("image"))
				Case "scalex"
					entity.scale.sx = data.GetFloat ("scalex")
				Case "scaley"
					entity.scale.sy = data.GetFloat ("scaley")				
				Case "rotation"
					entity.rotation = data.GetInt ("rotation")
				Case "alpha"
					entity.color.a = data.GetFloat ("alpha")
				Case "red"
					entity.color.r = data.GetInt ("red")
				Case "green"
					entity.color.g = data.GetInt ("green")				
				Case "blue"
					entity.color.b = data.GetInt ("blue")
				Case "layer"
					entity.layer = data.GetInt ("layer")
				Default
			End Select
		Next
		TEditor.GetInstance().world.AddEntity (entity)
	End Method
	
	
'--------------------------------------------------------------------------
' * Private: called from Load()
'--------------------------------------------------------------------------
	Method CreateSprite( typeOfSprite:String )
		Select typeOfSprite
			Case "Sprite"
				Local sprite:TEntity = New TEntity
				sprite.SetImage( templateSprite.texturePath )
				If (Not sprite.image) Return
				sprite.position.x = templateSprite.position.X
				sprite.position.y = templateSprite.position.Y
				sprite.SetScale( templateSprite.scale.sx, templateSprite.scale.sy )
				sprite.rotation = templateSprite.rotation
				sprite.color.r = templateSprite.color.r
				sprite.color.g = templateSprite.color.g
				sprite.color.b = templateSprite.color.b
				sprite.color.a = templateSprite.color.a
				sprite.layer = templateSprite.layer
				sprite.visible = templateSprite.visible
				sprite.active = templateSprite.active
				sprite.name = templateSprite.name
				TEditor.GetInstance().world.AddEntity( sprite )
				'Reset sprite properties
				templateSprite.position.x = 0
				templateSprite.position.y = 0
				templateSprite.scale.sx = 1.0
				templateSprite.scale.sy = 1.0
				templateSprite.rotation = 0.0
				templateSprite.color.r = 255
				templateSprite.color.g = 255
				templateSprite.color.b = 255
				templateSprite.color.a = 1.0
				templateSprite.layer = 1
				templateSprite.texturePath = ""
				templateSprite.image = Null
				templateSprite.visible = True
				templateSprite.active = False
				templateSprite.name = ""
				templateSprite.frame = 0
			Default
				DebugLog "Unknown type of sprite on loading scene: " + typeOfSprite
		End Select
	End Method
	
	Method SetValue( line:String, name:String, typeOfSprite:String )
		line = line.Trim()
		Local i:Int = name.Length
		Local value:String = line[i+2..line.Length-i-3]
		If (typeOfSprite = "Sprite")
			Select name
				Case "x"
					templateSprite.position.x = Float( value )
				Case "y"
					templateSprite.position.y = Float( value )
				Case "scaleX"
					templateSprite.scale.sx = Float( value )
				Case "scaleY"
					templateSprite.scale.sy = Float( value )
				Case "rotation"
					templateSprite.rotation = Float( value )
				Case "alpha"
					templateSprite.color.a = Float( value )
				Case "red"
					templateSprite.color.r = Float( value )
				Case "green"
					templateSprite.color.g = Float( value )
				Case "blue"
					templateSprite.color.b = Float( value )
				Case "image"
					templateSprite.texturePath = GfxWorkingDir + value
				Case "visible"
					templateSprite.visible = Int( value )
				Case "active"
					templateSprite.active = Int( value )
				Case "layer"
					templateSprite.layer = Int( value )
				Case "frame"
					templateSprite.frame = Int( value )
				Case "name"
					templateSprite.name = value
				Default
					DebugLog "Error on loading Scene: Unknown property: " + name
			End Select
		ElseIf (typeOfSprite = "SceneProperty")
			If name = "Property" Return
			TEditor.GetInstance().window_sceneProps.AddPropertyWithValue (name, value)
		ElseIf (typeOfSprite = "NormalProperty")
			NormalSceneProperty.SetValueOfProperty (name, value)
		EndIf
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
