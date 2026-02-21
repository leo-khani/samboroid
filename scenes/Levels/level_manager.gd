class_name LevelManager extends Node2D

var max_mass_fluid: float = 100.0
var mass_fluid: float = 100.0:
	set(value):
		mass_fluid = clamp(value, 0.0, max_mass_fluid)

func _ready():
	SignalHub.planet_mass_added.connect(_on_planet_mass_added)
	SignalHub.planet_mass_removed.connect(_on_planet_mass_removed)

func _on_planet_mass_added(planet: Node):
	print("Mass added to planet: ", planet.name) # Debug print

	if mass_fluid == 0.0:
		missing_resource()
		return

	planet.add_mass(10.0) # Example mass addition, adjust as needed
	mass_fluid -= 10.0 # Decrease mass fluid, ensuring it doesn't go below 0

func _on_planet_mass_removed(planet: Node):
	if mass_fluid == max_mass_fluid:
		resources_full()
		return

	planet.remove_mass(10.0) # Example mass removal, adjust as needed
	mass_fluid += 10.0 # Increase mass fluid, ensuring it doesn't go above max



func missing_resource():
	print("Missing resource: ")
	SignalHub.emit_camera_shake(GlobalEnum.ShakePreset.MEDIUM, 0.5)
	SignalHub.emit_notification("Missing resource!")

func resources_full():
	print("Resources full: ")
	SignalHub.emit_camera_shake(GlobalEnum.ShakePreset.MEDIUM, 0.5)
	SignalHub.emit_notification("Resources are full!")