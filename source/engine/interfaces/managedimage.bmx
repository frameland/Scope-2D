'------------------------------------------------------------------------------
' Used so images are not loaded twice
' How to use: my_image:TImage = TManagedImage.Load( path )
'------------------------------------------------------------------------------
Type TManagedImage

'------------------------------------------------------------------------------
' This TMap contains all images already loaded
' key: path:String | value: image:TImage
'------------------------------------------------------------------------------	
	Global RessourceMap:TMap = New TMap
	
	
'------------------------------------------------------------------------------
' Lookup in the RessourceMap if the TImage is already loaded
' If loaded     => Return the already loaded Image
' If Not loaded => Return the newly loaded Image
'------------------------------------------------------------------------------
	Function Load:TImage( path:Object, flags:Int = -1 )
		If RessourceMap.Contains( path )
			Return TImage( RessourceMap.ValueForKey( path ) )
		Else
			Local image:TImage = LoadImage( path, flags )
			RessourceMap.Insert( path, image )
			Return image
		EndIf
	EndFunction
	

'------------------------------------------------------------------------------
' Same as above but with AnimImage
'------------------------------------------------------------------------------	
	Function LoadAnim:TImage( path:Object, cell_width:Int, cell_height:Int, first_cell:Int, cell_count:Int, flags:Int = -1 )
		If RessourceMap.Contains( path )
			Return TImage( RessourceMap.ValueForKey( path ) )
		Else
			Local image:TImage = LoadAnimImage( path, cell_width, cell_height, first_cell, cell_count, flags = -1 )
			RessourceMap.Insert( path, image )
			Return image
		EndIf
	EndFunction
	

'------------------------------------------------------------------------------
' Remove the image with the speciefied path
'------------------------------------------------------------------------------
	Function Remove( path:Object )
		If RessourceMap.Contains( path )
			RessourceMap.Remove( path )
			Return
		EndIf
		?debug
		DebugLog( "The image at " + path.ToString() + " could not be removed." )
		?
	EndFunction
	
	
'------------------------------------------------------------------------------
' Clear the RessourceMap of all loaded TImages
' Info: You still have to manually clear all other references to TImages
'       in your own Types
'------------------------------------------------------------------------------	
	Function Reset()
		RessourceMap.Clear()
	EndFunction
	
EndType
