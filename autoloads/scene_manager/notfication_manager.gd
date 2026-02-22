extends Node



var active_notifications: Array = []

func _ready() -> void:
	SignalHub.notification.connect(_on_notification)


func _on_notification(message: String, duration: float, color: Color, font_size: int) -> void:
	if active_notifications.size() >= 1:  # Limit to 1 active notification at a time
		# Too many notifications, ignore new ones
		return
	var viewport = get_viewport()
	var screen_pos = viewport.get_mouse_position()
	var world_pos = viewport.get_canvas_transform().affine_inverse() * screen_pos
	var label_scene = GlobalData.NOTIFICATION_LABEL_SCENE


	var label_instance = label_scene.instantiate() as UINotificationLabel
	if label_instance is UINotificationLabel:
		label_instance.text = message
		label_instance.position = world_pos
		label_instance.setup(message, duration, color, font_size)
		get_tree().get_root().add_child(label_instance)
		active_notifications.append(label_instance)
		# Optional: Add animation or timer to remove the label after a few seconds

		label_instance.tree_exited.connect(_on_label_exited)


func _on_label_exited() -> void:
	# Erase all
	active_notifications.clear()
