'--------------------------------------------------------------------------
' * Set Max Layer
'--------------------------------------------------------------------------
Type LayerSetterWindow
	
	Field window:TGadget
	Field labelValue:TGadget
	Field txtValue:TGadget
	Field stepper:TGadget
	
	Method New()
		Local editor:TEditor = TEditor.GetInstance()
		window = CreateWindow( "Set Max Layers",0,0,323,44,editor.window,WINDOW_CENTER|WINDOW_CLIENTCOORDS|WINDOW_TITLEBAR )
		CreateLabel( "Max Number of Layers:",0,12,182,20,window,8 )
		txtValue = CreateTextField( 190,11,70,20,window,0 )
		stepper = CreateSlider( 262,10,15,22,window,SLIDER_STEPPER|SLIDER_VERTICAL)
		SetSliderRange( stepper, 0, 1 )
		SetGadgetFilter (txtValue, NumberFilter)
		ActivateGadget( window )
		Hide()
	End Method

	Method Show()
		Local editor:TEditor = TEditor.GetInstance()
		editor.exp_toolbar.Disable()
		editor.exp_menu.Disable()
		DisableGadget( editor.window )
		ShowGadget( window )
		ActivateGadget( txtValue )
		editor.activeWindow = 3
		SetGadgetText (txtValue, String(editor.world.MAX_LAYERS))
	End Method

	Method Hide()
		Local editor:TEditor = TEditor.GetInstance()
		HideGadget( window )
		editor.exp_toolbar.Enable()
		editor.exp_menu.Enable()
		EnableGadget( editor.window )
		ActivateGadget( editor.window )
		editor.activeWindow = 1
		editor.mouse.SetUp()
		editor.exp_options.UpdatePropsUI()
	End Method

	Method OnEvent( event:TEvent )
		Select event.id
			Case EVENT_WINDOWCLOSE
				Local paddingValue:Int = Int(GadgetText( txtValue ))
				Local editor:TEditor = TEditor.GetInstance()
				editor.world.SetMaxLayers (paddingValue)
				SetSliderRange( editor.exp_options.prop_Layer, 1, editor.world.MAX_LAYERS )
				Hide()
			Case EVENT_GADGETACTION
				Local paddingValue:Int = Int(GadgetText( txtValue ))
				If event.source = stepper
					If SliderValue(stepper) = 1
						paddingValue:+ 1
					ElseIf SliderValue(stepper) = 0
						paddingValue:- 1
					EndIf
					If (paddingValue < 1)
						paddingValue = 1
					ElseIf (paddingValue > 1000)
						paddingValue = 1000
					EndIf
					SetGadgetText( txtValue, paddingValue )
				ElseIf event.source = txtValue
					If GadgetText( txtValue ) = ""
						SetGadgetText( txtValue, "1" )
					ElseIf (paddingValue < 1)
						paddingValue = 1
					ElseIf (paddingValue > 1000)
						paddingValue = 1000
					EndIf
					SetGadgetText( txtValue, paddingValue )
				EndIf
			Default
		End Select
	End Method
	
End Type




