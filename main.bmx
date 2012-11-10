'buildopt: release
'buildopt: gui
'buildopt: execute

SuperStrict


'--------------------------------------------------------------------------
' * Import Libs
'--------------------------------------------------------------------------
Import maxgui.drivers
Import maxgui.proxygadgets
Import chaos.desktopext
Import sho.fps
Include "source/engine/core.bmx"

'--------------------------------------------------------------------------
' * Include Files
'--------------------------------------------------------------------------
Include "source/world.bmx"
Include "source/editor.bmx"
Include "source/editor_menu.bmx"
Include "source/editor_toolbar.bmx"
Include "source/editor_canvas.bmx"
Include "source/editor_options.bmx"
Include "source/mouse.bmx"
Include "source/controller.bmx"
Include "source/selection.bmx"
Include "source/filemanager.bmx"
Include "source/undo.bmx"
Include "source/about.bmx"
Include "source/toolwindows.bmx"


Local app:TEditor = New TEditor
'--------------------------------------------------------------------------
' * Main Loop
'--------------------------------------------------------------------------
While Not app.Ending()
	WaitEvent()
	Delay( 1 )
Wend




