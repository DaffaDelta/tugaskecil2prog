extends Node


signal game_saved
signal game_loaded

const SAVE_PATH := "user://savegame.json"
const SAVE_VERSION := 1
const GROUP := "saveable"


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game(extra: Dictionary = {}) -> bool:
	var nodes_data := {}
	for node in get_tree().get_nodes_in_group(GROUP):
		if node.has_method("get_save_data"):
			nodes_data[node.call("get_save_id")] = node.call("get_save_data")

	var data := {
		"version": SAVE_VERSION,
		"extra": extra,
		"nodes": nodes_data,
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Gagal menulis save: %s" % error_string(FileAccess.get_open_error()))
		return false
	file.store_string(JSON.stringify(data, "\t"))
	game_saved.emit()
	return true


func load_game() -> Dictionary:
	if not has_save():
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("File save rusak.")
		return {}

	var nodes_data: Dictionary = parsed.get("nodes", {})
	for node in get_tree().get_nodes_in_group(GROUP):
		if not node.has_method("load_save_data"):
			continue
		var id: String = node.call("get_save_id")
		if nodes_data.has(id):
			node.call("load_save_data", nodes_data[id])

	game_loaded.emit()
	return parsed.get("extra", {})


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
