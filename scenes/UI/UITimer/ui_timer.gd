class_name UITimer extends Control

@onready var timer_label: Label = %TimerLabel

var elapsed_time: float = 0.0
var is_running: bool = false
var last_displayed_second: int = -1
var juice_tween: Tween

func _ready():
	SignalHub.level_started.connect(_on_level_started)
	SignalHub.level_completed.connect(_on_level_completed)
	SignalHub.level_failed.connect(_on_level_failed)
	_update_label()

func _process(delta: float):
	if not is_running:
		return

	elapsed_time += delta
	_update_label()

	# Juice on every new second
	var current_second := int(elapsed_time)
	if current_second != last_displayed_second:
		last_displayed_second = current_second
		_juice()


func _update_label():
	var total_seconds := int(elapsed_time)
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	timer_label.text = "%d:%02d" % [minutes, seconds]


func _juice():
	if juice_tween and juice_tween.is_running():
		juice_tween.kill()

	timer_label.pivot_offset = timer_label.size / 2.0
	timer_label.scale = Vector2(1.3, 1.3)
	timer_label.modulate = Color(1.0, 0.85, 0.3)

	juice_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	juice_tween.tween_property(timer_label, "scale", Vector2.ONE, 0.4)
	juice_tween.parallel().tween_property(timer_label, "modulate", Color.WHITE, 0.3) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)


func start_timer():
	elapsed_time = 0.0
	last_displayed_second = -1
	is_running = true
	_update_label()

func stop_timer():
	is_running = false

func reset_timer():
	is_running = false
	elapsed_time = 0.0
	last_displayed_second = -1
	_update_label()


func get_time() -> float:
	return elapsed_time


func _on_level_started(_level_name: GlobalEnum.Levels):
	start_timer()

func _on_level_completed(_level_name: GlobalEnum.Levels):
	stop_timer()
	SaveManager.add_level_data(_level_name, get_time())


func _on_level_failed(_level_name: GlobalEnum.Levels):
	stop_timer()