Type ExpOptions Extends TEditorExpansion
	
	Field editor:TEditor
	
	Field panel:TGadget
	Field panelProps:TGadget
	
	Field tabs:TGadget[4]
	Field currentGadget:Int = 0
	
	Field select_MultiSelect:TGadget
	Field move_MoveStraight:TGadget
	Field scale_KeepAspect:TGadget
	Field rotate_Snap:TGadget
	                        
	Field prop_Name:TGadget
	Field prop_Layer:TGadget
	Field prop_LayerNumber:TGadget
	Field labelLayer:TGadget
	Field prop_Red:TGadget
	Field prop_Green:TGadget
	Field prop_Blue:TGadget
	Field prop_Alpha:TGadget
	
	Field labelRed:TGadget
	Field labelGreen:TGadget
	Field labelBlue:TGadget
	
	Field prop_X:TGadget
	Field prop_Y:TGadget
	Field prop_ScaleX:TGadget
	Field prop_ScaleY:TGadget
	Field prop_Rotation:TGadget
	
	Field okButton:TGadget
	
'--------------------------------------------------------------------------
' * Init Gadgets
'--------------------------------------------------------------------------
	Method Init( editor:TEditor )
		panel:TGadget = CreatePanel( CANVAS_WIDTH,0,200,33,editor.window )
		SetGadgetLayout panel,0,1,1,0
		SetGadgetColor( panel, 210,210,210 )
		panelProps = CreatePanel( CANVAS_WIDTH,33,200,500,editor.window )
		SetGadgetLayout panelProps,0,1,1,0
		
		'Local labelOption:TGadget = CreateLabel( "Option",12,8,48,18,panel )
		Local sep1:TGadget = CreateLabel( "",1,32,panel.ClientWidth(),2,panel,3 )
		
		Local i:Int
		For i = 0 Until tabs.Length
			tabs[i] = CreatePanel( 0,0,ClientWidth(panel),ClientHeight(panel),panel )
			HideGadget( tabs[i] )	
		Next
		ShowGadget( tabs[0] )
		InitTabs()
		InitProps()
		
		Self.editor = editor
	EndMethod

