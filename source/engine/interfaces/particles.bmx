'------------------------------------------------------------------------------
' Update all Particles
'------------------------------------------------------------------------------
Function UpdateParticles()
	Local o:TParticleEffect
	For o = EachIn TParticleEffect.Effects
		o.Update()
	Next
EndFunction


'------------------------------------------------------------------------------
' Render all Particles
'------------------------------------------------------------------------------
Function RenderParticles( cam:TCamera )
	Local o:TParticleEffect
	For o = EachIn TParticleEffect.Effects
		o.Render( cam )
	Next
EndFunction





'------------------------------------------------------------------------------
' A normal particle
' You can extend this Type to make your own particles
'------------------------------------------------------------------------------
Type TParticle

'------------------------------------------------------------------------------
' Init components
'------------------------------------------------------------------------------
	Method New()
		position     = New TPosition
		dif_position = New TPosition
		scale        = New TScale
		color        = New TColor
		dead         = False
	EndMethod
	
	
'------------------------------------------------------------------------------
' Particle Properties
'------------------------------------------------------------------------------	
	Field position     : TPosition
	Field dif_position : TPosition
	Field angle        : Float
	Field dif_alpha    : Float
	Field color        : TColor
	Field scale        : TScale
	Field link         : TLink
	Field name         : String
	Field dead         : Int
	
EndType





'------------------------------------------------------------------------------
' Extend this Type for creating Particle Effects
' Particles:TList should contain all your TParticles or extended Type of TParticle
'------------------------------------------------------------------------------
Type TParticleEffect Abstract

'------------------------------------------------------------------------------
' Contains all TParticleEffects
'------------------------------------------------------------------------------
	Global Effects:TList = New TList


'------------------------------------------------------------------------------
' Contains all Particles of an Effect
'------------------------------------------------------------------------------
	Field Particles :  TList = New TList
	

'------------------------------------------------------------------------------
' Properties
'------------------------------------------------------------------------------	
	Field link  :TLink
	Field image :TImage
	Field blend :Int
	

'------------------------------------------------------------------------------
' A new TParticleEffect instance
'------------------------------------------------------------------------------	
	Method New()
		link = Effects.AddLast( Self )
		blend = ALPHABLEND
	EndMethod
	

'------------------------------------------------------------------------------
' Remove Self completely
'------------------------------------------------------------------------------	
	Method Remove()
		link.Remove()
	EndMethod
	
	
'------------------------------------------------------------------------------
' Every TParticleEffect has to inherit these Methods
'------------------------------------------------------------------------------
	Method Update() Abstract
	Method Render( cam:TCamera ) Abstract
	
EndType


