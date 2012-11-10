'------------------------------------------------------------------------------
' Extract the Red Value out of the integer
'------------------------------------------------------------------------------
Function ExtractRed:Int( value:Int )
	Return (value & $000000FF)
EndFunction


'------------------------------------------------------------------------------
' Extract the Green Value out of the integer
'------------------------------------------------------------------------------
Function ExtractGreen:Int( value:Int )
	Return (value & $0000FF00) Shr 8
EndFunction


'------------------------------------------------------------------------------
' Extract the Blue Value out of the integer
'------------------------------------------------------------------------------
Function ExtractBlue:Int( value:Int )
	Return (value & $00FF0000) Shr 16
EndFunction


'------------------------------------------------------------------------------
' Extract the Alpha Value out of the integer
'------------------------------------------------------------------------------
Function ExtractAlpha:Int( value:Int )
	Return (value & $FF000000) Shr 24
EndFunction


'------------------------------------------------------------------------------
' Stores red, green and blue Values in an integer
'------------------------------------------------------------------------------
Function StoreRGB:Int( r:Int , g:Int , b:Int )
	Return r + (g Shl 8) + (b Shl 16) + (255 Shl 24)
End Function


'------------------------------------------------------------------------------
' Stores red, green, blue and alpha Values in an integer
'------------------------------------------------------------------------------
Function StoreRGBA:Int( r:Int , g:Int , b:Int , a:Int )
	Return r + (g Shl 8) + (b Shl 16) + (a Shl 24)
End Function


