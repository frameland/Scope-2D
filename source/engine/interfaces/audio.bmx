Public
'------------------------------------------------------------------------------
' Initializes the Audio System
' Returns True when Setup was successful, else False
'------------------------------------------------------------------------------
Function SetupAudio:Int()
	Local driver_maxmod:String = "MaxMod RtAudio"
	If AudioDriverExists( driver_maxmod )
		SetAudioDriver( driver_maxmod )
		SetAudioStreamDriver( driver_maxmod )
	Else
		Return False
	EndIf
	?debug
		MaxModVerbose True
	?Not debug
		MaxModVerbose False
	?
	TAudioFader.SetUpdateRate( GetSettedUps() )
	Return True
EndFunction



'------------------------------------------------------------------------------
' Loads a new BG Music
'------------------------------------------------------------------------------
Function SetBGMusic:TBGMusic( file:String, loop:Int = True, paused:Int = False )
	If __music Then __music.channel.Stop()
	__music = New TBGMusic.Create( file, loop, paused )
	Return __music
EndFunction


'------------------------------------------------------------------------------
' Returns the current Background Music or Null when there is no BG Music
' Use this Function to get the TBGMusic Object. With this Object you
' can use the Methods of the TBGMusic Type.
' Example:
'------------------------------------------------------------------------------
' SetBGMusic( "song.ogg" )
' BGMusic().SetVolume( 0.8 )
' BGMusic().Pause()
'------------------------------------------------------------------------------
' Also possible:
'------------------------------------------------------------------------------
' my_music:TBGMusic = BGMusic()
' my_music.Pause()
'------------------------------------------------------------------------------
Function BGMusic:TBGMusic()
	?debug
		If Not __music
			DebugLog( "Failed to access the global BGMusic.~n" +..
			"Use SetBGMusic(..) first!" )
		EndIf
	?
	Return __music
EndFunction



'------------------------------------------------------------------------------
' Type for playing Background Music
'------------------------------------------------------------------------------
Type TBGMusic

'------------------------------------------------------------------------------
' The properties of TBGMusic
'------------------------------------------------------------------------------	
	Field channel:TChannel
	Field channel_volume:Float = 1.0
	Field channel_pan   :Float = 0.0
	Field channel_depth :Float = 0.0
	Field channel_rate  :Float = 1.0
	Field fader:TAudioFader


'------------------------------------------------------------------------------
' Returns a new TBGMusic
'------------------------------------------------------------------------------	
	Method Create:TBGMusic( file:String, loop:Int = True, paused:Int = False )
		?debug
			If Not FileType( file )
				Throw( "The sound file you wanted to load could not be found!~n"+..
				"Your specified sound file: " + file )
			EndIf
		?
		channel = PlayMusic( file, loop )
		If paused
			Pause()
		Else
			If Not Playing()
				Resume()
			EndIf
		EndIf
		Return Self
	EndMethod


'------------------------------------------------------------------------------
' Returns True if currently playing, else False
'------------------------------------------------------------------------------
	Method Playing:Int()
		Return channel.Playing()
	EndMethod
	

'------------------------------------------------------------------------------
' Pauses the BG Music
'------------------------------------------------------------------------------	
	Method Pause()
		channel.SetPaused( True )
	EndMethod
	

'------------------------------------------------------------------------------
' Resumes a paused BG Music
'------------------------------------------------------------------------------	
	Method Resume()
		channel.SetPaused( False )
	EndMethod
	

'------------------------------------------------------------------------------
' Fade Out Music
'------------------------------------------------------------------------------	
	Method FadeIn( time:Int = 1000, fromValue:Float = 0.0, toValue:Float = 1.0 )
		If Not Playing() Then Resume()
		fader = New TAudioFader
		fader.FadeIn( Self, time, fromValue, toValue )
	EndMethod
	

'------------------------------------------------------------------------------
' Fade In Music
'------------------------------------------------------------------------------	
	Method FadeOut( time:Int = 1000, fromValue:Float = 1.0, toValue:Float = 0.0 )
		fader = New TAudioFader
		fader.FadeOut( Self, time, fromValue, toValue )
	EndMethod
	

