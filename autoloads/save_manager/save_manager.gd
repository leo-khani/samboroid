# Autoload SaveManager.gd
extends Node

const SAVE_PATH := "user://save_data.json"

var save_data_file: SaveFileStats = preload("res://resources/save_file.tres")
var DEBUG: bool = true

var remove_save_file_on_ready: bool = false

func _ready() -> void:
	if remove_save_file_on_ready:
		DirAccess.remove_absolute(SAVE_PATH)
	load_data()




## Serializes all level data from [member save_data_file] to disk as JSON.[br]
## Each key in the output is the stringified [enum GlobalEnum.Levels] value,[br]
## mapped to a dictionary with [code]best_time[/code] and [code]last_time[/code].[br]
## File is written to [constant SAVE_PATH] ([code]user://save_data.json[/code]).
func save_data() -> void:
	var out := {}
	for level_key in save_data_file.data:
		out[str(level_key)] = save_data_file.data[level_key].duplicate()

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(out, "\t"))
		if DEBUG:
			print("SaveManager: Data saved to ", SAVE_PATH)
	else:
		push_error("SaveManager: Failed to open save file for writing.")


## Reads the JSON save file from [constant SAVE_PATH] and populates
## [member save_data_file] with the stored level times.[br]
## If the file does not exist (first launch), this is a no-op.[br]
## Invalid or corrupt JSON is logged via [method push_error] and skipped.
func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("SaveManager: Failed to open save file for reading.")
		return

	var json_string := file.get_as_text()
	var parsed = JSON.parse_string(json_string)
	if parsed == null or not parsed is Dictionary:
		push_error("SaveManager: Save file contains invalid JSON.")
		return

	for key in parsed:
		var level_enum: GlobalEnum.Levels = int(key) as GlobalEnum.Levels
		if save_data_file.data.has(level_enum):
			var entry: Dictionary = parsed[key]
			save_data_file.data[level_enum]["best_time"] = entry.get("best_time")
			save_data_file.data[level_enum]["last_time"] = entry.get("last_time")

	if DEBUG:
		print("SaveManager: Data loaded from ", SAVE_PATH)
		print("Current save data: ", save_data_file.data)

func is_unlocked(level: GlobalEnum.Levels) -> bool:
	if not save_data_file.data.has(level):
		return false
	var level_data: Dictionary = save_data_file.data[level]
	return level_data.get("best_time") != null or level_data.get("last_time") != null



func add_level_data(level: GlobalEnum.Levels, time: float) -> void:
	var level_data: Dictionary = save_data_file.data[level]
	level_data["last_time"] = time
	if level_data["best_time"] == null or time < level_data["best_time"]:
		level_data["best_time"] = time
	save_data()


func get_level_data(level: GlobalEnum.Levels) -> Dictionary:
	return save_data_file.data.get(level, {})


func get_best_time(level: GlobalEnum.Levels):
	return save_data_file.data[level]["best_time"]


func get_last_time(level: GlobalEnum.Levels):
	return save_data_file.data[level]["last_time"]
