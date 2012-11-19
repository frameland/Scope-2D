'------------------------------------------------------------------------------
' The TWorld is a Blueprint for every new World you are going to create
'------------------------------------------------------------------------------
Type TWorld Abstract

	
'------------------------------------------------------------------------------
' Create an Entity-List to hold all Game-Objects
' The Active-List contains only Entities in range
'------------------------------------------------------------------------------
	Field EntityList:TList = New TList
	Field ActiveList:TList = New TList
	

'------------------------------------------------------------------------------
' Every World has a Camera from which the User sees it
'------------------------------------------------------------------------------
	Field cam:TCamera = New TCamera
	

'------------------------------------------------------------------------------
' Setting this variable to True destroys the current World
' Use this with the Destroy() Method
'------------------------------------------------------------------------------
	Field is_alive:Byte = True

	
'------------------------------------------------------------------------------
' Range is the number of pixels an object has to be near the camera to,
' else it will not get in the ActiveList
'------------------------------------------------------------------------------
	Field range:Float = 500
	Method SetRange( value:Float )
		range = value
	EndMethod
	
	
'------------------------------------------------------------------------------
' How many MilliSecs() does it take to refresh the ActiveList
'------------------------------------------------------------------------------
	Field refresh_intervall:Int = 200
	Method SetRefreshIntervall( value:Int )
		refresh_intervall = value
	EndMethod
	
	
'------------------------------------------------------------------------------
' Add an Enity to the World
'------------------------------------------------------------------------------
	Method AddEntity( entity:TEntity )
		entity.link = EntityList.AddLast( entity )
	EndMethod
	

'------------------------------------------------------------------------------
' Remove an Entity from the World
'------------------------------------------------------------------------------	
	Method RemoveEntity( entity:TEntity )
		entity.link.Remove()
	EndMethod
	

'------------------------------------------------------------------------------
' Check if the World is alive
'------------------------------------------------------------------------------
	Method IsAlive:Byte()
		Return is_alive
	EndMethod
	

'------------------------------------------------------------------------------
' Destroys the current World
'------------------------------------------------------------------------------
	Method Destroy()
		is_alive = False
	EndMethod
	

'------------------------------------------------------------------------------
' Number of Layers to process
'------------------------------------------------------------------------------
	Field MAX_LAYERS:Int = 5
	Method SetMaxLayers( value:Int )
		MAX_LAYERS = value
		Local entity:TEntity
		For entity = EachIn EntityList
			If (entity.layer > MAX_LAYERS)
				entity.layer = MAX_LAYERS
			EndIf
		Next
	EndMethod
	

'------------------------------------------------------------------------------
' Optimization Function for creating large worlds
' Every refresh_intervall (in MilliSecs) the ActiveList will get filled
' with Entities which are in range
' Use EachIn with ActiveList instead of EntityList in your Update and Render Routines
'------------------------------------------------------------------------------
' This function also does a kind of Z-Ordering so your Entities get drawn
' in the right order
'------------------------------------------------------------------------------
' Returns True if it was updated, else False
'------------------------------------------------------------------------------
	Field ticker:Int = MilliSecs()
	Method TransferActives:Int( force:Int = False )
		If Not force
			If (ticker + refresh_intervall) > MilliSecs() Then Return False
		EndIf
		ticker = MilliSecs()
		Local i:TEntity
		Local LayerList:TList[MAX_LAYERS]
		Local j:Int
		'Create Layers
		For j = 0 Until MAX_LAYERS
			LayerList[j] = New TList
		Next
		ActiveList.Clear()
		'Add all Entities in range to their respective LayerLists
		For i = EachIn EntityList
			If ((i.position.x + i.size.width)*cam.position.z + cam.screen_center_x >..
			(cam.position.x) * cam.position.z  + cam.dist_x - range)..
			And ((i.position.x)*cam.position.z + cam.screen_center_x <..
			(cam.position.x + i.size.width) * cam.position.z + cam.view.width + cam.dist_x + range)..
			And ((i.position.y + i.size.height)*cam.position.z + cam.screen_center_y >..
			(cam.position.y) * cam.position.z  + cam.dist_y - range )..
			And ((i.position.y)*cam.position.z + cam.screen_center_y <..
			(cam.position.y + i.size.height) * cam.position.z + cam.view.height + cam.dist_y + range)
				If (i.layer > MAX_LAYERS-1)
					i.layer = MAX_LAYERS-1
				ElseIf (i.layer < 0)
					i.layer = 0
				EndIf
				LayerList[i.layer].AddLast( i )
			EndIf
		Next
		Local ent:TEntity
		'Transfer all Entities from the Layers to the ActiveList in the right order
		For j = 0 Until MAX_LAYERS
			If LayerList[j].IsEmpty() Then Continue
			For ent = EachIn LayerList[j]
				ActiveList.AddLast(ent)
			Next
		Next
		'print Millisecs() - ticker
		Return True
	EndMethod
	
	
	
