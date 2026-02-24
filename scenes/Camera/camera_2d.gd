extends Camera2D

enum Mode { STRATEGY, FOLLOW }

var current_mode: Mode = Mode.STRATEGY

## Arrow key pan speed in pixels per second.
@export var pan_speed: float = 400.0
## How smoothly the camera lerps to the asteroid in follow mode (higher = snappier).
@export var follow_smoothing: float = 8.0

#region Zoom
## Minimum zoom level (most zoomed-in).
@export var zoom_min: float = 0.5
## Maximum zoom level (most zoomed-out).
@export var zoom_max: float = 3.0
## How much each scroll step changes the zoom.
@export var zoom_step: float = 0.1
## How fast the zoom lerps to its target (higher = snappier).
@export var zoom_smoothing: float = 8.0

var _target_zoom: float = 1.0
#endregion

#region Shake
## Current shake intensity (pixels). Decays over time.
var _trauma: float = 0.0
## Maximum offset in pixels for the shake.
var _max_offset: float = 0.0
## How fast trauma decays per second (higher = shorter shake).
var _decay_rate: float = 0.0
## Noise-based time accumulator for organic feel.
var _noise_t: float = 0.0

## FastNoiseLite for smooth, organic shake movement.
var _noise: FastNoiseLite

# --- Preset config: [max_offset, trauma, decay_rate] ---
const SHAKE_CONFIG := {
	GlobalEnum.ShakePreset.SMALL:  [4.0, 0.4, 2.0],
	GlobalEnum.ShakePreset.MEDIUM: [10.0, 0.7, 1.5],
	GlobalEnum.ShakePreset.LARGE:  [20.0, 1.0, 1.0],
}
#endregion


func _ready() -> void:
	_noise = FastNoiseLite.new()
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = 1.5
	_noise.seed = randi()

	SignalHub.camera_shake.connect(_on_camera_shake)
	SignalHub.asteroid_shot.connect(_on_asteroid_shot)
	#SignalHub.game_state_changed.connect(_on_asteroid_shot)


	_target_zoom = zoom.x

	# Start in strategy mode: detach from parent transform so arrow keys control position
	set_mode(Mode.STRATEGY)


func _process(delta: float) -> void:
	match current_mode:
		Mode.STRATEGY:
			_process_strategy(delta)
		_:
			offset = Vector2.ZERO  # Reset any manual offset; shake will be applied separately
			_process_follow(delta)

	_process_zoom(delta)
	_process_shake(delta)


#region Mode switching
func set_mode(new_mode: Mode) -> void:
	current_mode = new_mode
	match new_mode:
		Mode.STRATEGY:
			# Detach from parent so position is independent
			top_level = true
			position_smoothing_enabled = false
		_:
			print("Switching to FOLLOW mode")
			# Re-attach to parent (Asteroid) so we follow it
			top_level = false
			offset = Vector2.ZERO
			position = Vector2.ZERO


func _on_asteroid_shot() -> void:
	set_mode(Mode.FOLLOW)
#endregion


#region Zoom
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_target_zoom = clampf(_target_zoom - zoom_step, zoom_min, zoom_max)
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_target_zoom = clampf(_target_zoom + zoom_step, zoom_min, zoom_max)


func _process_zoom(delta: float) -> void:
	var new_zoom: float = lerpf(zoom.x, _target_zoom, zoom_smoothing * delta)
	zoom = Vector2(new_zoom, new_zoom)
#endregion


#region Strategy mode — arrow key panning
func _process_strategy(delta: float) -> void:
	var input_dir := Vector2.ZERO

	if Input.is_action_pressed("camera_left"):
		input_dir.x -= 1.0
	if Input.is_action_pressed("camera_right"):
		input_dir.x += 1.0
	if Input.is_action_pressed("camera_up"):
		input_dir.y -= 1.0
	if Input.is_action_pressed("camera_down"):
		input_dir.y += 1.0

	if input_dir != Vector2.ZERO:
		global_position += input_dir.normalized() * pan_speed * delta
#endregion


#region Follow mode — follow the parent (Asteroid)
func _process_follow(delta: float) -> void:
	# Camera is a child of Asteroid, so with top_level = false it already follows.
	# Nothing extra needed; shake offset is applied separately.
	pass
#endregion


#region Shake
func _process_shake(delta: float) -> void:
	if _trauma <= 0.0:
		offset = Vector2.ZERO
		return

	# Advance noise time
	_noise_t += delta * 60.0

	# Shake amount uses trauma squared for a nice exponential feel
	var shake: float = _trauma * _trauma * _max_offset

	# Sample two independent noise axes for organic, non-repetitive motion
	var offset_x: float = _noise.get_noise_2d(_noise_t, 0.0) * shake
	var offset_y: float = _noise.get_noise_2d(0.0, _noise_t) * shake

	# Pixel-perfect: round to whole pixels
	offset = Vector2(roundf(offset_x), roundf(offset_y))

	# Decay trauma
	_trauma = maxf(_trauma - _decay_rate * delta, 0.0)


func _on_camera_shake(shake_preset: GlobalEnum.ShakePreset, _duration: float) -> void:
	var config: Array = SHAKE_CONFIG.get(shake_preset, [0.0, 0.0, 1.0])
	_max_offset = config[0]
	# Stack trauma additively, clamp to 1.0 for safety
	_trauma = minf(_trauma + config[1], 1.0)
	_decay_rate = config[2]
#endregion