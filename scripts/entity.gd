class_name Entity
extends Node2D
## Kelas dasar (INHERITANCE) untuk Player dan Enemy.
## Gerakan berbasis grid, dan otomatis "saveable".

signal moved(new_cell: Vector2i)

@export var save_id := "entity"
@export var color := Color.WHITE
@export var texture: Texture2D  
@export var move_duration := 0.15

var active := true  # false = tidak bisa bergerak (game selesai)

var _maze: MazeGrid
var _cell := Vector2i.ZERO
var _is_moving := false
var _tween: Tween


func _ready() -> void:
	add_to_group(SaveManagerConst.GROUP)


func setup(maze: MazeGrid, start_cell: Vector2i) -> void:
	_maze = maze
	set_cell_instant(start_cell)
	queue_redraw()


func get_cell() -> Vector2i:
	return _cell


func is_moving() -> bool:
	return _is_moving


func try_move(direction: Vector2i) -> bool:
	if not active or _is_moving or _maze == null:
		return false
	var target := _cell + direction
	if not _maze.is_walkable(target):
		return false
	_is_moving = true
	_cell = target
	_tween = create_tween()
	_tween.tween_property(self, "global_position", _maze.cell_to_world(target), move_duration)
	_tween.finished.connect(_on_move_finished)
	return true


func set_cell_instant(cell: Vector2i) -> void:
	if _tween:
		_tween.kill()
	_is_moving = false
	_cell = cell
	global_position = _maze.cell_to_world(cell)


func _on_move_finished() -> void:
	_is_moving = false
	moved.emit(_cell)


func _draw() -> void:
	if _maze == null:
		return
	var tile := Vector2(_maze.get_tile_size())
	if texture:
		draw_texture_rect(texture, Rect2(-tile / 2.0, tile), false)
	else:
		draw_circle(Vector2.ZERO, tile.x * 0.35, color)


func get_save_id() -> String:
	return save_id


func get_save_data() -> Dictionary:
	return {"cell": [_cell.x, _cell.y]}


func load_save_data(data: Dictionary) -> void:
	var c: Array = data.get("cell", [_cell.x, _cell.y])
	set_cell_instant(Vector2i(int(c[0]), int(c[1])))
