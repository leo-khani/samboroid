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
signal notification(message: String)
func emit_notification(message: String):
	notification.emit(message)
#endregion

#region Level
signal level_started(level_name: String)
func emit_level_started(level_name: String):
	level_started.emit(level_name)
	
signal level_completed(level_name: String)
func emit_level_completed(level_name: String):
	level_completed.emit(level_name)

signal asteroid_shot()
func emit_asteroid_shot():
	asteroid_shot.emit()

	
#endregion