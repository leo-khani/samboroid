extends Node

@onready var pause_ui: Control = $MainUI/PauseUI
@onready var game_over_ui: Control = $MainUI/GameOverUI

@onready var try_again_btn: Button = %TryAgainBtn
@onready var game_over_label: Label = %GameOverLabel


var game_over_texts = [
	"Objective: Don’t hit the planets! Result: Planet successfully headbutted. Try again!",
	"Space rule #1: Avoid planets.You: ‘What if… no?",
	"Congratulations! You discovered a planet… the hard way.",
	"That planet wasn’t a goal. But you reached it anyway.",
	"Mission failed. Reason: Planet was too tempting.",
]

func _ready():
	SignalHub.level_started.connect(_on_level_started)
	SignalHub.level_completed.connect(_on_level_completed)
	SignalHub.level_failed.connect(_on_level_failed)


func _on_level_started(level_name: GlobalEnum.Levels):
	print("Level started: ", level_name) # Debug print


func _on_level_completed(level_name: GlobalEnum.Levels):
	print("Level completed: ", level_name) # Debug print


func _on_level_failed(level_name: GlobalEnum.Levels):
	print("Level failed: ", level_name) # Debug print
	set_pause(true)
	game_over_label.text = game_over_texts[randi() % game_over_texts.size()]
	game_over_ui.visible = true


func set_pause(is_paused: bool):
	get_tree().paused = is_paused
	SignalHub.emit_game_paused(is_paused)

func _on_try_again_btn_pressed():
	get_tree().reload_current_scene()

	set_pause(false)
	game_over_ui.visible = false

func _input(event):
	if event.is_action_pressed("pause"):
		set_pause(not get_tree().paused)
		pause_ui.visible = get_tree().paused


func _on_main_menu_btn_pressed():
	set_pause(false)
	game_over_ui.visible = false
	SceneLoader.load_scene(GlobalData.UI_MAIN_MENU_SCENE.resource_path)
