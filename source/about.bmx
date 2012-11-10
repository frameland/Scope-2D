'--------------------------------------------------------------------------
' * Shows the about dialog
'--------------------------------------------------------------------------
Type AboutWindow
	
	Field window:TGadget
	Field imagePanel:TGadget
	Field lowerPanel:TGadget
	Field link:TGadget
	
'--------------------------------------------------------------------------
' * Init
'--------------------------------------------------------------------------
	Method New()
		Local editor:TEditor = TEditor.GetInstance()
		Local style:Int = WINDOW_TITLEBAR|WINDOW_CLIENTCOORDS|WINDOW_CENTER
		window = CreateWindow( "About Scope 2D", 0, 0, 414, 350, editor.window, style )
		imagePanel = CreatePanel( 0, 0, window.ClientWidth(), 233, window )
		lowerPanel = CreatePanel( 0, 233, window.ClientWidth(), window.ClientHeight()-213, window )
		SetGadgetPixmap( imagePanel, LoadPixmap("source/ressource/About.png") )
		CreateLabel( "",0,0,lowerPanel.ClientWidth(),2,lowerPanel,LABEL_SEPARATOR )
		link = CreateHyperlink( "http://scope2d.com/",0,25,lowerPanel.ClientWidth(),20,lowerPanel, LABEL_CENTER, "Visit Official Website" )
		CreateLabel( "(c) Copyright 2011 Markus Langthaler",0,60,lowerPanel.ClientWidth(),20,lowerPanel,LABEL_CENTER )
		CreateLabel( "All rights reserved",0,80,lowerPanel.ClientWidth(),20,lowerPanel,LABEL_CENTER )
		ActivateGadget( window )
		Hide()
	End Method

'--------------------------------------------------------------------------
' * Show About
'--------------------------------------------------------------------------
	Method Show()
		Local editor:TEditor = TEditor.GetInstance()
		editor.exp_toolbar.Disable()
		editor.exp_menu.Disable()
		DisableGadget( editor.window )
		ShowGadget( window )
		ActivateGadget( window )
		editor.activeWindow = 2
	End Method

'--------------------------------------------------------------------------
' * Hide About
'--------------------------------------------------------------------------
	Method Hide()
		Local editor:TEditor = TEditor.GetInstance()
		HideGadget( window )
		editor.exp_toolbar.Enable()
		editor.exp_menu.Enable()
		EnableGadget( editor.window )
		ActivateGadget( editor.window )
		editor.activeWindow = 1
	End Method

'--------------------------------------------------------------------------
' * Act on Events
'--------------------------------------------------------------------------
	Method OnEvent( event:TEvent )
		Select event.id
			Case EVENT_WINDOWCLOSE
				Hide()
			Default
		End Select
	End Method
	
End Type

