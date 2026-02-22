extends Button


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var tooltip_label: Label = $TooltipLabel

@export var level_enum: GlobalEnum.Levels = GlobalEnum.Levels.LEVEL_1
@export var locked_color: Color = Color(1, 1, 1, 0.5)

var base_scale: Vector2 = Vector2.ONE
var hover_outline_thickness: float = 1.0

var is_unlocked: bool = true


var outline_tween: Tween = null
var scale_tween: Tween = null


func _format_time(time) -> String:
	if time == null:
		return "--:--"
	var minutes: int = int(time) / 60
	var seconds: int = int(time) % 60
	return "%02d:%02d" % [minutes, seconds]

func _ready():
	base_scale = sprite.scale
	hide_tooltip()

	is_unlocked = SaveManager.is_unlocked(level_enum)

	var best_time_info: String = "\nBest Time: " + _format_time(SaveManager.get_best_time(level_enum)) + "\nLast Time: " + _format_time(SaveManager.get_last_time(level_enum))

	match level_enum:
		GlobalEnum.Levels.LEVEL_1:
			tooltip_label.text = "Level 1" + best_time_info
		GlobalEnum.Levels.LEVEL_2:
			tooltip_label.text = "Level 2" + best_time_info
		GlobalEnum.Levels.LEVEL_3:
			tooltip_label.text = "Level 3" + best_time_info
		GlobalEnum.Levels.LEVEL_4:
			tooltip_label.text = "Level 4" + best_time_info
		GlobalEnum.Levels.LEVEL_5:
			tooltip_label.text = "Level 5" + best_time_info
		
		_:
			tooltip_label.text = "Unknown Level"

	if !is_unlocked and level_enum != GlobalEnum.Levels.LEVEL_1:
		set_disabled(true)
		sprite.modulate = locked_color
		tooltip_label.text = "Locked!"


func set_hover_mode(is_active: bool):
		
	if is_active:
		show_tooltip()
	else:
		hide_tooltip()

	if !is_unlocked:
		return  # Don't allow hover effects if the level is locked
		
	var scale_factor = 1.5 * base_scale if is_active else base_scale

	if scale_tween:
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.tween_property(sprite, "scale", scale_factor, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)

func show_tooltip():
	animation_player.play("animate_tooltip")

func hide_tooltip():
	animation_player.play_backwards("animate_tooltip")

func _on_mouse_exited():
	set_hover_mode(false)


func _on_mouse_entered():
	set_hover_mode(true)
	AudioManager.play_sfx(GlobalData.SFX_FORCE_FIELD_0, 1.0, -5.0)


func _on_pressed():
	SceneLoader.load_scene(GlobalData.level_scenes.get(level_enum).resource_path)
