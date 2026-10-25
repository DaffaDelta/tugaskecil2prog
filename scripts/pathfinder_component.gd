class_name PathfinderComponent
extends Node


var _maze: MazeGrid
var _astar := AStarGrid2D.new()


func setup(maze: MazeGrid) -> void:
	_maze = maze
	rebuild()


func rebuild() -> void:
	var rect := _maze.get_bounds()
	_astar.region = rect
	_astar.cell_size = Vector2(_maze.get_tile_size())
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.update()

	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var cell := Vector2i(x, y)
			if _maze.is_wall(cell):
				_astar.set_point_solid(cell, true)


func find_path(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if not _is_valid(from) or not _is_valid(to):
		return result
	result.assign(_astar.get_id_path(from, to))
	return result


func find_world_path(from: Vector2i, to: Vector2i) -> PackedVector2Array:
	var points := PackedVector2Array()
	for cell in find_path(from, to):
		points.append(_maze.cell_to_world(cell))
	return points


func _is_valid(cell: Vector2i) -> bool:
	return _astar.region.has_point(cell) and not _astar.is_point_solid(cell)