'--------------------------------------------------------------------------
' * Grid Size
'--------------------------------------------------------------------------
Type GridSizeWindow
	
	Field window:TGadget
	Field labelValue:TGadget
	Field txtValue:TGadget
	Field stepper:TGadget
	
	Method New()
		Local editor:TEditor = TEditor.GetInstance()
		window = CreateWindow( "Set Grid Size",0,0,323,44,editor.window,WINDOW_CENTER|WINDOW_CLIENTCOORDS|WINDOW_TITLEBAR )
		CreateLabel( "Grid Size:",0,12,142,20,window,8 )
		txtValue = CreateTextfield( 150,11,70,20,window,0 )
		stepper = CreateSlider( 222,10,15,22,window,SLIDER_STEPPER|SLIDER_VERTICAL )
		SetSliderRange( stepper, 0, 1 )
		SetGadgetFilter (txtValue, NumberFilter)
		ActivateGadget( window )
		Hide()
	End Method

	Method Show()
		Local editor:TEditor = TEditor.GetInstance()
		editor.exp_toolbar.Disable()
		editor.exp_menu.Disable()
		DisableGadget( editor.window )
		ShowGadget( window )
		ActivateGadget( txtValue )
		editor.activeWindow = 4
		SetGadgetText( txtValue, editor.exp_menu.gridSize )
	End Method

	Method Hide()
		Local editor:TEditor = TEditor.GetInstance()
		HideGadget( window )
		editor.exp_toolbar.Enable()
		editor.exp_menu.Enable()
		EnableGadget( editor.window )
		ActivateGadget( editor.window )
		editor.activeWindow = 1
		editor.mouse.SetUp()
	End Method

	Method OnEvent( event:TEvent )
		Select event.id
			Case EVENT_WINDOWCLOSE
				Local paddingValue:Int = Int(GadgetText( txtValue ))
				Local editor:TEditor = TEditor.GetInstance()
				editor.exp_menu.gridSize = paddingValue
				Hide()
			Case EVENT_GADGETACTION
				Local paddingValue:Int = Int(GadgetText( txtValue ))
				Local editor:TEditor = TEditor.GetInstance()
				If event.source = stepper
					If SliderValue(stepper) = 1
						paddingValue:+ 1
					ElseIf SliderValue(stepper) = 0
						paddingValue:- 1
					EndIf
					If (paddingValue < 1)
						paddingValue = 1
					ElseIf (paddingValue > 1024)
						paddingValue = 1024
					EndIf
					SetGadgetText( txtValue, paddingValue )
				ElseIf event.source = txtValue
					If GadgetText( txtValue ) = ""
						SetGadgetText( txtValue, "1" )
					ElseIf (paddingValue < 1)
						paddingValue = 1
					ElseIf (paddingValue > 1024)
						paddingValue = 1024
					EndIf
					SetGadgetText( txtValue, paddingValue )
				EndIf
			Default
		End Select
	End Method
	
End Type



