# Autoload Data.gd
extends Node



#region Scene references
const NOTIFICATION_LABEL_SCENE: PackedScene = preload("uid://c1cljhr8txymn")
const UI_LOADING_SCENE: PackedScene = preload("res://scenes/UI/UILoading/ui_loading.tscn")
const UI_MAIN_MENU_SCENE: PackedScene = preload("uid://cftm3pjo6csix")
const UI_LEVEL_SELECTOR_SCENE: PackedScene = preload("uid://bis15xufloj6p")
const UI_WON_SCENE: PackedScene = preload("uid://cmjya0vysjdmm")
#endregion

#region LevelScene references
var level_scenes: Dictionary = {}

func _ready():
	level_scenes = {
		GlobalEnum.Levels.LEVEL_1: load("res://scenes/Levels/level_01.tscn"),
		GlobalEnum.Levels.LEVEL_2: load("res://scenes/Levels/level_02.tscn"),
		GlobalEnum.Levels.LEVEL_3: load("res://scenes/Levels/level_03.tscn"),
		GlobalEnum.Levels.LEVEL_4: load("res://scenes/Levels/level_04.tscn"),
		GlobalEnum.Levels.LEVEL_5: load("res://scenes/Levels/level_05.tscn"),
	}

var planet_textures: Dictionary[GlobalEnum.PlanetType, Array] = {
	GlobalEnum.PlanetType.ROCKY: [
		preload("res://assets/Planets/rocky_01.png"),
		preload("res://assets/Planets/rocky_02.png"),
		preload("res://assets/Planets/rocky_03.png"),
		preload("res://assets/Planets/rocky_04.png"),
		preload("res://assets/Planets/rocky_05.png"),
		preload("res://assets/Planets/rocky_06.png"),
		preload("res://assets/Planets/rocky_07.png"),
		preload("res://assets/Planets/rocky_08.png"),
		preload("res://assets/Planets/rocky_09.png"),
		preload("res://assets/Planets/rocky_10.png"),
		preload("res://assets/Planets/rocky_11.png"),
		preload("res://assets/Planets/rocky_12.png"),
		preload("res://assets/Planets/rocky_13.png"),
	]
}

#region AudioStreams

# SFXs
const SFX_COMPUTER_0: AudioStream = preload("res://audios/SFX/computerNoise_000.ogg")
const SFX_COMPUTER_1: AudioStream = preload("res://audios/SFX/computerNoise_001.ogg")
const SFX_COMPUTER_2: AudioStream = preload("res://audios/SFX/computerNoise_002.ogg")
const SFX_COMPUTER_3: AudioStream = preload("res://audios/SFX/computerNoise_003.ogg")

const SFX_DOOR_CLOSE_0: AudioStream = preload("res://audios/SFX/doorClose_000.ogg")
const SFX_DOOR_CLOSE_1: AudioStream = preload("res://audios/SFX/doorClose_001.ogg")
const SFX_DOOR_CLOSE_2: AudioStream = preload("res://audios/SFX/doorClose_002.ogg")

const SFX_DOOR_OPEN_0: AudioStream = preload("res://audios/SFX/doorOpen_000.ogg")
const SFX_DOOR_OPEN_1: AudioStream = preload("res://audios/SFX/doorOpen_001.ogg")
const SFX_DOOR_OPEN_2: AudioStream = preload("res://audios/SFX/doorOpen_002.ogg")

const SFX_ENGINE_CIRCULAR_0: AudioStream = preload("res://audios/SFX/engineCircular_000.ogg")
const SFX_ENGINE_CIRCULAR_1: AudioStream = preload("res://audios/SFX/engineCircular_001.ogg")
const SFX_ENGINE_CIRCULAR_2: AudioStream = preload("res://audios/SFX/engineCircular_002.ogg")
const SFX_ENGINE_CIRCULAR_3: AudioStream = preload("res://audios/SFX/engineCircular_003.ogg")
const SFX_ENGINE_CIRCULAR_4: AudioStream = preload("res://audios/SFX/engineCircular_004.ogg")

const SFX_EXPLOSION_0: AudioStream = preload("res://audios/SFX/explosionCrunch_000.ogg")
const SFX_EXPLOSION_1: AudioStream = preload("res://audios/SFX/explosionCrunch_001.ogg")
const SFX_EXPLOSION_2: AudioStream = preload("res://audios/SFX/explosionCrunch_002.ogg")
const SFX_EXPLOSION_3: AudioStream = preload("res://audios/SFX/explosionCrunch_003.ogg")
const SFX_EXPLOSION_4: AudioStream = preload("res://audios/SFX/explosionCrunch_004.ogg")

const SFX_FORCE_FIELD_0: AudioStream = preload("res://audios/SFX/forceField_000.ogg")
const SFX_FORCE_FIELD_1: AudioStream = preload("res://audios/SFX/forceField_001.ogg")
const SFX_FORCE_FIELD_2: AudioStream = preload("res://audios/SFX/forceField_002.ogg")
const SFX_FORCE_FIELD_3: AudioStream = preload("res://audios/SFX/forceField_003.ogg")
const SFX_FORCE_FIELD_4: AudioStream = preload("res://audios/SFX/forceField_004.ogg")

const SFX_IMPACT_METAL_0: AudioStream = preload("res://audios/SFX/impactMetal_000.ogg")
const SFX_IMPACT_METAL_1: AudioStream = preload("res://audios/SFX/impactMetal_001.ogg")
const SFX_IMPACT_METAL_2: AudioStream = preload("res://audios/SFX/impactMetal_002.ogg")
const SFX_IMPACT_METAL_3: AudioStream = preload("res://audios/SFX/impactMetal_003.ogg")
const SFX_IMPACT_METAL_4: AudioStream = preload("res://audios/SFX/impactMetal_004.ogg")

