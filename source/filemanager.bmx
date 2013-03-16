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
			ElseIf block.id.StartsWith ("spriteF")
				CreateSpriteCss (block, True)
			ElseIf block.id.StartsWith ("poly")
				CreatePolyCss (block)
			ElseIf block.id.StartsWith ("baseline")
				CreatePolyCss (block, True)
			ElseIf block.id.StartsWith ("trigger")
				CreateTrigger (block)
			ElseIf block.id.StartsWith ("particle")
				CreateTrigger (block, True)
			ElseIf block.id.StartsWith ("savepoint")
				CreateTrigger (block, False)
			EndIf
		Next
		
		Return True
	End Method

	Method CreatePolyCss (data:CssBlock, isBaseline:Byte = False)
		Local array:String[] = data.GetArray ("data")
		Local verts:Int[array.Length]
		For Local i:Int = 0 Until verts.Length
			verts[i] = Int (array[i])
		Next
		Local poly:TEntity = TEditor.GetInstance().world.CreatePoly (False)
		If isBaseline
			poly.isBaseline = True
		EndIf
		Local sX:Float = DistanceOfPoints (verts[0], verts[1], verts[2], verts[3]) / poly.image.width
		Local sY:Float = DistanceOfPoints (verts[0], verts[1], verts[4], verts[5]) / poly.image.height
		poly.SetScale (sx, sy)
		poly.rotation = AngleOfPoints (verts[0], verts[1], verts[2], verts[3]) - 180
		Local x:Float = (verts[0] + verts[2] + verts[4] + verts[6]) / 4.0 + 0.5
		Local y:Float = (verts[1] + verts[3] + verts[5] + verts[7]) / 4.0 + 0.5
		poly.SetPosition (x, y)
		poly.name = data.Get("id")
	End Method
	
	Method CreateSpriteCss (data:CssBlock, isFrontSprite:Byte = False)
		Local entity:TEntity = New TEntity
		If isFrontSprite
			entity.inFront = True
		EndIf
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
				Default
			End Select
			entity.flipH = data.GetInt ("flipX")
			entity.flipV = data.GetInt ("flipY")
		Next
		TEditor.GetInstance().world.AddEntity (entity)
	End Method
	
	Method CreateTrigger (data:CssBlock, isParticle:Byte = False)
		Local event:TEntity = TEditor.GetInstance().world.CreateEvent (False)
		If isParticle
			event.isParticle = True
		EndIf
		If data.id.StartsWith("savepoint")
			event.name = data.id
		EndIf
		Local prop:String
		For prop = EachIn data.Properties.Keys()
			Select prop
				Case "effect"
					event.name = data.Get ("effect")
				Case "id"
					event.name = data.Get ("id")
				Case "x"
					event.position.x = data.GetInt ("x")
				Case "y"
					event.position.y = data.GetInt ("y")
				Case "radius"
					event.scale.sx = data.GetInt ("radius") / Float(event.image.width)
					event.scale.sy = event.scale.sx
				Default
			End Select
		Next
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
		RemoveEmptyScripts()
	End Method

	Method SaveAs()
		Local name:String
		name = RequestFile( "Name your file ...",, True, MapWorkingDir)
		If name = "" Then Return
		name = NameCssFile (name)
		currentlyOpened = name
		WriteCssFile( name )
		RemoveEmptyScripts()
	End Method
	
	Method NameCssFile:String (name:String)
		name = StripExt (name)
		name = name + ".css"
		Return name
	End Method
	
	Method RemoveEmptyScripts()
		If currentlyOpened = ""
		        Return
		EndIf
	
		Local mapDir:String = ExtractDir(currentlyOpened)
		Local onActionDir:String = mapDir + "/on_action/"
		Local onEnterDir:String = mapDir + "/on_enter/"
		Local actionDirContents:String[] = LoadDir(onActionDir)
		Local enterDirContents:String[] = LoadDir(onEnterDir)
	
		Local file:String
		For file = EachIn actionDirContents
		        If file.EndsWith(".script")
		                Local scriptFile:String = LoadString(onActionDir + file)
		                If scriptFile.Length = 0
		                        DeleteFile(onActionDir + file)
		                EndIf
		        EndIf
		Next
		For file = EachIn enterDirContents
		        If file.EndsWith(".script")
		                Local scriptFile:String = LoadString(onEnterDir + file)
		                If scriptFile.Length = 0
		                        DeleteFile(onEnterDir + file)
		                EndIf
		        EndIf
		Next
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
				
				If entity.flipH Then stream.WriteString( "flipX:" + Int(entity.flipH) + sc)
				If entity.flipV Then stream.WriteString( "flipY:" + Int(entity.flipH) + sc)
					
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
		
		'Front Sprites
		i = 0
		For layerCounter = 1 To world.MAX_LAYERS
			For entity = EachIn Self.GetFrontSprites()
				If (entity.layer <> layerCounter) Continue 
				i:+1
				stream.WriteString( "spriteF" + i + "{" )
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
				
				If entity.flipH Then stream.WriteString( "flipX:" + Int(entity.flipH) + sc)
				If entity.flipV Then stream.WriteString( "flipY:" + Int(entity.flipH) + sc)
						
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
		
		'Polys
		i = 0
		Local thePolys:TList = GetPolys()
		For entity = EachIn thePolys
			i:+1
			stream.WriteString ("poly" + i + "{data:")
			Local verts:Int[] = entity.GetVertices()
			For Local i:Int = 0 Until verts.Length-1
				stream.WriteString (verts[i] + ",")
			Next
			stream.WriteString (verts[verts.Length-1])
			If entity.name <> ""
				stream.WriteString (";id:" + entity.name)
			EndIf
			stream.WriteString (";}~n")
		Next
		
		'Baselines
		i = 0
		Local theBaselines:TList = GetBaselines()
		For entity = EachIn theBaselines
			i:+1
			stream.WriteString ("baseline" + i + "{data:")
			Local verts:Int[] = entity.GetVertices()
			For Local i:Int = 0 Until verts.Length-1
				stream.WriteString (verts[i] + ",")
			Next
			stream.WriteString (verts[verts.Length-1])
			If entity.name <> ""
				stream.WriteString (";id:" + entity.name)
			EndIf
			stream.WriteString (";}~n")
		Next
		
		'Triggers
		i = 0
		Local theTriggers:TList = GetTriggers()
		For entity = EachIn theTriggers
			i:+1
			stream.WriteString ("trigger" + i + "{")
			stream.WriteString ("x:" + Int(entity.position.x) + ";")
			stream.WriteString ("y:" + Int(entity.position.y) + ";")
			stream.WriteString ("id:" + entity.name + ";")
			stream.WriteString ("radius:" + Int(entity.scale.sx * entity.image.width) + ";")
			stream.WriteString ("}~n")
		Next
		
		'Particles
		i = 0
		Local theParticles:TList = GetParticles()
		For entity = EachIn theParticles
			If (entity.name = "")
				AppTitle = "Unnamed Particle Effect at position x:" + Int(entity.position.x) + ", y:" + Int(entity.position.y)
				Notify ("Particles must have a name! They have to be named the same as the effect id.")
				Continue
			EndIf
			i:+1
			stream.WriteString ("particle" + i + "{")
			stream.WriteString ("effect:" + entity.name + ";")
			stream.WriteString ("x:" + Int(entity.position.x) + ";")
			stream.WriteString ("y:" + Int(entity.position.y) + ";")
			stream.WriteString ("}~n")
		Next
		
		'Savepoints
		Local theSavepoints:TList = GetSavepoints()
		For entity = EachIn theSavepoints
		        stream.WriteString(entity.name + "{")
		        stream.WriteString ("x:" + Int(entity.position.x) + ";")
		        stream.WriteString ("y:" + Int(entity.position.y) + ";")
				stream.WriteString ("}~n")
		Next
		
		stream.Close()
	End Method
	
	Method GetSceneProperties:String()
		Local returnString:String = "General{"
		Local prop:String
		Local val:String
		Local i:SceneProperty

		returnString:+ "Width:" + Int (TEditor.GetInstance().world.size.x) + ";"
		returnString:+ "Height:" + Int (TEditor.GetInstance().world.size.y) + ";"
		returnString:+ "Layers:" + TEditor.GetInstance().world.MAX_LAYERS + ";"
		returnString:+ "Sprites:" + GetSprites().Count() + ";"
		returnString:+ "SpritesFront:" + GetFrontSprites().Count() + ";"
		returnString:+ "Polys:" + GetPolys().Count() + ";"
		returnString:+ "Baselines:" + GetBaselines().Count() + ";"
		returnString:+ "Triggers:" + GetTriggers().Count() + ";"
		returnString:+ "Particles:" + GetParticles().Count() + ";"
		returnString:+ "Savepoints:" + GetSavepoints().Count() + ";"
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
		
		Return returnString
	End Method
	