'--------------------------------------------------------------------------
' * Init the contents of the Tabs + Properties
'--------------------------------------------------------------------------
	Method InitTabs()
		'Select
		select_MultiSelect = CreateButton("Add to Selection", 12, 8, 130, 15, tabs[0], BUTTON_CHECKBOX )
		'Move
		move_MoveStraight = CreateButton("Move Straight", 12, 8, 130, 15, tabs[1], BUTTON_CHECKBOX )
		'Scale
		scale_KeepAspect = CreateButton("Keep Aspect", 12, 8, 130, 15, tabs[2], BUTTON_CHECKBOX )
		SetButtonState( scale_KeepAspect, True )
		'Rotate
		rotate_Snap = CreateButton("Snap to Value", 12, 8, 130, 15, tabs[3], BUTTON_CHECKBOX )
	End Method
	
	Method InitProps()
		Local fontSize:Int
		?MacOS
			fontSize = 11
		?Win32
			fontSize = 9
		?
		Local titleFont:TGuiFont = LookupGuiFont (,fontSize,FONT_BOLD)
		Local normalFont:TGuiFont = LookupGuiFont(,fontSize)
		
		Local labelName:TGadget = CreateLabel( "Name",12,12,40,18,panelProps, LABEL_RIGHT )
		prop_Name:TGadget = CreateTextField( 61,9,121,20,panelProps,0 )
		labelLayer = CreateLabel( "Layer",12,41,40,18,panelProps, LABEL_RIGHT)
		prop_Layer:TGadget = CreateSlider( 60,39,106,20,panelProps, 5)
		SetSliderRange( prop_Layer, 1, STANDARD_LAYERS)
		SetSliderValue( prop_Layer, 1 )
		prop_LayerNumber = CreateLabel (STANDARD_LAYERS/2, 164, prop_Layer.ypos, 20, 20, panelProps, 8)
		SetGadgetSensitivity( labelLayer, SENSITIZE_MOUSE )
		Local sep2:TGadget = CreateLabel( "",0,67,panelProps.ClientWidth(),1,panelProps,3 )
		
		labelRed:TGadget = CreateLabel( "Red",12,78,40,18,panelProps,LABEL_RIGHT )
		labelGreen:TGadget = CreateLabel( "Green",12,106,40,18,panelProps,LABEL_RIGHT )
		labelBlue:TGadget = CreateLabel( "Blue",12,134,40,18,panelProps,LABEL_RIGHT )
		Local labelAlpha:TGadget = CreateLabel( "Alpha",12,162,40,18,panelProps, LABEL_RIGHT )
		SetGadgetSensitivity( labelRed, SENSITIZE_MOUSE )
		SetGadgetSensitivity( labelGreen, SENSITIZE_MOUSE )
		SetGadgetSensitivity( labelBlue, SENSITIZE_MOUSE )
		prop_Red:TGadget = CreateSlider( 60,76,122,20,panelProps,5 )
		prop_Green:TGadget = CreateSlider( 60,104,122,20,panelProps,5 )
		prop_Blue:TGadget = CreateSlider( 60,132,122,20,panelProps,5 )
		prop_Alpha:TGadget = CreateSlider( 60,160,122,20,panelProps,5 )
		SetSliderRange( prop_Red, 0, 255 )
		SetSliderValue( prop_Red, 255 )
		SetSliderRange( prop_Green, 0, 255 )
		SetSliderValue( prop_Green, 255 )
		SetSliderRange( prop_Blue, 0, 255 )
		SetSliderValue( prop_Blue, 255 )
		SetSliderRange( prop_Alpha, 0, 100 )
		SetSliderValue( prop_Alpha, 100 )
		Local sep3:TGadget = CreateLabel( "",0,188,panelProps.ClientWidth(),1,panelProps,3 )
		
		Local labelX:TGadget = CreateLabel( "X",14,198+20,80,18,panelProps,LABEL_CENTER )
		Local labelY:TGadget = CreateLabel( "Y",102,198+20,80,18,panelProps,LABEL_CENTER )
		prop_X = CreateTextField( 14+15,197,50,20,panelProps,0 )
		prop_Y = CreateTextField( 102+15,197,50,20,panelProps,0 )
		Local labelScaleX:TGadget = CreateLabel( "ScaleX",14,241+20,80,18,panelProps,LABEL_CENTER )
		Local labelScaleY:TGadget = CreateLabel( "ScaleY",102,241+20,80,18,panelProps,LABEL_CENTER )
		prop_ScaleX = CreateTextField( 14+15,240,50,20,panelProps,0 )
		prop_ScaleY = CreateTextField( 102+15,240,50,20,panelProps,0 )
		Local labelRotation:TGadget = CreateLabel( "Rotation",12,284+20,80,18,panelProps, LABEL_CENTER)
		prop_Rotation = CreateTextField( 14+15,283,50,20,panelProps,0 )
		Local sep4:TGadget = CreateLabel( "",0,324,panelProps.ClientWidth(),1,panelProps,3 )
		
		okButton = CreateButton ("",205,0,40,24,panelProps, BUTTON_OK)
		
		SetGadgetFont (labelName, titleFont)
		SetGadgetFont (labelLayer, titleFont)
		SetGadgetFont (labelRed, titleFont)
		SetGadgetFont (labelGreen, titleFont)
		SetGadgetFont (labelBlue, titleFont)
		SetGadgetFont (labelAlpha, titleFont)
		SetGadgetFont (prop_Name, normalFont)
		SetGadgetFont (select_MultiSelect, normalFont)
		SetGadgetFont (prop_LayerNumber, normalFont)
		SetGadgetFont (labelX, titleFont)
		SetGadgetFont (labelY, titleFont)
		SetGadgetFont (labelScaleX, titleFont)
		SetGadgetFont (labelScaleY, titleFont)
		SetGadgetFont (labelRotation, titleFont)
		SetGadgetFont (prop_X, normalFont)
		SetGadgetFont (prop_Y, normalFont)
		SetGadgetFont (prop_ScaleX, normalFont)
		SetGadgetFont (prop_ScaleY, normalFont)
		SetGadgetFont (prop_Rotation, normalFont)
		
		SetGadgetFilter (prop_Name, WordFilter)
		SetGadgetFilter (prop_X, FloatNumberFilter)
		SetGadgetFilter (prop_Y, FloatNumberFilter)
		SetGadgetFilter (prop_ScaleX, FloatNumberFilter)
		SetGadgetFilter (prop_ScaleY, FloatNumberFilter)
		
		UpdatePropsUI()
	End Method
	
