## UIAnimationComponent.gd
## Fixed version: Correctly handles position resets for nodes inside containers.
class_name UIAnimationComponent extends Node

#region Signals
signal animation_started(anim_name: String)
signal animation_finished(anim_name: String)
#endregion

#region Enums
enum AnimationType {
	NONE,       ## No animation.
	SCALE,      ## Scales the node up or down.
	ROTATE,     ## Rotates the node.
	SHAKE,      ## Shakes the node horizontally/vertically.
	PULSE,      ## A continuous heartbeat scale effect.
	FADE,       ## Fades the modulate alpha.
	BOUNCE      ## Bounces the scale.
}

enum TriggerType {
	ON_START,   ## Plays automatically when the scene loads.
	ON_HOVER    ## Plays when the mouse enters the parent Control.
}
#endregion

#region Export Variables
@export var animation_type: AnimationType = AnimationType.NONE
@export var trigger: TriggerType = TriggerType.ON_START
@export_range(0.0, 5.0) var duration: float = 0.5
@export_range(0.0, 5.0) var delay: float = 0.0
@export var magnitude: float = 1.2
@export var loop: bool = false
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
@export var trans_type: Tween.TransitionType = Tween.TRANS_QUAD
#endregion

#region Internal Variables
var _target_control: Control
var _active_tween: Tween
var _initial_properties: Dictionary = {} 
var _is_hovering: bool = false
#endregion

#region Lifecycle Methods
func _ready() -> void:
	if not get_parent() is Control:
		push_error("UIAnimationComponent must be a child of a Control node.")
		return
		
	_target_control = get_parent()

	_target_control.pivot_offset_ratio = Vector2(0.5, 0.5) # Center pivot for better scaling/rotation
	
	# Connect signals
	if trigger == TriggerType.ON_HOVER:
		if not _target_control.mouse_entered.is_connected(_on_mouse_entered):
			_target_control.mouse_entered.connect(_on_mouse_entered)
		if not _target_control.mouse_exited.is_connected(_on_mouse_exited):
			_target_control.mouse_exited.connect(_on_mouse_exited)
		_target_control.mouse_filter = Control.MOUSE_FILTER_STOP
			
	elif trigger == TriggerType.ON_START:
		call_deferred("play_animation")

func _exit_tree() -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
#endregion

#region Public Methods
func play_animation() -> void:
	# Always capture the current state right before playing.
	# This fixes issues where the node might have moved since _ready().
	_store_initial_properties()
	_animation_logic(true)

func stop_animation() -> void:
	_animation_logic(false)
#endregion

#region Private Logic
func _store_initial_properties() -> void:
	_initial_properties["position"] = _target_control.position
	_initial_properties["scale"] = _target_control.scale
	_initial_properties["rotation"] = _target_control.rotation
	_initial_properties["modulate"] = _target_control.modulate

func _animation_logic(animate: bool) -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	
	if not animate:
		_reset_to_initial()
		return
		
	_active_tween = create_tween()
	_active_tween.set_ease(ease_type)
	_active_tween.set_trans(trans_type)
	_active_tween.set_parallel(false)
	
	emit_signal("animation_started", AnimationType.keys()[animation_type])
	
	match animation_type:
		AnimationType.SCALE: _setup_scale_tween()
		AnimationType.ROTATE: _setup_rotate_tween()
		AnimationType.SHAKE: _setup_shake_tween()
		AnimationType.PULSE: _setup_pulse_tween()
		AnimationType.FADE: _setup_fade_tween()
		AnimationType.BOUNCE: _setup_bounce_tween()
		_: return

	_active_tween.tween_callback(_on_animation_finished)

func _reset_to_initial() -> void:
	# Only reset properties that are NOT controlled by layout containers
	# or strictly necessary for the visual reset.
	if _target_control:
		_target_control.scale = _initial_properties["scale"]
		_target_control.rotation = _initial_properties["rotation"]
		_target_control.modulate = _initial_properties["modulate"]
		# We do NOT reset position here manually to avoid fighting with containers.
		# If using Shake, the Tween handles returning to start position.

func _on_animation_finished() -> void:
	emit_signal("animation_finished", AnimationType.keys()[animation_type])
	
	if loop and trigger == TriggerType.ON_START:
		# For looping start animations, re-capture state before restarting
		# to prevent drift (e.g. if pulse ended slightly off)
		_store_initial_properties() 
		play_animation()