const SFX_LASER_LARGE_0: AudioStream = preload("res://audios/SFX/laserLarge_000.ogg")
const SFX_LASER_LARGE_1: AudioStream = preload("res://audios/SFX/laserLarge_001.ogg")
const SFX_LASER_LARGE_2: AudioStream = preload("res://audios/SFX/laserLarge_002.ogg")
const SFX_LASER_LARGE_3: AudioStream = preload("res://audios/SFX/laserLarge_003.ogg")
const SFX_LASER_LARGE_4: AudioStream = preload("res://audios/SFX/laserLarge_004.ogg")

const SFX_LASER_RETRO_0: AudioStream = preload("res://audios/SFX/laserRetro_000.ogg")
const SFX_LASER_RETRO_1: AudioStream = preload("res://audios/SFX/laserRetro_001.ogg")
const SFX_LASER_RETRO_2: AudioStream = preload("res://audios/SFX/laserRetro_002.ogg")
const SFX_LASER_RETRO_3: AudioStream = preload("res://audios/SFX/laserRetro_003.ogg")
const SFX_LASER_RETRO_4: AudioStream = preload("res://audios/SFX/laserRetro_004.ogg")

const SFX_LASER_SMALL_0: AudioStream = preload("res://audios/SFX/laserSmall_000.ogg")
const SFX_LASER_SMALL_1: AudioStream = preload("res://audios/SFX/laserSmall_001.ogg")
const SFX_LASER_SMALL_2: AudioStream = preload("res://audios/SFX/laserSmall_002.ogg")
const SFX_LASER_SMALL_3: AudioStream = preload("res://audios/SFX/laserSmall_003.ogg")
const SFX_LASER_SMALL_4: AudioStream = preload("res://audios/SFX/laserSmall_004.ogg")

const SFX_LOW_EXPLOSION_0: AudioStream = preload("res://audios/SFX/lowFrequency_explosion_000.ogg")
const SFX_LOW_EXPLOSION_1: AudioStream = preload("res://audios/SFX/lowFrequency_explosion_001.ogg")

const SFX_SLIME_0: AudioStream = preload("res://audios/SFX/slime_000.ogg")
const SFX_SLIME_1: AudioStream = preload("res://audios/SFX/slime_001.ogg")

const SFX_ENGINE_0: AudioStream = preload("res://audios/SFX/spaceEngine_000.ogg")
const SFX_ENGINE_1: AudioStream = preload("res://audios/SFX/spaceEngine_001.ogg")
const SFX_ENGINE_2: AudioStream = preload("res://audios/SFX/spaceEngine_002.ogg")
const SFX_ENGINE_3: AudioStream = preload("res://audios/SFX/spaceEngine_003.ogg")

const SFX_ENGINE_LARGE_0: AudioStream = preload("res://audios/SFX/spaceEngineLarge_000.ogg")
const SFX_ENGINE_LARGE_1: AudioStream = preload("res://audios/SFX/spaceEngineLarge_001.ogg")
const SFX_ENGINE_LARGE_2: AudioStream = preload("res://audios/SFX/spaceEngineLarge_002.ogg")
const SFX_ENGINE_LARGE_3: AudioStream = preload("res://audios/SFX/spaceEngineLarge_003.ogg")
const SFX_ENGINE_LARGE_4: AudioStream = preload("res://audios/SFX/spaceEngineLarge_004.ogg")

const SFX_ENGINE_LOW_0: AudioStream = preload("res://audios/SFX/spaceEngineLow_000.ogg")
const SFX_ENGINE_LOW_1: AudioStream = preload("res://audios/SFX/spaceEngineLow_001.ogg")
const SFX_ENGINE_LOW_2: AudioStream = preload("res://audios/SFX/spaceEngineLow_002.ogg")
const SFX_ENGINE_LOW_3: AudioStream = preload("res://audios/SFX/spaceEngineLow_003.ogg")
const SFX_ENGINE_LOW_4: AudioStream = preload("res://audios/SFX/spaceEngineLow_004.ogg")

const SFX_ENGINE_SMALL_0: AudioStream = preload("res://audios/SFX/spaceEngineSmall_000.ogg")
const SFX_ENGINE_SMALL_1: AudioStream = preload("res://audios/SFX/spaceEngineSmall_001.ogg")
const SFX_ENGINE_SMALL_2: AudioStream = preload("res://audios/SFX/spaceEngineSmall_002.ogg")
const SFX_ENGINE_SMALL_3: AudioStream = preload("res://audios/SFX/spaceEngineSmall_003.ogg")
const SFX_ENGINE_SMALL_4: AudioStream = preload("res://audios/SFX/spaceEngineSmall_004.ogg")

const SFX_THRUSTER_0: AudioStream = preload("res://audios/SFX/thrusterFire_000.ogg")
const SFX_THRUSTER_1: AudioStream = preload("res://audios/SFX/thrusterFire_001.ogg")
const SFX_THRUSTER_2: AudioStream = preload("res://audios/SFX/thrusterFire_002.ogg")
const SFX_THRUSTER_3: AudioStream = preload("res://audios/SFX/thrusterFire_003.ogg")
const SFX_THRUSTER_4: AudioStream = preload("res://audios/SFX/thrusterFire_004.ogg")

#endregion
