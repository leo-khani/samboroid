extends RigidBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cpuparticles_2d: CPUParticles2D = $CPUParticles2D
@onready var tail_particle: CPUParticles2D = $TailParticle

# Gravity constant - Tweak this to change how strong gravity feels
const G = 400.0 

## Maximum speed the asteroid can reach (pixels/sec). 0 = no limit.
@export var max_speed: float = 0.0
## Linear drag applied each physics frame. Higher = slows down faster. 0 = no drag.
@export var drag: float = 0.0

var is_dead: bool = false
var is_launched: bool = false: set = _set_launched

var collect_tween: Tween

signal asteroid_destroyed

func _set_launched(value: bool):
	is_launched = value
	if is_launched:
		SignalHub.emit_asteroid_shot()
		tail_particle.emitting = true
	else:
		tail_particle.emitting = false

	


func _ready():
	# To prevent lagging
	cpuparticles_2d.duplicate()
	tail_particle.duplicate()

func _integrate_forces(state):
	# Calculate gravity manually
	var total_gravity = Vector2.ZERO
	var planets = get_tree().get_nodes_in_group("planets")
	
	for planet in planets:
		var direction = planet.global_position - global_position
		var distance = direction.length()
		
		# Prevent dividing by zero or extreme forces if inside the planet
		# The 'radius' variable needs to be accessible from the planet script
		# For now, we use a safe minimum distance
		var safe_dist = max(distance, 30.0) 
		
		# Inverse Square Law: F = G * M / r^2
		var force_magnitude = G * planet.gravity_mass / (safe_dist * safe_dist)
		
		total_gravity += direction.normalized() * force_magnitude

	# Apply the force
	state.apply_central_force(total_gravity)

	# Apply drag to slow down over time
	if drag > 0.0:
		state.linear_velocity *= (1.0 - drag * state.step)

	# Clamp speed to max_speed
	if max_speed > 0.0 and state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed

## This destroys the asteroid on collision with a planet, you can replace it with damage logic if you want
func take_damage():
	if is_dead:
		return

	tail_particle.emitting = false
	
	is_dead = true
	AudioManager.play_sfx(GlobalData.SFX_LOW_EXPLOSION_0, 1.0, 10.0)
	SignalHub.emit_camera_shake(GlobalEnum.ShakePreset.LARGE, 0.7)
	set_physics_process(false) # Stop physics processing to freeze movement
	set_process(false) # Stop any other processing if needed

	set_deferred("freeze", true) # Freeze the RigidBody2D to stop all movement
	# Stop all physics movement instantly
	sprite_2d.visible = false
	await get_tree().create_timer(0.1).timeout # Wait for shake to finish
	cpuparticles_2d.emitting = true
	await get_tree().create_timer(1.5).timeout
	asteroid_destroyed.emit()

func collect():
	if is_dead:
		return

	tail_particle.emitting = false

	AudioManager.play_sfx(GlobalData.SFX_SLIME_0, 1.0, 10.0)

		# Scale up
	if collect_tween:
		collect_tween.kill()

	collect_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	collect_tween.tween_property(self, "scale", sprite_2d.scale * 1.1, 0.1)
	collect_tween.tween_property(self, "scale", Vector2.ZERO, 0.4)

	await collect_tween.finished


	SignalHub.emit_camera_shake(GlobalEnum.ShakePreset.SMALL, 0.5)
	sprite_2d.visible = false
	set_physics_process(false) # Stop physics processing to freeze movement
	set_process(false) # Stop any other processing if needed

	set_deferred("freeze", true)

	

	