'--------------------------------------------------------------------------
' * SceneProps
'--------------------------------------------------------------------------
Type ScenePropertyWindow
	
	Field window:TGadget
	Field tabs:TGadget[2]
	Field labelView:TGadget
	Field comboView:TGadget
	
	Field panel:TScrollPanel
	Field panelNormal:TScrollPanel
	
	Field buttonAdd:TGadget
	Field buttonApply:TGadget
	
	Method New()
		Local editor:TEditor = TEditor.GetInstance()
		window = CreateWindow( "Scene Properties",0,0,455,437,editor.window,WINDOW_CENTER|WINDOW_CLIENTCOORDS|WINDOW_TITLEBAR|WINDOW_RESIZABLE )
		SetMinWindowSize (window, 455,437)
		SetMaxWindowSize (window, 455,DesktopHeight()-100)
		labelView = CreateLabel( "View:",12,11,38,20,window,0 )
		SetGadgetLayout labelView,1,0,1,0
		comboView = CreateComboBox( 52,8,150,24,window)
		SetGadgetLayout comboView,1,0,1,0
		AddGadgetItem (comboView, "General", GADGETITEM_DEFAULT)
		AddGadgetItem (comboView, "Custom")
		Local sep1:TGadget = CreateLabel( "",0,40,455,1,window,3 )
		SetGadgetLayout sep1,1,1,1,0

		tabs[1] = CreatePanel (0, 41, 455, 396, window)
		SetGadgetLayout tabs[1],1,1,1,1
		panel = CreateScrollPanel( 0,0,455,352,tabs[1],SCROLLPANEL_HNEVER )
		SetGadgetLayout panel,1,1,1,1
		SetGadgetColor (panel, 255, 255, 255)
		buttonAdd = CreateButton( "Add Property",147,364,160,24,tabs[1],BUTTON_PUSH )
		SetGadgetLayout buttonAdd,0,0,0,1
		Local sep2:TGadget = CreateLabel( "",0,352,455,1,tabs[1],3 )
		SetGadgetLayout sep2,1,1,0,1
		
		tabs[0] = CreatePanel (0, 41, 455, 396, window)
		SetGadgetLayout tabs[0],1,1,1,1
		panelNormal = CreateScrollPanel (0,0,455,352,tabs[0],SCROLLPANEL_HNEVER)
		SetGadgetLayout panelNormal,1,1,1,1
		SetGadgetColor (panelNormal, 255, 255, 255)
		buttonApply = CreateButton ("Apply Changes",147,364,160,24,tabs[0],BUTTON_OK )
		Local sep3:TGadget = CreateLabel( "",0,352,455,1,tabs[0],3 )
		SetGadgetLayout sep3,1,1,0,1
		
		AddNormalProperty ("Width", "1000")
		AddNormalProperty ("Height", "1000")
		AddNormalProperty ("Layers", "5")
		
		ActivateGadget( window )
		AddProperty()
		Hide()
	End Method

	Method Show()
		SetPointer (POINTER_DEFAULT)
		Local editor:TEditor = TEditor.GetInstance()
		editor.exp_toolbar.Disable()
		editor.exp_menu.Disable()
		DisableGadget( editor.window )
		ShowGadget( window )
		editor.activeWindow = 5
	End Method

	Method Hide()
		Local editor:TEditor = TEditor.GetInstance()
		HideGadget( window )
		editor.exp_toolbar.Enable()
		editor.exp_menu.Enable()
		EnableGadget( editor.window )
		ActivateGadget( editor.window )
		editor.activeWindow = 1
	End Method
	
	Method AddProperty()
		Local prop:SceneProperty = New SceneProperty
		prop.Init (panel)
	End Method
	
	Method AddPropertyWithValue( name:String, value:String )
		Local prop:SceneProperty = New SceneProperty
		prop.Init (panel)
		SetGadgetText (prop.labelProperty, name)
		SetGadgetText (prop.labelValue, value)
	End Method

	Method OnEvent( event:TEvent )
		Select event.id
			Case EVENT_WINDOWCLOSE
				Hide()
			Case EVENT_GADGETACTION
				If (event.source = buttonAdd)
					AddProperty()
				ElseIf (event.source = buttonApply)
					Hide()
					RedrawGadget (TEditor.GetInstance().exp_canvas.canvas)
					Show()
				ElseIf (event.source = comboView)
					If (SelectedGadgetItem(comboView) = 0) 'Normal Props
						HideGadget (tabs[1])
						ShowGadget (tabs[0])
					ElseIf (SelectedGadgetItem(comboView) = 1) 'Custom Props
						HideGadget (tabs[0])
						ShowGadget (tabs[1])
					Else
						Return
					EndIf
				Else
					Local normal:NormalSceneProperty
					For normal = EachIn NormalSceneProperty.List
						If (normal.labelValue = event.source)
							normal.OnEvent (normal)
							Exit
						EndIf
					Next
				EndIf
			Case EVENT_MOUSEDOWN
				If (Not event.source)
					Return
				EndIf
				Local obj:Object = GadgetExtra (TGadget (event.source))
				If (obj)
					SceneProperty (obj).Remove()
				EndIf
			Default
		End Select
	End Method
	
	Method AddNormalProperty (name:String, value:String)
		Local prop:NormalSceneProperty = New NormalSceneProperty
		prop.Init (panelNormal)
		SetGadgetText (prop.labelProperty, name)
		SetGadgetText (prop.labelValue, value)
	End Method
	
End Type




