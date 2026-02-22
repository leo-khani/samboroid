class_name LevelManager extends Node2D

var current_game_state: GlobalEnum.GameState = GlobalEnum.GameState.NONE: set = _set_game_state
@export var current_level: GlobalEnum.Levels = GlobalEnum.Levels.LEVEL_1

func _set_game_state(new_state: GlobalEnum.GameState):
	current_game_state = new_state

	SignalHub.emit_game_state_changed(new_state)

@export var max_mass_fluid: float = 100.0
@export var mass_fluid: float = 100.0:
	set(value):
		mass_fluid = clamp(value, 0.0, max_mass_fluid)

func _ready():
	SignalHub.planet_mass_added.connect(_on_planet_mass_added)
	SignalHub.planet_mass_removed.connect(_on_planet_mass_removed)
	SignalHub.asteroid_shot.connect(func():	current_game_state = GlobalEnum.GameState.LAUNCH)
	SignalHub.emit_level_started(current_level)

	current_game_state = GlobalEnum.GameState.STRATEGY

func _on_planet_mass_added(planet: Node):
	print("Mass added to planet: ", planet.name) # Debug print

	if mass_fluid == 0.0:
		missing_resource()
		return

	planet.add_mass(10.0) # Example mass addition, adjust as needed
	mass_fluid -= 10.0 # Decrease mass fluid, ensuring it doesn't go below 0
	AudioManager.play_sfx(GlobalData.SFX_IMPACT_METAL_0, 1.0, 0.0)

func _on_planet_mass_removed(planet: Node):
	if mass_fluid == max_mass_fluid:
		resources_full()
		return

	planet.remove_mass(10.0) # Example mass removal, adjust as needed
	mass_fluid += 10.0 # Increase mass fluid, ensuring it doesn't go above max
	AudioManager.play_sfx(GlobalData.SFX_SLIME_0, 1.0, 0.0)



func missing_resource():
	if current_game_state != GlobalEnum.GameState.STRATEGY:
		return

	SignalHub.emit_camera_shake(GlobalEnum.ShakePreset.MEDIUM, 0.5)
	SignalHub.emit_notification("Missing resource!", 0.6, Color.RED, 16)
	

func resources_full():
	if current_game_state != GlobalEnum.GameState.STRATEGY:
		return

	SignalHub.emit_camera_shake(GlobalEnum.ShakePreset.MEDIUM, 0.5)
	SignalHub.emit_notification("Resources are full!", 0.6, Color.RED, 16)
