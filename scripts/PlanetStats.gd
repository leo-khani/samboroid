class_name PlanetStats extends Resource

@export var planet_type: GlobalEnum.PlanetType = GlobalEnum.PlanetType.ROCKY

## Derived automatically from planet_type via Data.planet_textures.
var planet_texture: Texture2D:
	get:
		var textures: Array = GlobalData.planet_textures.get(planet_type, [])
		if textures.is_empty():
			return null
		return textures.pick_random()
