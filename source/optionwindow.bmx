Type OptionWindow
	
	Field window:TGadget
	Field folderGroup:TGadget
	Field sceneButton:TGadget
	Field graphicsButton:TGadget
	Field debugInfoButton:TGadget
	
	Method New()
		Local editor:TEditor = TEditor.GetInstance()
		window = CreateWindow( "Options",0,0,320,190,editor.window,WINDOW_CENTER|WINDOW_CLIENTCOORDS|WINDOW_TITLEBAR )
		folderGroup = CreatePanel(12, 12, window.ClientWidth() - 24, 110, window, PANEL_GROUP, "Folder Paths")
		CreateLabel("Scenes", 8, 17, 70, 24, folderGroup, LABEL_RIGHT)
		CreateLabel("Graphics", 8, 49, 70, 24, folderGroup, LABEL_RIGHT)
		sceneButton = CreateButton(GfxWorkingDir[..GfxWorkingDir.length-1], 78, 16, folderGroup.ClientWidth() - 82, 24, folderGroup)
		graphicsButton = CreateButton(MapWorkingDir[..MapWorkingDir.length-1], 78, 48, folderGroup.ClientWidth() - 82, 24, folderGroup)
		debugInfoButton = CreateButton("Render Debug-Info", 85, 12 + GadgetHeight(folderGroup) + 20, 200, 20, window, BUTTON_CHECKBOX)
		If RenderDebugInfo
			SetButtonState(debugInfoButton, True)
		EndIf
		ActivateGadget( window )
		Hide()
	End Method

	Method Show()
		Local editor:TEditor = TEditor.GetInstance()
		editor.exp_toolbar.Disable()
		editor.exp_menu.Disable()
		DisableGadget( editor.window )
		ShowGadget( window )
		editor.activeWindow = 6
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
				SaveConfig()
				Hide()
				
			Case EVENT_GADGETACTION
				If event.source = sceneButton
					Local path:String = RequestDir("Set scene folder", GadgetText(sceneButton))
					If path <> ""
						If path.Contains(AppDir)
							path = path.Replace(AppDir, "")[1..]
						EndIf
						SetGadgetText(sceneButton, path)
					EndIf
					
				ElseIf event.source = graphicsButton
					Local path:String = RequestDir("Set scene folder", GadgetText(graphicsButton))
					If path <> ""
						If path.Contains(AppDir)
							path = path.Replace(AppDir, "")[1..]
						EndIf
						SetGadgetText(graphicsButton, path)
					EndIf
				EndIf
			Default
		End Select
	End Method
	
	Method SaveConfig()
		RenderDebugInfo = ButtonState(debugInfoButton)
		MapWorkingDir = GadgetText(sceneButton) + "/"
		GfxWorkingDir = GadgetText(graphicsButton) + "/"
	End Method
	
End Type