'------------------------------------------------------------------------------
' You only have to call this Method if you want to use the FadeIn/Out
' capabilities. Then it should be called every frame (of your game logic)
'------------------------------------------------------------------------------	
	Method UpdateFading()
		If (fader)
			If fader.dead
				fader = Null
				Return
			EndIf
			fader.Update()
		EndIf
	EndMethod
	


'------------------------------------------------------------------------------
' Setter Methods
' Set volume, pan, depth and rate
'------------------------------------------------------------------------------
	Method SetVolume( volume:Float )
		channel_volume = volume
		channel.SetVolume( volume )
	EndMethod
	
	Method SetPan( pan:Float )
		channel_pan = pan
		channel.SetPan( pan )
	EndMethod
	
	Method SetDepth( depth:Float )
		channel_depth = depth
		channel.SetDepth( depth )
	EndMethod
	
	Method SetRate( rate:Float )
		channel_rate = rate
		channel.SetRate( rate )
	EndMethod
	

'------------------------------------------------------------------------------
' Getter Methods
' Get volume, pan, depth and rate
'------------------------------------------------------------------------------	
	Method GetVolume:Float()
		Return channel_volume
	EndMethod
	
	Method GetPan:Float()
		Return channel_pan
	EndMethod
	
	Method GetDepth:Float()
		Return channel_depth
	EndMethod
	
	Method GetRate:Float()
		Return channel_rate
	EndMethod	
	
EndType





'------------------------------------------------------------------------------
' Private
'------------------------------------------------------------------------------
Private
Global __music:TBGMusic


'------------------------------------------------------------------------------
' Used for Fading Music In/Out
'------------------------------------------------------------------------------
Type TAudioFader
	
	Global update_rate:Int = 0
	Field modifier:Float
	Field music:TBGMusic
	Field to_value:Int
	Field dead:Int = False
	

'------------------------------------------------------------------------------
' Returns a fader Object which should be updated every frame
' (this means so many times you have set the UpdateRate)
'------------------------------------------------------------------------------
	Method FadeIn:TAudioFader( bgMusic:TBGMusic, fadeTime:Int = 1000, fromValue:Float = 0.0, toValue:Float = 2.0 )
		If (update_rate = 0)
			Throw( "Update Rate not set!~nUse TAudioFader.SetUpdateRate() first." )
		EndIf
		modifier = (fadeTime / 1000.0) * update_rate
		modifier = (toValue - fromValue) / modifier
		music = bgMusic
		to_value = toValue
		music.SetVolume( fromValue )
		Return Self
	EndMethod
	

'------------------------------------------------------------------------------
' Returns a fader Object which should be updated every frame
' (this means so many times you have set the UpdateRate)
'------------------------------------------------------------------------------
	Method FadeOut:TAudioFader( bgMusic:TBGMusic, fadeTime:Int = 1000, fromValue:Float = 1.0, toValue:Float = 0.0 )
		If (update_rate = 0)
			Throw( "Update Rate not set!~nUse TAudioFader.SetUpdateRate() first." )
		EndIf
		modifier = (fadeTime / 1000.0) * update_rate
		modifier = (fromValue - toValue) / modifier
		modifier = -modifier
		music = bgMusic
		to_value = toValue
		music.SetVolume( fromValue )
		Return Self
	EndMethod
	

'------------------------------------------------------------------------------
' This is called by BGMusic'S UpdateFading() Method
'------------------------------------------------------------------------------	
	Method Update()
		Local volume:Float = music.GetVolume() + modifier
		music.SetVolume( volume )
		If (modifier < 0)
			If (volume < to_value) Then dead = True
		Else
			If (volume > to_value) Then dead = True
		EndIf
	EndMethod


'------------------------------------------------------------------------------
' Sets the rate which the fader Object uses for internal calculations
' Set this to the equivalent of your FPS of your game logic
'------------------------------------------------------------------------------
	Function SetUpdateRate( rate:Int )
		update_rate = rate
	EndFunction
		
EndType


