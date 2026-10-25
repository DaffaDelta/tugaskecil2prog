class_name WandererEnemy
extends Enemy


var _previous_cell := Vector2i(-9999, -9999)


func _init() -> void:
	save_id = "wanderer"
	think_interval = 0.3


func _choose_next_cell() -> Vector2i:
	var options := _maze.get_neighbors(_cell)
	if options.size() > 1:
		options.erase(_previous_cell)
	if options.is_empty():
		return _cell
	_previous_cell = _cell
	return options.pick_random()