'------------------------------------------------------------------------------
' Sort the ActiveList according to the Entities layers
' If an object has changed it's layer call this Method instead of
' TransferActives() as this is much more efficient for this purpose
'------------------------------------------------------------------------------	
	Method ZSortActives()
		Local i:Int
		Local entity:TEntity
		Local LayerList:TList[MAX_LAYERS]
		For i = 1 To MAX_LAYERS
			LayerList[i] = New TList
		Next
		For entity = EachIn ActiveList
			If (entity.layer > MAX_LAYERS-1)
				entity.layer = MAX_LAYERS-1
			ElseIf (entity.layer < 0)
				entity.layer = 0
			EndIf
			LayerList[entity.layer].AddLast( entity )
		Next
		ActiveList.Clear()
		For i = 0 Until MAX_LAYERS
			For entity = EachIn LayerList[i]
				ActiveList.AddLast(entity)
			Next
		Next
	EndMethod
	

'--------------------------------------------------------------------------
' * Return True if entity is in view of the player, else False
'--------------------------------------------------------------------------
	Method IsInView:Int( entity:TEntity )
		Local size:Float = Max (entity.image.width*entity.scale.sx, entity.image.height*entity.scale.sy)
		Return  (entity.position.x + size - entity.image.handle_x + cam.screen_center_x/cam.position.z) > cam.position.x And ..
				(entity.position.y + size - entity.image.handle_y + cam.screen_center_y/cam.position.z) > cam.position.y And ..
				(entity.position.x + entity.image.handle_x - size - cam.screen_center_x/cam.position.z) < cam.position.x And ..
				(entity.position.y + entity.image.handle_y - size - cam.screen_center_y/cam.position.z) < cam.position.y
	End Method
	
	
'------------------------------------------------------------------------------
' Every World must have these Routines
'------------------------------------------------------------------------------
	Method Init() Abstract
	Method Render() Abstract
	Method Update() Abstract
	Method OnExit() Abstract


'------------------------------------------------------------------------------
' Run the Main-Loop while alive
'------------------------------------------------------------------------------	
	Method Run()
		While IsAlive()
			If TimeToUpdate()
				StartUpdate()
				cam.Update()
				Update()
				Delay FinishUpdate()-1 'give the system some time if available
			EndIf
			If TimeToRender()
				StartRendering()
				Cls()
				Render()
				Flip(0)
				FinishRendering()
			EndIf
		Wend
		OnExit()
	EndMethod
	

'------------------------------------------------------------------------------
' Zoom In/Out
'------------------------------------------------------------------------------	
	Method ZoomIn( multiplier:Float = 1.0 )
		cam.position.z:* zoomin_speed * multiplier
	EndMethod
	
	Method ZoomOut( multiplier:Float = 1.0 )
		cam.position.z:* zoomout_speed * multiplier
	EndMethod


'------------------------------------------------------------------------------
' Set Zoom Speed
'------------------------------------------------------------------------------
	Field zoomin_speed:Float = 0.98
	Field zoomout_speed:Float = 1.02
	
	Method SetZoomInSpeed( value:Float )
		zoomin_speed = value
	EndMethod
	
	Method SetZoomOutSpeed( value:Float )
		zoomout_speed = value
	EndMethod
	
EndType




