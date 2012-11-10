'------------------------------------------------------------------------------
' Returns the Distance of 2 Points in a 2D Space
'------------------------------------------------------------------------------
Function DistanceOfPoints:Float( x1:Float, y1:Float, x2:Float, y2:Float )
	Return Sqr( ((x1-x2)*(x1-x2)) + ((y1-y2)*(y1-y2)) )
End Function

Function AngleOfPoints:Float( x1:Float, y1:Float, x2:Float, y2:Float )
	Local deltaY:Float = x1 - x2
	Local deltaX:Float = y1 - y2
	Local direction:Float = -ATan2(deltaY, deltaX)+90
	Return direction
End Function


'------------------------------------------------------------------------------
' Returns True if the 2 Circles collide, else False
'------------------------------------------------------------------------------
Function CirclesCollide:Int( x1:Float, y1:Float, r1:Float, x2:Float, y2:Float, r2:Float )
	If (Sqr(((x1-x2)*(x1-x2))+((y1-y2)*(y1-y2))) - r1 - r2) < 0
		Return True
	EndIf
	Return False
EndFunction


'------------------------------------------------------------------------------
' Returns True if the 2 Rects collide, else False
'------------------------------------------------------------------------------
Function RectsCollide:Int( x1:Float, y1:Float, w1:Float, h1:Float, x2:Float, y2:Float, w2:Float, h2:Float)
	Local x_1:Float = Min( x1,x2 )
	Local x_2:Float = Max( x1,x2 )
	Local y_1:Float = Min( y1,y2 )
	Local y_2:Float = Max( y1,y2 )
	w1:*0.5 ; w2:*0.5
	h1:*0.5 ; h2:*0.5
	If (x_2 - x_1 - w1 - w2) > 0 Then Return False
	If (y_2 - y_1 - h1 - h2) > 0 Then Return False
	Return True
EndFunction

'--------------------------------------------------------------------------
' * Return True if specified point is inside the Rectangle, else False
'--------------------------------------------------------------------------
Function PointInRect:Int( pX:Float, pY:Float, x:Float, y:Float, w:Float, h:Float )
	If (pX > x) And (pX < x+w) And (pY > y) And (pY < y+h)
		Return True
	EndIf
	Return False
End Function



Rem
	bbdoc: check if a number is equal (bfw)
End Rem
Function IsEqual:Int(Number:Int)
	Return (Number Mod 2 = 0)
End Function

Rem
	bbdoc: check if a number is not equal(bfw)
End Rem
Function IsNotEqual:Int(Number:Int)
	Return (Number Mod 2 > 0)
End Function

'--------------------------------------------------------------------------
' * Ensures value is Positive
'--------------------------------------------------------------------------
Function Pos:Float( value:Float )
	If value > 0
		Return value
	EndIf
	Return -value
End Function


'--------------------------------------------------------------------------
' * Returns a trimmed Float number
' * digits: number of digits after the comma
'--------------------------------------------------------------------------
Function TrimFloat:Float( value:Float, digits:Int = 2 )
	Local index:Int = String(value).Find(".",1)
	Return Float(String(value)[..index+digits+1])
End Function



