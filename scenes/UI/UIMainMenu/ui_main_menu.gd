extends Control

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var rotaion_speed: float = 20.0

func _process(delta: float) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	animated_sprite_2d.position = viewport_size / 2

	animated_sprite_2d.scale = Vector2(3.5, 3.5)

func _on_start_btn_pressed():
	AudioManager.play_sfx(GlobalData.SFX_EXPLOSION_2, 1.0, -5.0)
	SceneLoader.load_scene(GlobalData.UI_LEVEL_SELECTOR_SCENE.resource_path)

	
