# Autoload SignalHub.gd
extends Node


#region Camera
signal camera_shake(shake_preset: GlobalEnum.ShakePreset, duration: float)

func emit_camera_shake(shake_preset: GlobalEnum.ShakePreset, duration: float):
	emit_signal("camera_shake", shake_preset, duration)
#endregion

