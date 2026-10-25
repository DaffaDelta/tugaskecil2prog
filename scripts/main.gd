extends Node2D


enum State { PLAYING, WON, LOST }

@export var player_start := Vector2i(-19, 10)
@export var exit_cell := Vector2i(18, -12)
@export var chaser_starts: Array[Vector2i] = [Vector2i(10, 1)]
@export var wanderer_starts: Array[Vector2i] = [Vector2i(1, 10)]

@export_group("Sprites (opsional)")
@export var player_texture: Texture2D
@export var chaser_texture: Texture2D
@export var wanderer_texture: Texture2D
@export var exit_texture: Texture2D

@onready var _maze: MazeGrid = $Maze
@onready var _camera: Camera2D = $Camera2D
@onready var _info_label: Label = $HUD/InfoLabel

var _pathfinder: PathfinderComponent
var _player: Player
var _enemies: Array[Enemy] = []
var _hint_line: Line2D
var _state := State.PLAYING
var _elapsed := 0.0
var _steps := 0
var _message := ""


func _ready() -> void:
	_pathfinder = PathfinderComponent.new()
	add_child(_pathfinder)
	_pathfinder.setup(_maze)

	_spawn_entities()
	_setup_hint_line()
	_fit_camera()
	queue_redraw()


func _spawn_entities() -> void:
	_player = Player.new()
	_player.texture = player_texture
	add_child(_player)
	_player.setup(_maze, player_start)
	_player.moved.connect(_on_player_moved)

	for i in chaser_starts.size():
		var chaser := ChaserEnemy.new()
		chaser.save_id = "chaser_%d" % i
		chaser.texture = chaser_texture
		add_child(chaser)
		chaser.setup(_maze, chaser_starts[i])
		chaser.set_target(_player, _pathfinder)
		chaser.moved.connect(_on_enemy_moved)
		_enemies.append(chaser)

	for i in wanderer_starts.size():
		var wanderer := WandererEnemy.new()
		wanderer.save_id = "wanderer_%d" % i
		wanderer.texture = wanderer_texture
		add_child(wanderer)
		wanderer.setup(_maze, wanderer_starts[i])
		wanderer.moved.connect(_on_enemy_moved)
		_enemies.append(wanderer)


func _setup_hint_line() -> void:
	_hint_line = Line2D.new()
	_hint_line.width = 3.0
	_hint_line.default_color = Color(1, 1, 0, 0.8)
	_hint_line.z_index = 1
	_hint_line.visible = false
	add_child(_hint_line)


func _fit_camera() -> void:
	var tile := Vector2(_maze.get_tile_size())
	var bounds := _maze.get_bounds()
	var world_size := Vector2(bounds.size) * tile
	var top_left := _maze.cell_to_world(bounds.position) - tile / 2.0
	_camera.global_position = top_left + world_size / 2.0
	var view := get_viewport_rect().size
	var z := minf(view.x / world_size.x, view.y / world_size.y) * 0.9
	_camera.zoom = Vector2(z, z)


func _draw() -> void:
	var tile := Vector2(_maze.get_tile_size())
	var pos := to_local(_maze.cell_to_world(exit_cell))
	var rect := Rect2(pos - tile * 0.4, tile * 0.8)
	if exit_texture:
		draw_texture_rect(exit_texture, Rect2(pos - tile / 2.0, tile), false)
	else:
		draw_rect(rect, Color.GOLD)


func _process(delta: float) -> void:
	if _state == State.PLAYING:
		_elapsed += delta
	_update_hud()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	match key.keycode:
		KEY_K: _save()
		KEY_L: _load()
		KEY_H: _toggle_hint()
		KEY_R: get_tree().reload_current_scene()


# Aturan game
func _on_player_moved(cell: Vector2i) -> void:
	_steps += 1
	_refresh_hint()
	if cell == exit_cell:
		_message = "KAMU MENANG!"
		_set_state(State.WON)
	else:
		_check_collision()


func _on_enemy_moved(_cell: Vector2i) -> void:
	_check_collision()


func _check_collision() -> void:
	if _state != State.PLAYING:
		return
	for enemy in _enemies:
		if enemy.get_cell() == _player.get_cell():
			_message = "KAMU TERTANGKAP!"
			_set_state(State.LOST)
			return


func _set_state(new_state: State) -> void:
	_state = new_state
	var is_playing := new_state == State.PLAYING
	_player.active = is_playing
	for enemy in _enemies:
		enemy.active = is_playing


# Pathfinding
func _toggle_hint() -> void:
	_hint_line.visible = not _hint_line.visible
	_refresh_hint()


func _refresh_hint() -> void:
	if not _hint_line.visible:
		return
	var points := PackedVector2Array()
	for p in _pathfinder.find_world_path(_player.get_cell(), exit_cell):
		points.append(to_local(p))
	_hint_line.points = points


# Save & Load
func _save() -> void:
	var ok: bool = SaveManager.save_game({"elapsed": _elapsed, "steps": _steps})
	_message = "Game tersimpan." if ok else "Gagal menyimpan!"


func _load() -> void:
	if not SaveManager.has_save():
		_message = "Belum ada data save."
		return
	var extra: Dictionary = SaveManager.load_game()
	_elapsed = float(extra.get("elapsed", 0.0))
	_steps = int(extra.get("steps", 0))
	_set_state(State.PLAYING)
	_refresh_hint()
	_message = "Game dimuat."


func _update_hud() -> void:
	_info_label.text = "
	%s \n
	Waktu: %.1f s \n
	Langkah: %d\n
	\n
	[Arrow] Move\n
	[H] petunjuk\n
	[K] simpan\n
	[L] muat\n
	[R] ulang" % [_message, _elapsed, _steps]