'--------------------------------------------------------------------------
' * Changes Tab according to given id(selected Tool)
'--------------------------------------------------------------------------
	Method ChangeTab( id:Int )
		HideGadget( tabs[currentGadget] )
		currentGadget = id
		OnTabChange()
		ShowGadget( tabs[id] )
	EndMethod
	
'--------------------------------------------------------------------------
' * Do when Changing from one tool to another
'--------------------------------------------------------------------------
	Method OnTabChange()
		Local editor:TEditor = TEditor.GetInstance()
		Local selected:Int = editor.world.NrOfSelectedEntities()
		Local entity:TEntity
		If currentGadget <> 0 Then
			TSelection.ClearHighlighted( editor.world.EntityList )
		EndIf
	End Method

	Method UpdatePropsUI()
		Local editor:TEditor = TEditor.GetInstance()
		Local selected:Int = editor.world.NrOfSelectedEntities()
		Local entity:TEntity
		If selected = 0
			DisableGadget panelProps
			SetGadgetText (prop_X, "...")
			SetGadgetText (prop_Y, "...")
			SetGadgetText (prop_ScaleX, "...")
			SetGadgetText (prop_ScaleY, "...")
			SetGadgetText (prop_Rotation, "...")
			Return
		EndIf
		EnableGadget panelProps
		If (selected = 1)
			If editor.exp_toolbar.mode = MODE_EDIT
				EnableGadget prop_Name
				EnableGadget prop_Alpha
				EnableGadget prop_Red
				EnableGadget prop_Green
				EnableGadget prop_Blue
				EnableGadget prop_Layer
				entity = editor.world.GetSelectedEntity()
				SetGadgetText( prop_Name, entity.name )
				SetSliderValue( prop_Layer, entity.layer )
				SetGadgetText (prop_LayerNumber, entity.layer)
				SetSliderValue( prop_Red, entity.color.r )
				SetSliderValue( prop_Green, entity.color.g )
				SetSliderValue( prop_Blue, entity.color.b )
				SetSliderValue( prop_Alpha, Float( entity.color.a * 100.0 ) )
			Else
				DisableGadget prop_Alpha
				DisableGadget prop_Red
				DisableGadget prop_Green
				DisableGadget prop_Blue
				DisableGadget prop_Layer
				entity = editor.world.GetSelectedEntity()
				SetGadgetText( prop_Name, entity.name )
			EndIf
		ElseIf (selected > 1)
			If editor.exp_toolbar.mode = MODE_EDIT
				SetGadgetText( prop_Name, "..." )
				DisableGadget prop_Name
				SetSliderValue( prop_Layer, 1 )
				SetSliderValue( prop_Alpha, 100 )
			Else
				DisableGadget panelProps
			EndIf
		EndIf
		UpdateTransforms()
	End Method
	
	Method Enable()
		EnableGadget( tabs[currentGadget] )
		EnableGadget( panelProps )
	End Method

	Method Disable()
		DisableGadget( tabs[currentGadget] )
		DisableGadget( panelProps )
	End Method

