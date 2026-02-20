extends Node2D

@onready var asteroid = $Asteroid
@onready var trajectory_line = $TrajectoryLine
@onready var goal = $Goal

var is_dragging = false
var start_drag_pos = Vector2.ZERO
var launch_power_multiplier = 0.5 # Adjust for sensitivity

func _ready():
	goal.win.connect(_on_win)
	asteroid.freeze = true # Start frozen until shot
	trajectory_line.visible = false

func _on_win():
	print("LEVEL COMPLETE!")
	# Add restart logic or next level logic here
	get_tree().reload_current_scene()

func _input(event):
	# Start Drag
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Only shoot if the asteroid is currently frozen (not shot yet)
		if asteroid.freeze:
			is_dragging = true
			start_drag_pos = event.position
			SignalHub.emit_camera_shake(GlobalEnum.ShakePreset.SMALL, 0.3) # Shake on drag start
	
	# End Drag (Shoot)
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_dragging:
			is_dragging = false
			shoot_asteroid(event.position)
	
	# Update trajectory while dragging
	if event is InputEventMouseMotion and is_dragging:
		update_trajectory(event.position)

func shoot_asteroid(mouse_pos: Vector2):
	# Calculate velocity vector (Direction is from Mouse to Asteroid)
	var launch_vector = (asteroid.global_position - mouse_pos) * launch_power_multiplier
	
	asteroid.freeze = false
	asteroid.linear_velocity = launch_vector
	trajectory_line.visible = false
	
	# Clear the trail
	if asteroid.has_node("Trail"):
		asteroid.get_node("Trail").clear_points()

func update_trajectory(mouse_pos: Vector2):
	trajectory_line.visible = true
	trajectory_line.clear_points()
	
	# Simulate the path
	var sim_pos = asteroid.global_position
	var sim_vel = (asteroid.global_position - mouse_pos) * launch_power_multiplier
	var dt = get_physics_process_delta_time()
	
	# Simulate 150 steps into the future
	for i in range(150):
		trajectory_line.add_point(sim_pos)
		
		# --- SIMULATE PHYSICS STEP ---
		# 1. Apply Gravity
		var gravity_force = Vector2.ZERO
		var planets = get_tree().get_nodes_in_group("planets")
		for planet in planets:
			var dir = planet.global_position - sim_pos
			var dist = dir.length()
			if dist < 10: dist = 10
			var f = 500.0 * planet.mass / (dist * dist)
			gravity_force += dir.normalized() * f
		
		sim_vel += gravity_force * dt
		sim_pos += sim_vel * dt
		
		# 2. Check Collision with Planets (Rough check)
		for planet in planets:
			if sim_pos.distance_to(planet.global_position) < planet.radius:
				return # Stop drawing if it hits a planet
