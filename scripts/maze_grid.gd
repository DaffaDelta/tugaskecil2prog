class_name MazeGrid
extends Node2D


@onready var _walls: TileMapLayer = $Walls


func get_tile_size() -> Vector2i:
	return _walls.tile_set.tile_size


func get_bounds() -> Rect2i:
	return _walls.get_used_rect()


func is_inside(cell: Vector2i) -> bool:
	return get_bounds().has_point(cell)


func is_wall(cell: Vector2i) -> bool:
	return _walls.get_cell_source_id(cell) != -1


func is_walkable(cell: Vector2i) -> bool:
	return is_inside(cell) and not is_wall(cell)


func cell_to_world(cell: Vector2i) -> Vector2:
	return _walls.to_global(_walls.map_to_local(cell))


func world_to_cell(world_pos: Vector2) -> Vector2i:
	return _walls.local_to_map(_walls.to_local(world_pos))


func get_neighbors(cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if is_walkable(cell + dir):
			result.append(cell + dir)
	return result


func get_walkable_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var rect := get_bounds()
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var cell := Vector2i(x, y)
			if is_walkable(cell):
				result.append(cell)
	return result
