'------------------------------------------------------------------------------
' Basic Entity
'------------------------------------------------------------------------------
Type TEntity

'------------------------------------------------------------------------------
' Properties of an Entity
'------------------------------------------------------------------------------	
	Field position:TPosition
	Field image:TImage
	
	Field scale:TScale
	Field flipH:Byte
	Field flipV:Byte
	
	Field rotation:Float
	Field color:TColor
	Field size:TSize
	Field layer:Int = 1
	Field link:TLink
	Field name:String
	Field static:Int = True
	Field visible:Int = True
	Field active:Int = False
	Field collision:TCollision
	Field texturePath:String
	Field frame:Int = 0
	
	'Object Props
	Field inFront:Byte = False
	Field isBaseline:Byte = False
	Field isParticle:Byte = False
	Field allowObjectTriggering:Byte = False
	
	
'--------------------------------------------------------------------------
' * For editor
'--------------------------------------------------------------------------
	Field selection:TSelection
	Field memory_position:TPosition
	Field memory_scale:TScale
	Field memory_rotation:Float
	Field memory_alpha:Float
	

'------------------------------------------------------------------------------
' Create an Entity
'------------------------------------------------------------------------------
	Method New()
		position = New TPosition
		scale = New TScale
		color = New TColor
		size = New TSize
		selection = New TSelection
		collision = New TCollision
		memory_position = New TPosition
		memory_scale = New TScale
	EndMethod

'--------------------------------------------------------------------------
' * After loading image finished
'--------------------------------------------------------------------------
	Method AfterPicLoading()
		SetSize( image.width, image.height )
		MidHandleImage( image )
		selection.Init(Self)
		collision.Init( Self )
	End Method
	
'------------------------------------------------------------------------------
' Remove the Entity from the World
'------------------------------------------------------------------------------	
	Method Remove()
	    link.Remove()
	EndMethod
	

'------------------------------------------------------------------------------
' Every Entity is rendered through this Method
'------------------------------------------------------------------------------
	Method Render( cam:TCamera )
		If (image = Null)
			Return
		EndIf
		Local sx:Float = 1.0
		Local sy:Float = 1.0
		If flipH Then sx = -1.0
		If flipV Then sy = -1.0
		.SetScale (scale.sx * cam.position.z * sx, scale.sy * cam.position.z * sy)
		.SetRotation( rotation )
		If (color.a = 0.0) Or (visible = False) Then Return
		.SetAlpha( color.a )	
		.SetColor( color.r, color.g, color.b )
		.SetBlend( color.blend )
		DrawImage( image, (position.x * cam.position.z) - (cam.position.x * cam.position.z) + cam.screen_center_x,..
		(position.y * cam.position.z) - (cam.position.y * cam.position.z) + cam.screen_center_y, frame )
	EndMethod


'--------------------------------------------------------------------------
' * Setters
'--------------------------------------------------------------------------
	Method SetImage( url:Object, flags:Int = -1 )
		image = TManagedImage.Load( url, flags )
		texturePath = url.ToString()
		If image
			AfterPicLoading()
		EndIf
	EndMethod
	
	Method SetAnimImage( url:Object, cell_width:Int, cell_height:Int, first_cell:Int, cell_count:Int, flags:Int = -1 )
		image = TManagedImage.LoadAnim( url:Object, cell_width:Int, cell_height:Int, first_cell:Int, cell_count:Int, flags:Int )
		texturePath = url.ToString()
		AfterPicLoading()
	EndMethod
	
	Method SetPosition( x:Float, y:Float )
		position.Set( x, y )
	EndMethod
	
	Method SetRotation( rot:Float )	
		rotation = rot
	End Method
	
	Method SetScale( x:Float, y:Float )
		scale.Set( x, y )
		size.Set( image.width * Pos(x), image.height * Pos(y) )
		collision.UpdateBounds()
		If selection
			selection.UpdateRadius()
		EndIf
	EndMethod
	
	Method SetSize( x:Float, y:Float )
		size.Set( x, y )
	EndMethod

	Method SetColor( r:Byte, g:Byte, b:Byte )  
		color.SetRGB( r, g, b )
	EndMethod
	
	Method SetLayer( value:Int )
		layer = value
	EndMethod
	
	Method SetVisible( state:Int )
		visible = state
	End Method
	
	Method SetActive( state:Int )
		active = state
	End Method
	
	Method SetName( newName:String )
		name = newName
	End Method
	
	Method SetFrame( frame:Int )
		Self.frame = frame
	End Method

'------------------------------------------------------------------------------
' * Getters
'------------------------------------------------------------------------------
	Method GetName:String()
		Return name
	EndMethod

	Method GetVertices:Int[]()
		Local verts:Int[8]
		Local rad:Float = 0.5 * Sqr (size.height * size.height + size.width * size.width)
		Local theta0:Float = ATan2 (size.height, size.width)
		Local theta1:Float = 180.0 - theta0
		Local x0:Float = rad * Cos( theta0 + rotation)
		Local y0:Float = rad * Sin( theta0 + rotation)
		Local x1:Float = rad * Cos( theta1 + rotation)
		Local y1:Float = rad * Sin( theta1 + rotation)
		
		'Top Left
		verts[ 0 ] = position.x - x0
		verts[ 1 ] = position.y - y0
		
		'Top Right
		verts[ 2 ] = position.x - x1
		verts[ 3 ] = position.y - y1
		
		'Bottom Left
		verts[ 4 ] = position.x + x1
		verts[ 5 ] = position.y + y1		
		
		'Bottom Right
		verts[ 6 ] = position.x + x0
		verts[ 7 ] = position.y + y0

		Return verts
	End Method
	
	
'--------------------------------------------------------------------------
' * Memory Methods
'--------------------------------------------------------------------------
	Method SavePosition()
		memory_position.Set( position.x, position.y )
	End Method
	
	Method SaveRotation()
		memory_rotation = rotation
	End Method
	
	Method SaveScale()
		memory_scale.Set( scale.sx, scale.sy )
	End Method
	
	Method SaveAlpha()
		memory_alpha = color.a
	End Method
	
	
EndType

