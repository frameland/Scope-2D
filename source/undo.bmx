'--------------------------------------------------------------------------
' * State of the World(EntityList), used to Undo/Redo
'--------------------------------------------------------------------------
Type TWorldState
	
	Field length:Int = 100
	Field Past:TList[length]
	Field PastPoly:TList[length]
	Field index:Int = -1
	
	Field future_length:Int = 100
	Field Future:TList[future_length]
	Field future_index:Int = -1

'--------------------------------------------------------------------------
' * Save Current State of the World
'--------------------------------------------------------------------------
	Method Save( Entities:TList)
		index:+ 1
		Local i:Int
		If index >= length Then
			For i = 1 Until length
				Past[i-1] = Past[i]
			Next
			index = length-1
		EndIf
		
		'Entities
		Local list:TList = New TList
		Local entity:TEntity
		Local dummy:TEntity
		For entity = EachIn Entities
			dummy = New TEntity
			dummy.position.Set( entity.position.x, entity.position.y )
			dummy.scale.Set( entity.scale.sx, entity.scale.sy )
			dummy.flipH = entity.flipH
			dummy.flipV = entity.flipV
			dummy.image = entity.image
			dummy.texturePath = entity.texturePath
			dummy.rotation = entity.rotation
			dummy.color.SetRGB( entity.color.r, entity.color.g, entity.color.b )
			dummy.color.a = entity.color.a
			dummy.size.Set( entity.size.width, entity.size.height )
			dummy.collision = entity.collision.GetCopy( dummy )
			dummy.isParticle = entity.isParticle
			dummy.isBaseline = entity.isBaseline
			dummy.allowObjectTriggering = entity.allowObjectTriggering
			dummy.layer = entity.layer
			dummy.name = entity.name
			dummy.visible = entity.visible
			dummy.inFront = entity.inFront
			dummy.selection.Init( dummy )
			dummy.selection.isOverlapping = entity.selection.isOverlapping
			dummy.selection.isSelected = entity.selection.isSelected
			dummy.link = list.AddLast( dummy )
		Next
		Past[index] = list
	End Method
	

'--------------------------------------------------------------------------
' * Undo last Action
'--------------------------------------------------------------------------	
	Method Undo( List:TList )
		If index < 0 Then Return
		If Not Past[index] Then Return
		AddToRedoList( List )
		List.Clear()
		Local entity:TEntity
		For entity = EachIn Past[index]
			entity.link = List.AddLast( entity )
		Next
		Past[index] = Null
		index:- 1
		If index < 0 Then
			index = 0
		EndIf
	End Method
	
'--------------------------------------------------------------------------
' * Redo last Action
'--------------------------------------------------------------------------
	Method Redo( List:TList )
		If future_index < 0 Then Return
		If Not Future[future_index] Then Return
		AddToUndoList( List )
		List.Clear()
		Local entity:TEntity
		For entity = EachIn Future[future_index]
			entity.link = List.AddLast( entity )
		Next
		Future[future_index] = Null
		future_index:- 1
		If future_index < 0 Then
			future_index = 0
		EndIf
	End Method
	
'--------------------------------------------------------------------------
' * Private
'--------------------------------------------------------------------------
	Method AddToRedoList( List:TList )
		future_index:+ 1
		If future_index < 0 Then
			future_index = 0
		ElseIf future_index >= future_length Then
			future_index = future_length - 1
		EndIf
		Future[future_index] = New TList
		Local entity:TEntity
		For entity = EachIn List
			entity.link = Future[future_index].AddLast( entity )
		Next
	End Method
	
	Method AddToUndoList( List:TList )
		index:+ 1
		If index < 0 Then
			index = 0
		ElseIf index >= length Then
			index = length - 1
		EndIf
		Past[index] = New TList
		Local entity:TEntity
		For entity = EachIn List
			entity.link = Past[index].AddLast( entity )
		Next
	End Method
	
	Method ClearRedoList()
		Local i:Int
		For i = 0 Until future_index
			Future[i] = Null
		Next
		future_index = 0
	End Method
	
	Method ClearAll()
		Local i:Int
		For i = 0 Until index
			Past[i] = Null
		Next
		For i = 0 Until future_index
			Future[i] = Null
		Next
		index = -1
		future_index = -1
	End Method
	
End Type