extends Camera2D

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


func _ready() -> void:
	_noise = FastNoiseLite.new()
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = 1.5
	_noise.seed = randi()
	SignalHub.camera_shake.connect(_on_camera_shake)


func _process(delta: float) -> void:
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