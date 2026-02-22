# Autoload Enum.gd
extends Node

enum PlanetType {
	ROCKY,
	GAS_GIANT,
	ICE_GIANT,
	MOON,
	STAR,
}

enum ShakePreset {
	SMALL,
	MEDIUM,
	LARGE,
}

enum GameState {
	NONE,
	MAIN_MENU,
	PAUSE,
	STRATEGY,
	LAUNCH,
	WIN,
	LOSE,
}

enum Levels {
	LEVEL_1,
	LEVEL_2,
	LEVEL_3,
	LEVEL_4,
	LEVEL_5,
}