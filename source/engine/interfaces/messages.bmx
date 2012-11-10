'------------------------------------------------------------------------------
' Messages can be sent to a TEntity directly or published to a TBoard
' They act as a communication system between these Objects
'------------------------------------------------------------------------------
Type TMessage

'------------------------------------------------------------------------------
' Items in these lists will get updated and sent or published as soon as
' the execution-time is met
'------------------------------------------------------------------------------	
	Global PendingSends:TList = New TList
	Global PendingPublishs:TList = New TList
	Global NextSendings:TList = New TList
	

'------------------------------------------------------------------------------
' Properties of a TMessage
'------------------------------------------------------------------------------
	Field id:String
	Field sender:Object
	Field receiver:Object
	Field content:Object
	Field execution_time:Int
	Field link:TLink
	

'------------------------------------------------------------------------------
' Create a new message
' For Send() sender and receiver have to be a TEntity
' For Publish() receiver has to be a TBoard
'------------------------------------------------------------------------------	
	Method Create:TMessage( sender:Object, receiver:Object, id:String, content:Object = Null, execution_time:Int = 0 )
		Self.sender = sender
		Self.receiver = receiver
		Self.id = id
		If (content)
			Self.content = content
		EndIf
		Self.execution_time = GetTime() + execution_time
		Return Self
	EndMethod
	

'------------------------------------------------------------------------------
' Send a message to an Entity directly
' If execution_time is greater than the current time it will get stored
' in the PendingSends:TList for later
'------------------------------------------------------------------------------	
	Method Send()
		If (execution_time < GetTime()+1)
			link = NextSendings.AddLast( Self )
			Return
		EndIf
		link = PendingSends.AddLast( Self )
	EndMethod
	

'------------------------------------------------------------------------------
' Publish a message to a Board (TBoard)
' If execution_time is greater than the current time it will get stored
' in the PendingPublishs:TList for later
'------------------------------------------------------------------------------
	Method Publish()
		If (execution_time < GetTime()+1)
			TBoard(receiver).Publish( Self )
			Return
		EndIf
		link = PendingPublishs.AddLast( Self )
	EndMethod	
	

'------------------------------------------------------------------------------
' Update all pending Messages
'------------------------------------------------------------------------------	
	Function Update()
		Local m:TMessage
		Local counter:Int = 0
		Local msg_limit:Int = 100 'update MessageTime every 200 messages
		UpdateTime()
		For m = EachIn NextSendings
			TEntity(m.receiver).logic.ProcessMessage( m )
			m.Remove()
			counter:+ 1
			If (counter > msg_limit)
				counter = 0
				UpdateTime()
			EndIf
		Next
		For m = EachIn PendingSends
			If (m.execution_time < GetTime()+1)
				TEntity(m.receiver).logic.ProcessMessage( m )
				m.Remove()
			EndIf
			counter:+ 1
			If (counter > msg_limit)
				counter = 0
				UpdateTime()
			EndIf
		Next
		For m = EachIn PendingPublishs
			If (m.execution_time < GetTime()+1)
				TBoard(m.receiver).Publish( m )
				m.Remove()
			EndIf
			counter:+ 1
			If (counter > msg_limit)
				counter = 0
				UpdateTime()
			EndIf
		Next
	EndFunction
	
'------------------------------------------------------------------------------
' Remove a message on from the List it is added to
'------------------------------------------------------------------------------
	Method Remove()
		link.Remove()
	EndMethod
	
EndType




'------------------------------------------------------------------------------
' A board represents a bridge between an Entity and other Interfaces
' To prevent direct linking with other objects or Types you publish
' content to such boards where they are sent to the receiver
' You can create an own TBoard by extending from this Type
'------------------------------------------------------------------------------
Type TBoard Abstract
	
'------------------------------------------------------------------------------
' All Boards are contained in this List
'------------------------------------------------------------------------------
	Global AllBoards:TList = New TList


'------------------------------------------------------------------------------
' Holds all Messages
'------------------------------------------------------------------------------	
	Field MessageList:TList = New TList


'------------------------------------------------------------------------------
' Automatically add all Boards to the AllBoards List
'------------------------------------------------------------------------------	
	Method New()
		AllBoards.AddLast(Self)
	EndMethod
	

'------------------------------------------------------------------------------
' Publish a Message
'------------------------------------------------------------------------------	
	Method Publish( message:TMessage )
		message.link = MessageList.AddLast( message )
	EndMethod
	

'------------------------------------------------------------------------------
' Every board has to implent an Update() Method where it processes all Messages
'------------------------------------------------------------------------------
	Method Update() Abstract


'------------------------------------------------------------------------------
' Remove a TBoard completely
'------------------------------------------------------------------------------
	Method Remove()
		AllBoards.Remove( Self )
	EndMethod
	
EndType





'------------------------------------------------------------------------------
' Update All Message Systems
'------------------------------------------------------------------------------
Function UpdateMessageSystem()
	TMessage.Update()
	Local board:TBoard
	For board = EachIn TBoard.AllBoards
		board.Update()
	Next
EndFunction


'------------------------------------------------------------------------------
' Update the Time for Message Systems
' This is done so not a costy call to MilliSecs() has to be made every time
'------------------------------------------------------------------------------
Function UpdateTime()
	PTime.time = Millisecs()
EndFunction


'------------------------------------------------------------------------------
' GetTime() to get Millisecs() (more efficient as it doesn't call Millisecs() every time)
' CheckTime() has to be in every message send to ensure expected behaviour
'------------------------------------------------------------------------------
Type PTime
	Global time:Int
	Function SetTime( value:Int )
		time = value
	EndFunction
EndType

Function GetTime:Int()
	Return PTime.time
EndFunction

