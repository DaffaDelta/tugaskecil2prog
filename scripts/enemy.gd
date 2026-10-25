class_name Enemy
extends Entity


@export var think_interval := 0.4

var _think_timer: Timer


func _ready() -> void:
	super._ready()
	_think_timer = Timer.new()
	_think_timer.wait_time = think_interval
	_think_timer.autostart = true
	_think_timer.timeout.connect(_on_think)
	add_child(_think_timer)


func _on_think() -> void:
	if not active or _is_moving or _maze == null:
		return
	var next_cell := _choose_next_cell()
	if next_cell != _cell:
		try_move(next_cell - _cell)


func _choose_next_cell() -> Vector2i:
	return _cell
