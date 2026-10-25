class_name ChaserEnemy
extends Enemy

var _target: Entity
var _pathfinder: PathfinderComponent


func _init() -> void:
	save_id = "chaser"
	think_interval = 0.35


func set_target(target: Entity, pathfinder: PathfinderComponent) -> void:
	_target = target
	_pathfinder = pathfinder


func _choose_next_cell() -> Vector2i:
	if _target == null or _pathfinder == null:
		return _cell
	var path := _pathfinder.find_path(_cell, _target.get_cell())
	if path.size() > 1:
		return path[1]  # path[0] = posisi sekarang
	return _cell
