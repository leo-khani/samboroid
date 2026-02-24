@tool
class_name Moon extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var kill_area_collision_shape_2d: CollisionShape2D = $KillArea/KillAreaCollisionShape2D


@export var rotation_speed: float = 1.0
@export var radius: float = 0.0: set = _update_collisions
@export var current_scale: float = 1: set = _update_scale

var base_scale: Vector2 = Vector2.ONE
var tween: Tween = null
var rotate_tween: Tween = null

func _ready():
	animate_rotation()

func _update_collisions(new_radius: float):
	if not is_node_ready():
		return

	collision_shape_2d.shape.radius = new_radius
	kill_area_collision_shape_2d.shape.radius = new_radius

func _update_scale(new_scale: float):
	if not is_node_ready():
		return

	current_scale = new_scale
	sprite_2d.scale = Vector2.ONE * current_scale
	base_scale = sprite_2d.scale
	


func animate_rotation():
	if not is_node_ready():
		return
		
	if rotate_tween:
		rotate_tween.kill()
	
	rotate_tween = create_tween().set_loops()
	rotate_tween.tween_property(sprite_2d, "rotation_degrees", 360.0 * rotation_speed + randf_range(5.0, 10.0), 60.0).as_relative()
