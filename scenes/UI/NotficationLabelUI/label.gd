class_name UINotificationLabel extends Label

var tween: Tween = null

var duration: float = 3.0  # Duration the notification stays visible in seconds


## Configures the notification label with the specified message, duration, color, and font size.
## [br]
## Sets up the visual appearance and timing properties of a notification label UI element.
## [br]
## [param msg] The text message to display in the notification.
## [param new_duration] How long the notification should remain visible (in seconds).
## [param color] The color to apply to the notification text.
## [param new_font_size] The font size for the notification text (in pixels).
func setup(msg: String, new_duration: float, color: Color, new_font_size: int):
	text = msg
	modulate = color
	add_theme_font_size_override("font_size", new_font_size)
	self.duration = new_duration

func _ready():
	await get_tree().process_frame  # Ensure the node is fully initialized before animating
	animate_in()
	await get_tree().create_timer(duration).timeout
	await animate_out()
	await tween.finished
	queue_free()

func animate_in():
	if tween:
		tween.kill()
		
	# Start with the label invisible and slightly scaled down
	self.modulate.a = 0.0
	self.scale = Vector2(0.8, 0.8)

	# Create a tween to animate the label in
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)




func animate_out():
	if tween:
		tween.kill()  # Stop any existing tweens to prevent conflicts

	# Create a tween to animate the label out (parallel so both play at once)
	tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", position.y - 30.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
