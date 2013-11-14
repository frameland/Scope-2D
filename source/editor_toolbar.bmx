Const MODE_EDIT:Int = 0
Const MODE_COLLISION:Int = 1
Const MODE_EVENT:Int = 2


Type ExpToolbar Extends TEditorExpansion
	
	Field editor:TEditor
	Field toolbar:TGadget
	Field selected:Int = 0
	Field mode:Int 'deprecated
	
'--------------------------------------------------------------------------
' * Init Gadgets
'--------------------------------------------------------------------------
	Method Init( editor:TEditor )
		Self.editor = editor
		toolbar = CreateToolbar("",0,0,0,0,editor.window)
		Local icons:TIconStrip = LoadIconStrip("source/ressource/toolbar.png")
		SetGadgetIconStrip( toolbar, icons )
		AddGadgetItem( toolbar,"New",0, 0 )
		AddGadgetItem( toolbar,"Open",0, 2 )
		AddGadgetItem( toolbar,"Save",0, 4 )
		AddGadgetItem( toolbar,"",0, GADGETICON_BLANK )
		AddGadgetItem( toolbar,"Undo",0, 6 )
		AddGadgetItem( toolbar,"Redo",0, 8 )
		AddGadgetItem( toolbar,"",0, GADGETICON_BLANK )
		AddGadgetItem( toolbar,"Select", GADGETITEM_TOGGLE, 10 )
		AddGadgetItem( toolbar,"Move", GADGETITEM_TOGGLE, 12 )
		AddGadgetItem( toolbar,"Scale", GADGETITEM_TOGGLE, 14 )
		AddGadgetItem( toolbar,"Rotate", GADGETITEM_TOGGLE, 16 )
		AddGadgetItem( toolbar,"",0, GADGETICON_BLANK )
		AddGadgetItem( toolbar,"Select", 0, 18)
		Local tips:String[] = ["New","Open","Save","","Undo","Redo","","Select (Q)","Move (W)","Scale (E)","Rotate (R)", "", "Show Graphics (Spacebar)"]
		SetToolbarTips( toolbar, tips )
	EndMethod

'--------------------------------------------------------------------------
' * Update Tab according to selected Tool
'--------------------------------------------------------------------------	
	Method OnClick( data:Int )
		Select data
			Case 0
				editor.world.NewScene()
			Case 1
				SceneFile.Instance().Open()
			Case 2
				SceneFile.Instance().Save()
			Case 4
				editor.world.Undo()
			Case 5
				editor.world.Redo()
			Case 7,8,9,10
				selected = data - 7
				SetSelected()
				editor.exp_options.ChangeTab( selected )
			Case 12
				editor.GoToChooseMode()
			Default
		End Select
	End Method

'--------------------------------------------------------------------------
' * Fix so the correct Tool is selected
'--------------------------------------------------------------------------
	Method SetSelected()
		Local i:Int = 0
		For i = 0 Until 4
			DeselectGadgetItem( toolbar, i+7 )
		Next
		ToggleGadgetItem( toolbar, selected + 7 )
	End Method
	
	
'--------------------------------------------------------------------------
' * Switch Tool via Keyboard Shortcut
'--------------------------------------------------------------------------
	Method ActivateNextTool( editor:TEditor, backwards:Int = False )
		If backwards
			selected:- 1
			If selected < 0 Then selected = 3
		Else
			selected:+ 1
			If selected > 3 Then selected = 0
		EndIf
		SetSelected()
		editor.exp_options.ChangeTab( selected )
	End Method

'--------------------------------------------------------------------------
' * Disable Self
'--------------------------------------------------------------------------
	Method Disable()
		Local i:Int
		Local items:Int = CountGadgetItems( toolbar )
		For i = 0 Until items
			If i <> 12
				DisableGadgetItem( toolbar, i )
			EndIf
		Next
	End Method
	
	Method Enable()
		Local i:Int
		Local items:Int = CountGadgetItems( toolbar )
		For i = 0 Until items
			EnableGadgetItem( toolbar, i )
		Next
	End Method
	
EndType