'------------------------------------------------------------------------------
' A common Interface for loading ressources
'------------------------------------------------------------------------------
Type TRessource

'------------------------------------------------------------------------------
' These properties have first to be set through their Setter Methods
'------------------------------------------------------------------------------
	Field dirData:String
	Field dirGraphics:String
	Field dirSounds:String
	Field dirFonts:String
	Field dirParticles:String


'------------------------------------------------------------------------------
' Setters
'------------------------------------------------------------------------------
	Method SetDataPath( path:String )
		dirData = path
	EndMethod
	
	Method SetGraphicPath( path:String )
		dirGraphics = path
	EndMethod
	
	Method SetSoundPath( path:String )
		dirSounds = path
	EndMethod
	
	Method SetFontPath( path:String )
		dirFonts = path
	EndMethod
	
	Method SetParticlePath( path:String )
		dirParticles = path
	EndMethod
	
	
'------------------------------------------------------------------------------
' Getters
'------------------------------------------------------------------------------
	Method Data:String()
		Return dirData + "/"
	EndMethod
	
	Method Graphic:String()
		Return dirData + "/" + dirGraphics + "/"
	EndMethod
	
	Method Sound:String()
		Return dirData + "/" + dirSounds + "/"
	EndMethod
	
	Method Font:String()
		Return dirData + "/" + dirFonts + "/"
	EndMethod
	
	Method Particle:String()
		Return dirData + "/" + dirParticles + "/"
	EndMethod
		
EndType

Global Ressource:TRessource = New TRessource
Ressource.SetDataPath( "data/" )
Ressource.SetGraphicPath( "graphics" )
Ressource.SetSoundPath( "sounds" )
Ressource.SetFontPath( "fonts" )
Ressource.SetParticlePath( "particles" )