#endregion

#region Tween Setup Methods

func _setup_scale_tween() -> void:
	var target_scale = Vector2(magnitude, magnitude)
	var start_scale = _initial_properties["scale"]
	
	if trigger == TriggerType.ON_HOVER:
		_active_tween.tween_property(_target_control, "scale", target_scale, duration).set_delay(delay)
	else:
		_active_tween.tween_property(_target_control, "scale", target_scale, duration).set_delay(delay)
		_active_tween.tween_property(_target_control, "scale", start_scale, duration)

func _setup_rotate_tween() -> void:
	var target_rot = deg_to_rad(magnitude)
	
	if trigger == TriggerType.ON_HOVER:
		_active_tween.tween_property(_target_control, "rotation", target_rot, duration).set_delay(delay)
	else:
		_active_tween.tween_property(_target_control, "rotation", target_rot, duration).set_delay(delay)
		_active_tween.tween_property(_target_control, "rotation", _initial_properties["rotation"], duration)

func _setup_shake_tween() -> void:
	var original_pos = _initial_properties["position"]
	
	# Shake logic: Move right, move left, center.
	_active_tween.set_loops(3)
	_active_tween.tween_property(_target_control, "position:x", original_pos.x + magnitude, duration / 6.0).set_trans(Tween.TRANS_SINE)
	_active_tween.tween_property(_target_control, "position:x", original_pos.x - magnitude, duration / 6.0).set_trans(Tween.TRANS_SINE)
	_active_tween.tween_property(_target_control, "position:x", original_pos.x, duration / 6.0).set_trans(Tween.TRANS_SINE)

func _setup_pulse_tween() -> void:
	var start_scale = _initial_properties["scale"]
	var target_scale = start_scale * magnitude
	
	_active_tween.set_loops()
	_active_tween.tween_property(_target_control, "scale", target_scale, duration).set_delay(delay).set_ease(Tween.EASE_IN)
	_active_tween.tween_property(_target_control, "scale", start_scale, duration).set_ease(Tween.EASE_OUT)

func _setup_fade_tween() -> void:
	var target_alpha = magnitude 
	
	if trigger == TriggerType.ON_HOVER:
		_active_tween.tween_property(_target_control, "modulate:a", target_alpha, duration).set_delay(delay)
	else:
		_active_tween.tween_property(_target_control, "modulate:a", target_alpha, duration).set_delay(delay)
		_active_tween.tween_property(_target_control, "modulate:a", 1.0, duration)

func _setup_bounce_tween() -> void:
	var target_scale = Vector2(magnitude, magnitude)
	var start_scale = _initial_properties["scale"]
	
	_active_tween.set_trans(Tween.TRANS_BOUNCE)
	
	if trigger == TriggerType.ON_HOVER:
		_active_tween.tween_property(_target_control, "scale", target_scale, duration).set_delay(delay)
	else:
		_active_tween.tween_property(_target_control, "scale", target_scale, duration).set_delay(delay)
		_active_tween.tween_property(_target_control, "scale", start_scale, duration)

#endregion

#region Event Handlers
func _on_mouse_entered() -> void:
	_is_hovering = true
	play_animation()

func _on_mouse_exited() -> void:
	_is_hovering = false
	
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	
	# Create a return tween
	_active_tween = create_tween()
	_active_tween.set_ease(ease_type)
	_active_tween.set_trans(trans_type)
	_active_tween.set_parallel(true)
	
	# CRITICAL FIX: Only reset properties that the specific animation type affects.
	# This prevents breaking layout position for Scale/Rotate animations.
	
	match animation_type:
		AnimationType.SCALE, AnimationType.PULSE, AnimationType.BOUNCE:
			_active_tween.tween_property(_target_control, "scale", _initial_properties["scale"], duration)
		
		AnimationType.ROTATE:
			_active_tween.tween_property(_target_control, "rotation", _initial_properties["rotation"], duration)
		
		AnimationType.SHAKE:
			# Shake modifies position, so we must return position to the captured start position
			_active_tween.tween_property(_target_control, "position", _initial_properties["position"], duration)
		
		AnimationType.FADE:
			_active_tween.tween_property(_target_control, "modulate:a", _initial_properties["modulate"].a, duration)
	
	_active_tween.set_parallel(false)
#endregion