'--------------------------------------------------------------------------
' * Shortcut for Turning on/off certain features (SHIFT)
'--------------------------------------------------------------------------
	Method ToggleExtra( editor:TEditor )
		Local event:TEvent = New TEvent
		event.id = EVENT_GADGETACTION
		Select editor.exp_toolbar.selected
			Case 0
				SetButtonState( select_MultiSelect, Not ButtonState(select_MultiSelect) )
				event.source = select_MultiSelect
			Case 1
				SetButtonState( move_MoveStraight, Not ButtonState(move_MoveStraight) )
				event.source = move_MoveStraight
			Case 2
				SetButtonState( scale_KeepAspect, Not ButtonState(scale_KeepAspect) )
				event.source = scale_KeepAspect
			Case 3
				SetButtonState( rotate_Snap, Not ButtonState(rotate_Snap) )
				event.source = rotate_Snap
			Default
		End Select
		event.Emit()
	End Method

'--------------------------------------------------------------------------
' * Property Setters
'--------------------------------------------------------------------------
	Method SetName()
		Local editor:TEditor = TEditor.GetInstance()
		Local selected:Int = editor.world.NrOfSelectedEntities()
		Local name:String = GadgetText( prop_Name )
		If selected = 1
			editor.world.GetSelectedEntity().SetName( editor.world.UniqueEntityName( name ) )
		EndIf		
	End Method

	Method SetLayer()
		Local editor:TEditor = TEditor.GetInstance()
		'editor.world.SaveState()
		Local selected:Int = editor.world.NrOfSelectedEntities()
		Local set_Layer:Int = Int( SliderValue(prop_Layer) )
		SetGadgetText( prop_LayerNumber, set_Layer )
		Local entity:TEntity
		If selected = 1
			editor.world.GetSelectedEntity().SetLayer( set_Layer )
		ElseIf selected > 1
			For entity = EachIn editor.world.EntityList
				If entity.selection.isSelected Then
					entity.SetLayer( set_Layer )
				EndIf
			Next
		EndIf
		RedrawGadget( editor.window )
	End Method
	
	Method SetAlpha()
		Local editor:TEditor = TEditor.GetInstance()
		'editor.world.SaveState()
		Local selected:Int = editor.world.NrOfSelectedEntities()
		Local set_Alpha:Float = Float( SliderValue(prop_Alpha)/100.0 )
		Local entity:TEntity
		If selected = 1
			editor.world.GetSelectedEntity().color.a = set_Alpha
		ElseIf (selected > 1)
			For entity = EachIn editor.world.EntityList
				If entity.selection.isSelected Then
					entity.color.a = set_Alpha
				EndIf
			Next
		EndIf
		RedrawGadget( editor.window )
	End Method
	
	Method SetRed()
		Local editor:TEditor = TEditor.GetInstance()
		'editor.world.SaveState()
		Local selected:Int = editor.world.NrOfSelectedEntities()
		Local set:Int = SliderValue(prop_Red)
		Local entity:TEntity
		If selected = 1
			editor.world.GetSelectedEntity().color.r = set
		ElseIf (selected > 1)
			For entity = EachIn editor.world.EntityList
				If entity.selection.isSelected Then
					entity.color.r = set
				EndIf
			Next
		EndIf
		RedrawGadget( editor.window )
	End Method

	Method SetGreen()
		Local editor:TEditor = TEditor.GetInstance()
		'editor.world.SaveState()
		Local selected:Int = editor.world.NrOfSelectedEntities()
		Local set:Int = SliderValue(prop_Green)
		Local entity:TEntity
		If selected = 1
			editor.world.GetSelectedEntity().color.g = set
		ElseIf (selected > 1)
			For entity = EachIn editor.world.EntityList
				If entity.selection.isSelected Then
					entity.color.r = set
				EndIf
			Next
		EndIf
		RedrawGadget( editor.window )
	End Method
	
	Method SetBlue()
		Local editor:TEditor = TEditor.GetInstance()
		'editor.world.SaveState()
		Local selected:Int = editor.world.NrOfSelectedEntities()
		Local set:Int = SliderValue(prop_Blue)
		Local entity:TEntity
		If selected = 1
			editor.world.GetSelectedEntity().color.b = set
		ElseIf (selected > 1)
			For entity = EachIn editor.world.EntityList
				If entity.selection.isSelected Then
					entity.color.r = set
				EndIf
			Next
		EndIf
		RedrawGadget( editor.window )
	End Method
	
	Method SetColor()
		Local editor:TEditor = TEditor.GetInstance()
		editor.world.SaveState()
		Local r:Int, g:Int, b:Int
		Local entity:TEntity
		Local selected:Int = editor.world.NrOfSelectedEntities()
		If selected = 1
			entity = editor.world.GetSelectedEntity()
			If RequestColor(entity.color.r, entity.color.g, entity.color.b) Then
				r = RequestedRed()
				g = RequestedGreen()
				b = RequestedBlue()
				entity.SetColor( r, g, b )
			EndIf
		ElseIf selected > 1
			If RequestColor(255, 255, 255) Then
				r = RequestedRed()
				g = RequestedGreen()
				b = RequestedBlue()
			EndIf
			For entity = EachIn editor.world.EntityList
				If entity.selection.isSelected
					entity.SetColor( r, g, b )
				EndIf
			Next
		EndIf
		UpdatePropsUI()
	End Method

