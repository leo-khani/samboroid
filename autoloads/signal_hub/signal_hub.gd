# Autoload SignalHub.gd
extends Node


#region Camera
signal camera_shake(shake_preset: GlobalEnum.ShakePreset, duration: float)

func emit_camera_shake(shake_preset: GlobalEnum.ShakePreset, duration: float):
	camera_shake.emit(shake_preset, duration)
#endregion

#region Mouse
signal mouse_hover_entered()
func emit_mouse_hover_entered():
	mouse_hover_entered.emit()


signal mouse_hover_exited()
func emit_mouse_hover_exited():
	mouse_hover_exited.emit()
#endregion

#region Planet

signal planet_mass_added(planet: Node)
func emit_planet_mass_added(planet: Node):
	planet_mass_added.emit(planet)

signal planet_mass_removed(planet: Node)
func emit_planet_mass_removed(planet: Node):
	planet_mass_removed.emit(planet)

#endregion

#region Notfication
signal notification(message: String, duration: float, color: Color, font_size: int)
func emit_notification(message: String, duration: float = 3.0, color: Color = Color(1, 1, 1), font_size: int = 16):
	notification.emit(message, duration, color, font_size)
#endregion

#region Level
signal level_started(level_name: GlobalEnum.Levels)
func emit_level_started(level_name: GlobalEnum.Levels):
	level_started.emit(level_name)
	
signal level_completed(level_name: GlobalEnum.Levels)
func emit_level_completed(level_name: GlobalEnum.Levels):
	level_completed.emit(level_name)

signal level_failed(level_name: GlobalEnum.Levels)
func emit_level_failed(level_name: GlobalEnum.Levels):
	level_failed.emit(level_name)
#endregion


signal asteroid_shot()
func emit_asteroid_shot():
	asteroid_shot.emit()

signal game_state_changed(new_state: GlobalEnum.GameState)
func emit_game_state_changed(new_state: GlobalEnum.GameState):
	game_state_changed.emit(new_state)

signal game_paused(is_paused: bool)
func emit_game_paused(is_paused: bool):
	game_paused.emit(is_paused)

#endregion