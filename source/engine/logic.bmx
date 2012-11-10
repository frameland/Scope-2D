'------------------------------------------------------------------------------
' Every other Logic Extends TLogic
'------------------------------------------------------------------------------
Type TLogic Abstract

'------------------------------------------------------------------------------
' A link to the entity to update
'------------------------------------------------------------------------------
	Field entity:TEntity
	

'------------------------------------------------------------------------------
' Every Logic has to update it's linked Entity with this Method
'------------------------------------------------------------------------------
	Method Update() Abstract
	Method ProcessMessage( message:TMessage ) Abstract
		
EndType
