Type TPublicInfo
	
	Field InfoMap:TMap = New TMap
	
	
	Method Upload( id:String, content:Object )
		InfoMap.Insert( id, content )
	EndMethod
	
	Method Download:Object( id:String )
		?Debug
		If InfoMap.Contains( id )
			DebugLog( "The Public-Info: " + id + " was not found!" )	
		EndIf
		?
		Return InfoMap.ValueForKey( id )
	EndMethod
	
EndType


Global __PublicInfo:TPublicInfo = New TPublicInfo
Function UploadPublicInfo( id:String, content:Object )
	__PublicInfo.Upload( id, content )
EndFunction

Function DownloadPublicInfo:Object( id:String )
	Return __PublicInfo.Download( id )
EndFunction
