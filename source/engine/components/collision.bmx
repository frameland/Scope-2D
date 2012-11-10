'------------------------------------------------------------------------------
' Used for everything collision related
'------------------------------------------------------------------------------
Type TCollision

'------------------------------------------------------------------------------
' Properties
'------------------------------------------------------------------------------
	Field collidable:Int = False
	Field moving:Int = False
	Field radius:Float
	
	Field x1:Float
	Field y1:Float
	Field x2:Float
	Field y2:Float
	Field x3:Float
	Field y3:Float
	Field x4:Float
	Field y4:Float
	
	Field entity:TEntity
	
	Method Init( entityRef:TEntity )
		entity = entityRef
		UpdateBounds()
	End Method
	

	Method GetCopy:TCollision( ent:TEntity)
		Local c:TCollision = New TCollision
		c.x1 = x1
		c.y1 = y1
		c.x2 = x2
		c.y2 = y2
		c.x3 = x3
		c.y3 = y3
		c.x4 = x4
		c.y4 = y4
		c.collidable = collidable
		c.moving = moving
		c.radius = radius
		c.entity = ent
		Return c
	End Method


	Method UpdateBounds()
		x1 = -entity.image.handle_x * Pos( entity.scale.sx )
		y1 = -entity.image.handle_y * Pos( entity.scale.sy )
		x2 =  (entity.image.width - entity.image.handle_x) * Pos( entity.scale.sx )
		y2 = -entity.image.handle_y * Pos( entity.scale.sy )
		x3 =  (entity.image.width - entity.image.handle_x) * Pos( entity.scale.sx ) 
		y3 =  (entity.image.height - entity.image.handle_y) * Pos( entity.scale.sy )  
		x4 =  -entity.image.handle_x * Pos( entity.scale.sx )
		y4 =  (entity.image.height - entity.image.handle_y) * Pos( entity.scale.sy )
	End Method
	
'------------------------------------------------------------------------------
' Set radius with an optional multiplier (factor)
' ex: if you set an image with a radius of 100, and the factor to 1.2
' the radius will be 120
'------------------------------------------------------------------------------
	Method SetRadius( image:TImage, factor:Float = 1.0 )
		radius = (Max( image.width, image.height ) * 0.5) * factor
	EndMethod


'------------------------------------------------------------------------------
' Set if a collision is possible at all, and if Entity is moving
'------------------------------------------------------------------------------	
	Method Setup( collisionPossible:Int, movingEntity:Int )
		collidable = collisionPossible
		moving = movingEntity
	EndMethod
	

'------------------------------------------------------------------------------
' Update the 4 Points of the Entity
'------------------------------------------------------------------------------
	Method CollidesWithPoint:Int( px:Float, py:Float )
		px = px - entity.position.x
		py = py - entity.position.y
		Local tx:Float = px*Cos(-entity.rotation) - py*Sin(-entity.rotation) 
		Local ty:Float = py*Cos(-entity.rotation) + px*Sin(-entity.rotation)
		If tx > x1 And ty >y1 And tx < x3 And ty < y3
			Return True
		EndIf
		Return False
	End Method
	
EndType
