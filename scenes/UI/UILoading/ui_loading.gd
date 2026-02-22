extends CanvasLayer

signal loading_screen_ready

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	# The animation "transition" should autoplay to fade in [00:06:22]
	animation_player.play("animate_in")
	await animation_player.animation_finished
	loading_screen_ready.emit()

func on_progress_changed(value: float) -> void:
	# Use 'value' (0.0 to 1.0) to update a ProgressBar if desired [00:07:22]
	pass

func on_load_finished() -> void:
	# Play the fade-out animation once the scene has switched [00:07:53]
	await get_tree().create_timer(0.3).timeout  # Optional delay before fading out
	animation_player.play_backwards("animate_in")
	await animation_player.animation_finished
	queue_free()
