@tool
class_name Planet extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var gravity_field: ColorRect = $GravityField
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var selection_area_collision_shape_2d: CollisionShape2D = $SelectionArea/SelectionAreaCollisionShape2D

@export var rotation_speed: float = 1.0
@export var hover_outline_color: Color = Color(1, 1, 1, 0.8)
@export var hover_outline_thickness: float = 3.0

## The planet's mass (display value). Radius is derived from this automatically.
@export var mass: float = 200.0:
	set(value):
		mass = value
		_update_planet()

## Factor to convert mass into visual radius: radius = sqrt(mass) * radius_scale.
@export var radius_scale: float = 1.414

## Multiplier for the gravity field / collision shape relative to the planet radius.
@export var gravity_field_multiplier: float = 5.0

## Multiplier applied to mass for gravity calculations (gameplay tuning).
const GRAVITY_MASS_SCALE := 100.0

## Computed radius — derived from mass, not set directly.
var radius: float = 0.0

## The mass value used in gravity calculations (mass × 100).
var gravity_mass: float:
	get: return mass * GRAVITY_MASS_SCALE

@export var is_hovered: bool = false:
	set(value):
		is_hovered = value

var base_scale: Vector2 = Vector2.ONE

var tween: Tween = null
var outline_tween: Tween = null
var scale_tween: Tween = null

func _ready():
	_update_planet()
	animate_planet()
	base_scale = sprite_2d.scale


func add_mass(amount: float):
	mass += amount  # Triggers setter → recalculates radius

func remove_mass(amount: float):
	mass = max(mass - amount, 0)  # Triggers setter → recalculates radius


func _update_planet():
	# Derive radius from mass
	radius = sqrt(max(mass, 0.0)) * radius_scale

	# Setter runs before _ready(), so nodes aren't available yet
	if not is_node_ready():
		return

	# 1. Gravity collider (CollisionShape2D) — defines the gravity field range
	var gravity_radius = radius * gravity_field_multiplier
	if not collision_shape_2d.shape is CircleShape2D:
		collision_shape_2d.shape = CircleShape2D.new()
	collision_shape_2d.shape.radius = gravity_radius

	# 2. Gravity field visual — match collision shape exactly (diameter as size)
	var gravity_diameter = gravity_radius * 2
	gravity_field.size = Vector2(gravity_diameter, gravity_diameter)
	gravity_field.position = -gravity_field.size / 2

	# 3. Sprite scale to match the planet's visual radius
	var sprite_size = sprite_2d.texture.get_size().x
	sprite_2d.scale = Vector2.ONE * (radius * 2 / sprite_size)

	# 4. Selection area — slightly larger than the visual radius for better UX
	var selection_radius = radius * 1.5
	if not selection_area_collision_shape_2d.shape is CircleShape2D:
		selection_area_collision_shape_2d.shape = CircleShape2D.new()
	selection_area_collision_shape_2d.shape.radius = selection_radius


func set_outline(is_active: bool):
	var outline_thickness = hover_outline_thickness if is_active else 0.0
	var shader_material = sprite_2d.material
	var scale_factor = 1.1 * base_scale if is_active else base_scale

	if outline_tween:
		outline_tween.kill()


	outline_tween = create_tween()
	outline_tween.tween_property(shader_material, "shader_parameter/outline_thickness", outline_thickness, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)

	if scale_tween:
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.tween_property(sprite_2d, "scale", scale_factor, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)


func animate_planet():
	if tween:
		tween.kill()
	
	tween = create_tween().set_loops()
	tween.tween_property(sprite_2d, "rotation_degrees", rotation_degrees + 360, 120.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_selection_area_mouse_entered():
	print("Mouse entered planet selection area") # Debug print
	is_hovered = true
	set_outline(is_hovered)
	SignalHub.emit_mouse_hover_entered()


func _on_selection_area_mouse_exited():
	is_hovered = false
	set_outline(is_hovered)
	SignalHub.emit_mouse_hover_exited()


func _input(event):
	if event.is_action_pressed("left_click") and is_hovered:
		print("Mouse clicked on planet") # Debug print
		SignalHub.emit_planet_mass_added(self) # Example mass addition, adjust as needed

	if event.is_action_pressed("right_click") and is_hovered:
		print("Mouse clicked on planet") # Debug print
		SignalHub.emit_planet_mass_removed(self) # Example mass removal, adjust as needed

func _on_selection_area_body_entered(body):
	if body.is_in_group("asteroid"):
		print("Asteroid entered planet selection area") # Debug print
		if body.has_method("take_damage"):
			body.take_damage() # Example damage value, adjust as needed

func _on_selection_area_body_exited(_body):
	pass # Replace with function body.