'--------------------------------------------------------------------------
' * A scene-property consisting of Property and Value
'--------------------------------------------------------------------------
Type SceneProperty
	
	Global List:TList = New TList
	Global lastY:Int = 4
	Global propFont:TGuiFont = LookUpGuiFont (GUIFONT_SYSTEM, 12, FONT_BOLD)
	Global valFont:TGuiFont = LookUpGuiFont (GUIFONT_SYSTEM, 11)
	Global icon:TPixmap = LoadPixmap ("source/ressource/remove.png")
	Global size:Int = 0
	Global scroller:TScrollPanel

	Field panel:TGadget
	Field labelProperty:TGadget
	Field labelValue:TGadget
	Field removeButton:TGadget
	Field link:TLink
	
	Function Clear()
		Local prop:SceneProperty
		For prop = EachIn List
			FreeGadget (prop.panel)
		Next
		List.Clear()
		TEditor.GetInstance().window_SceneProps.AddProperty()
		SortList()
		size = 1
	End Function
	
	Method Init(scroll:TScrollPanel)
		Local window:TGadget = ScrollPanelClient( scroll )
		scroller = scroll
		panel = CreatePanel (0, lastY, window.ClientWidth(), 34, window)
		labelProperty = CreateTextfield (12, 6, 184, 22, panel)
		SetGadgetFont (labelProperty, propFont)
		labelValue = CreateTextfield (208, 6, 184, 22, panel)
		SetGadgetFont (labelValue, valFont)
		removeButton = CreatePanel (402, 6, 22, 22, panel)
		SetGadgetSensitivity (removeButton, SENSITIZE_MOUSE)
		SetGadgetExtra (removeButton, Self)
		SetGadgetPixmap (removeButton, icon, PANELPIXMAP_CENTER )
		link = List.AddLast (Self)
		lastY:+34
		size:+1
		FitScrollPanelClient( scroll, SCROLLPANEL_SIZETOKIDS )
		ShowGadget (panel)
	End Method
	
	Method Remove()
		If (size <= 1) Return
		size:-1 
		FreeGadget (panel)
		link.Remove()
		SortList()
	End Method
	
	Function SortList()
		lastY = 4
		Local o:SceneProperty
		For o = EachIn SceneProperty.List
			SetGadgetShape (o.panel, o.panel.xpos, lastY, o.panel.width, o.panel.height)
			lastY:+28
		Next
		FitScrollPanelClient (scroller)
	End Function
	
End Type


Type NormalSceneProperty
	
	Global List:TList = New TList
	Global lastY:Int = 5
	Global scroller:TScrollPanel
	
	Field panel:TGadget
	Field labelProperty:TGadget
	Field labelValue:TGadget
	
	Method Init (scroll:TScrollPanel)
		Local window:TGadget = ScrollPanelClient( scroll )
		scroller = scroll
		panel = CreatePanel (0, lastY, window.ClientWidth(), 34, window)
		labelProperty = CreateLabel ("", 12, 8, 184, 20, panel, LABEL_RIGHT)
		SetGadgetFont (labelProperty, SceneProperty.propFont)
		labelValue = CreateTextfield (208, 6, 184, 22, panel)
		SetGadgetFont (labelValue, SceneProperty.valFont)
		SetGadgetExtra (labelValue, Self)
		List.AddLast (Self)
		lastY:+34
		FitScrollPanelClient( scroll, SCROLLPANEL_SIZETOKIDS )
		ShowGadget (panel)
		Clear()
	End Method
	
	Method OnEvent (obj:NormalSceneProperty)
		Local prop:String = GadgetText (obj.labelProperty)
		Local editor:TEditor = TEditor.GetInstance()
		Select (prop)
			Case "Width"
				editor.world.size.x = Int (GadgetText (obj.labelValue))
			Case "Height"
				editor.world.size.y = Int (GadgetText (obj.labelValue))
			Case "Layers"
				editor.world.SetMaxLayers (Int (GadgetText (obj.labelValue)))
			Default
		End Select
	End Method
	
	Function SetValueOfProperty (property:String, value:String)
		Local prop:NormalSceneProperty
		For prop = EachIn List
			If (GadgetText (prop.labelProperty) = property)
				SetGadgetText (prop.labelValue, value)
				prop.OnEvent (prop)
				Exit
			EndIf
		Next
	End Function
	
	Function Clear()
		Local prop:NormalSceneProperty
		Local pName:String
		Local editor:TEditor = TEditor.GetInstance()
		For prop = EachIn List
			pName = GadgetText (prop.labelProperty)
			Select (pName)
				Case "Width"
					SetGadgetText (prop.labelValue, Int (editor.world.size.x))
					editor.world.size.x = Int (GadgetText (prop.labelValue))
				Case "Height"
					SetGadgetText (prop.labelValue, Int(editor.world.size.y))
					editor.world.size.y = Int (GadgetText (prop.labelValue))
				Case "Layers"
					SetGadgetText (prop.labelValue, Int (editor.world.MAX_LAYERS))
					editor.world.SetMaxLayers (Int (GadgetText (prop.labelValue)))
				Default
			End Select
		Next
	End Function
End Type