'--------------------------------------------------------------------------
' * X, Y, ScaleX, ScaleY, Rotation
'--------------------------------------------------------------------------
	Method SetTransforms()
		Local editor:TEditor = TEditor.GetInstance()
		editor.world.SaveState()
		Local selected:Int = editor.world.NrOfSelectedEntities()
		Local x:Int = Int (GadgetText (prop_X))
		Local y:Int = Int (GadgetText (prop_Y))
		Local scaleX:Float = Float (GadgetText (prop_ScaleX))
		Local scaleY:Float = Float (GadgetText (prop_ScaleY))
		Local rotation:Float = Float (GadgetText (prop_Rotation))
		Local entity:TEntity
		If selected = 1
			entity = editor.world.GetSelectedEntity()
			entity.SetPosition (x, y)
			entity.SetScale (scaleX, scaleY)
			entity.SetRotation (rotation)
		ElseIf selected > 1
			For entity = EachIn editor.world.EntityList
				If entity.selection.isSelected Then
					entity.SetPosition (x, y)
					entity.SetScale (scaleX, scaleY)
					entity.SetRotation (rotation)
				EndIf
			Next
		EndIf
		RedrawGadget( editor.window )	
	End Method
	
	'TODO: Optimize to only set text that is necessary depending on current tool (e.g. for move only set position)
	Method UpdateTransforms()
		Local editor:TEditor = TEditor.GetInstance()
		Local selected:Int = editor.world.NrOfSelectedEntities()
		Local entity:TEntity
		If (Not editor.mouse.Dragging)
			Return
		EndIf
		If selected = 1
			entity = editor.world.GetSelectedEntity()
			Select editor.exp_toolbar.selected
				Case 1
					SetGadgetText (prop_X, Int (entity.position.x + 0.5))
					SetGadgetText (prop_Y, Int (entity.position.y + 0.5))
				Case 2
					SetGadgetText (prop_ScaleX, FormatedFloat (entity.scale.sx))
					SetGadgetText (prop_ScaleY, FormatedFloat (entity.scale.sy))
				Case 3
					SetGadgetText (prop_Rotation, Int (entity.rotation + 0.5))
				Default
			End Select
		ElseIf selected > 1
			SetGadgetText (prop_X, "")
			SetGadgetText (prop_Y, "")
			SetGadgetText (prop_ScaleX, "")
			SetGadgetText (prop_ScaleY, "")
			SetGadgetText (prop_Rotation, "")
		EndIf
		RedrawGadget( panelProps )
	End Method
	
	'May only be called after creating entity
	Method ShowTransformAttributes (entity:TEntity)
		SetGadgetText (prop_X, Int (entity.position.x + 0.5))
		SetGadgetText (prop_Y, Int (entity.position.y + 0.5))
		SetGadgetText (prop_ScaleX, FormatedFloat (entity.scale.sx))
		SetGadgetText (prop_ScaleY, FormatedFloat (entity.scale.sy))
		SetGadgetText (prop_Rotation, Int (entity.rotation + 0.5))
	End Method
	
End Type



