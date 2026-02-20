class_name PlanetStats extends Node

var planet_type: GlobalEnum.PlanetType = GlobalEnum.PlanetType.ROCKY
var planet_scene: PackedScene
var planet_radius: float

func _init(_type: GlobalEnum.PlanetType, _scene: PackedScene, _radius: float):
	planet_type = _type
	planet_scene = _scene
	planet_radius = _radius
