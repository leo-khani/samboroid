extends Node2D

@onready var left_btn: Button = %LeftBtn
@onready var lunch_btn: Button = %LunchBtn
@onready var right_btn: Button = %RightBtn
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var launch_controls: Control = %LaunchControls

@onready var mater_fluid_label: Label = %MaterFluidLabel
@onready var mater_fluid_progress_bar: ProgressBar = %MaterFluidProgressBar

@onready var asteroid = $Asteroid
@onready var trajectory_line = $TrajectoryLine
@onready var goal = $Goal

## How fast the aim rotates (degrees per second) when holding a button.
@export var aim_rotate_speed: float = 90.0
## Launch power applied to the asteroid.
@export var launch_power: float = 200.0
## Trajectory prediction range
@export var trajectory_range: float = 20.0


## Current aim angle in radians (0 = right, starts pointing up).
var aim_angle: float = -PI / 2.0
var can_shoot: bool = true
var rotating_left: bool = false
var rotating_right: bool = false

func _ready():
	goal.win.connect(_on_win)
	asteroid.freeze = true
	trajectory_line.visible = true

	left_btn.button_down.connect(func(): rotating_left = true)
	left_btn.button_up.connect(func(): rotating_left = false)
	right_btn.button_down.connect(func(): rotating_right = true)
	right_btn.button_up.connect(func(): rotating_right = false)
	lunch_btn.pressed.connect(_on_launch_pressed)
	asteroid.asteroid_destroyed.connect(func(): SignalHub.emit_level_failed(get_parent().current_level))

	SignalHub.planet_mass_added.connect(_update_mater_fluid)
	SignalHub.planet_mass_removed.connect(_update_mater_fluid)
	SignalHub.game_state_changed.connect(_on_game_state_changed)

	mater_fluid_progress_bar.max_value = get_parent().max_mass_fluid
	_update_mater_fluid(null)

	update_trajectory()

func _update_mater_fluid(_planet: Node):
	var _mass_fluid = get_parent().mass_fluid
	var _max_mass_fluid = get_parent().max_mass_fluid

	mater_fluid_label.text = str(_mass_fluid) + " / " + str(_max_mass_fluid)
	mater_fluid_progress_bar.value = _mass_fluid

func _on_win():
	if not GlobalData.level_scenes:
		print("No level scenes defined in GlobalData!")
		return
	print("LEVEL COMPLETE!")
	SignalHub.emit_level_completed(get_parent().current_level)

	await get_tree().create_timer(1.0).timeout

	var next_level = GlobalData.level_scenes.get(get_parent().current_level + 1, null)
	if next_level:
		SceneLoader.load_scene(next_level.resource_path)
	else:
		SceneLoader.load_scene(GlobalData.UI_WON_SCENE.resource_path)
	

func _process(delta: float):
	if not can_shoot:
		return

	var rotating = false

	if rotating_left:
		aim_angle -= deg_to_rad(aim_rotate_speed) * delta
		rotating = true
	if rotating_right:
		aim_angle += deg_to_rad(aim_rotate_speed) * delta
		rotating = true

	if rotating:
		update_trajectory()
	else: 
		audio_stream_player.stop()


func _on_launch_pressed():
	if not can_shoot:
		return
	can_shoot = false
	shoot_asteroid()


func shoot_asteroid():
	AudioManager.play_sfx(GlobalData.SFX_EXPLOSION_0, 1.0, 5.0)
	SignalHub.emit_camera_shake(GlobalEnum.ShakePreset.SMALL, 0.3)

	var launch_vector = Vector2.from_angle(aim_angle) * launch_power

	asteroid.freeze = false
	asteroid.linear_velocity = launch_vector
	asteroid.is_launched = true
	trajectory_line.visible = false
	SignalHub.emit_asteroid_shot()

	# Clear the trail
	if asteroid.has_node("Trail"):
		asteroid.get_node("Trail").clear_points()


func update_trajectory():
	if !audio_stream_player.playing:
		audio_stream_player.play()

	trajectory_line.visible = true
	trajectory_line.clear_points()

	var sim_pos = asteroid.global_position
	var sim_vel = Vector2.from_angle(aim_angle) * launch_power
	var dt = 1.0 / 60.0  # Must match physics tick rate

	# Cache planets and asteroid properties once
	var planets = get_tree().get_nodes_in_group("planets")
	var asteroid_mass = asteroid.mass

	# Godot's _integrate_forces callback runs AFTER position integration,
	# and apply_central_force queues the force for the NEXT step.
	# First step after launch has no queued gravity yet.
	var pending_gravity = Vector2.ZERO

	for i in range(trajectory_range):
		trajectory_line.add_point(trajectory_line.to_local(sim_pos))

		# 1. Apply pending gravity from previous step (acceleration = force / mass)
		sim_vel += (pending_gravity / asteroid_mass) * dt

		# 2. Update position
		sim_pos += sim_vel * dt

		# 3. Compute gravity at new position for next step (matches callback order)
		pending_gravity = Vector2.ZERO
		for planet in planets:
			var dir = planet.global_position - sim_pos
			var dist = dir.length()
			var safe_dist = max(dist, 30.0)
			var f = asteroid.G * planet.gravity_mass / (safe_dist * safe_dist)
			pending_gravity += dir.normalized() * f

		# 4. Apply drag (callback applies it after position update)
		if asteroid.drag > 0.0:
			sim_vel *= (1.0 - asteroid.drag * dt)

		# 5. Clamp to max speed
		if asteroid.max_speed > 0.0 and sim_vel.length() > asteroid.max_speed:
			sim_vel = sim_vel.normalized() * asteroid.max_speed

		# Stop at planet surface
		for planet in planets:
			if sim_pos.distance_to(planet.global_position) < planet.radius:
				return

func _input(event):
	if event.is_action_pressed("reload_level"):
		asteroid.take_damage()
		await get_tree().create_timer(1.0).timeout
		SignalHub.emit_level_failed(get_parent().current_level)

func _on_game_state_changed(new_state: GlobalEnum.GameState):
	match new_state:
		GlobalEnum.GameState.STRATEGY:
			launch_controls.show()
		_:
			launch_controls.hide()