'--------------------------------------------------------------------------
' * Getters
'--------------------------------------------------------------------------
	Method GetSprites:TList()
		Local sprites:TList = New TList
		Local e:TEntity
		For e = EachIn TEditor.GetInstance().world.EntityList
			If Not e.InFront
				sprites.AddLast (e)
			EndIf
		Next
		Return sprites
	End Method
	
	Method GetFrontSprites:TList()
		Local sprites:TList = New TList
		Local e:TEntity
		For e = EachIn TEditor.GetInstance().world.EntityList
			If e.InFront
				sprites.AddLast (e)
			EndIf
		Next
		Return sprites
	End Method
	
	Method GetPolys:TList()
		Local polys:TList = New TList
		Local p:TEntity
		For p = EachIn TEditor.GetInstance().world.Polys
			If Not p.isBaseline
				polys.AddLast (p)
			EndIf
		Next
		Return polys
	End Method
	
	Method GetBaselines:TList()
		Local baselines:TList = New TList
		Local p:TEntity
		For p = EachIn TEditor.GetInstance().world.Polys
			If p.isBaseline
				baselines.AddLast (p)
			EndIf
		Next
		Return baselines
	End Method
	
	Method GetTriggers:TList()
		Local triggers:TList = New TList
		Local t:TEntity
		For t = EachIn TEditor.GetInstance().world.Events
			If Not t.isParticle And (t.name.StartsWith("savepoint") = False)
				triggers.AddLast (t)
			EndIf
		Next
		Return triggers
	End Method
	
	Method GetParticles:TList()
		Local particles:TList = New TList
		Local p:TEntity
		For p = EachIn TEditor.GetInstance().world.Events
			If p.isParticle
				particles.AddLast (p)
			EndIf
		Next
		Return particles
	End Method
	
	Method GetSavepoints:TList()
        Local list:TList = New TList
        Local event:TEntity
        Local i:Int
        For event = EachIn TEditor.GetInstance().world.Events
			If event.name.StartsWith("savepoint")
				i:+1
				event.name = "savepoint" + i
				list.AddLast(event)
			EndIf
        Next
        Return list
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
