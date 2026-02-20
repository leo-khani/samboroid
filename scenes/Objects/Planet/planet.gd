@tool
class_name Planet extends StaticBody2D

## This value will be used in the asteroid's gravity calculations.
## It is multiplied by 1000 to make the gravity stronger for gameplay purposes. Adjust as needed.
@export var mass: float = 200.0:
	set(value):
		mass = value * 1000.0
		
@export var radius: float = 50.0: set = update_radius

func _ready():
	# Ensure collision matches the visual radius
	#$CollisionShape2D.shape.radius = radius
	
	# Visuals: scale the sprite to match radius
	# Assuming your sprite texture is originally 64px or similar
	pass

func update_radius(new_radius: float):
	# 1. Update the actual collision shape radius
	$CollisionShape2D.shape.radius = new_radius
	
	# 2. Calculate the sprite scale to match the new diameter
	var sprite_size = $Sprite2D.texture.get_size().x
	$Sprite2D.scale = Vector2.ONE * (new_radius * 2 / sprite_size)