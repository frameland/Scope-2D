'------------------------------------------------------------------------------
' A simple Collision Manager
'------------------------------------------------------------------------------
Type TCollisionManager
	

'------------------------------------------------------------------------------
' How many times per second to check for collisions
'------------------------------------------------------------------------------
	Field fps:Int = 1000/25
	Field next_update:Int = MilliSecs() + fps
	
	
'------------------------------------------------------------------------------
' Set the camera for the Collision Manager
'------------------------------------------------------------------------------
	Field cam:TCamera
	Method SetCamera( camera:TCamera )
		cam = camera
	EndMethod

	
'------------------------------------------------------------------------------
' Set the Framerate of the Collision Manager
'------------------------------------------------------------------------------
	Method SetFps( value:Int )
		fps = 1000/value
	EndMethod
	

'------------------------------------------------------------------------------
' Add a new Collision Possibility
'------------------------------------------------------------------------------
	Field Possible:Int[20,20]
	Method AddPossibility( typ1:Int, typ2:Int )
		Possible[ typ1, typ2 ] = True
	EndMethod


'------------------------------------------------------------------------------
' See if the 2 given Entities can collide
' Returns True if so, else False
'------------------------------------------------------------------------------
	Method IsPossible:Int( entity1:TEntity, entity2:TEntity )
		Return Possible[ entity1.typ, entity2.typ ]
	EndMethod
	
	
'------------------------------------------------------------------------------
' Returns True if an update should occur, else False
'------------------------------------------------------------------------------
	Method ReadyForUpdate:Int()
		If MilliSecs() > next_update
			next_update = MilliSecs() + fps
			Return True
		EndIf
		Return False
	EndMethod
	

'------------------------------------------------------------------------------
' Main Update Method
' Will select the currently set Collision-Mode and update accordingly
'------------------------------------------------------------------------------
' The list you pass to this function should only contain a minimum
' number of objects as they all get checked against each other.
' (you can sort out all Entities that are not on screen)
' Do not forget to clear the list from time to time (or every frame)
'------------------------------------------------------------------------------	
	Method Update( list:TList )
		If Not ReadyForUpdate()
			Return
		EndIf
		Check( list )
	EndMethod
	
	
'------------------------------------------------------------------------------
' Check for collisions and send messages to the colliding Entities
' First there is a Radial Check(fast) to see if objects are near each other
' TODO: Then Check with Seperating Axis Theorie
'------------------------------------------------------------------------------
	Method Check( list:TList )
		Local e:TEntity, e2:TEntity
		Local SplitList:TList[] = SplitIntoAreas( list )
		UpdateTime()
		Local i:Int,counter:Int
		'New TMessage.Create( Null, game.thePlayer , "No Collision").Send() '<- dirty hack
		For i = 0 Until 4
		For e = EachIn SplitList[i]
			If (Not e.collision.moving) Then Continue
			For e2 = EachIn SplitList[i]
				If (e = e2) Then Continue
				If Not IsPossible( e, e2 ) Then Continue
				If DistanceOfPoints(e.position.x,e.position.y,e2.position.x,e2.position.y) < (e.collision.radius + e2.collision.radius)
											
				EndIf
			Next
		Next
		Next
	EndMethod


'------------------------------------------------------------------------------
' Splits the pasted list into 4 Lists, depending on position of entity
' Returns a TList[4]
' SplitList[0] = Top Left		Area 0
' SplitList[1] = Top Right		Area 1
' SplitList[2] = Bottom Left	Area 2
' SplitList[3] = Bottom Right	Area 3
'------------------------------------------------------------------------------
	Method SplitIntoAreas:TList[]( entityList:TList )
		Local SplitList:TList[4]
		SplitList[0] = New TList
		SplitList[1] = New TList
		SplitList[2] = New TList
		SplitList[3] = New TList
		Local e:TEntity
		For e = EachIn entityList
			If (Not e.collision.collidable) Then Continue 
			'Left Side
			If (e.position.x - e.size.width/2) <  cam.position.x + (cam.view.width / 2)
				'Area 0
				If (e.position.y - e.size.height/2) < cam.position.y + (cam.view.height / 2)
					SplitList[0].AddLast(e)
					If (e.position.x + e.size.width/2) > cam.position.x + (cam.view.width / 2)
						SplitList[1].AddLast(e)
					EndIf
					If (e.position.y + e.size.height/2) > cam.position.y + (cam.view.height / 2)
						SplitList[2].AddLast(e)
					EndIf
				'Area 2
				Else
					SplitList[2].AddLast(e)
					If (e.position.x + e.size.width/2) > cam.position.x + (cam.view.width / 2)
						SplitList[3].AddLast(e)
					EndIf
				EndIf
			'Right Side
			Else
				'Area 1
				If (e.position.y - e.size.height/2) < cam.position.y + (cam.view.height / 2)
					SplitList[1].AddLast(e)
					If (e.position.y + e.size.height/2) > cam.position.y + (cam.view.height / 2)
						SplitList[3].AddLast(e)
					EndIf
				'Area 3
				Else
					SplitList[3].AddLast(e)
				EndIf
			EndIf
		Next
		Return SplitList
	EndMethod
	
	
EndType
