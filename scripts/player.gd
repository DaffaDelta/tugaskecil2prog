class_name Player
extends Entity



func _init() -> void:
	save_id = "player"


func _process(_delta: float) -> void:
	if _is_moving:
		return
	var dir := Vector2i.ZERO
	if Input.is_action_pressed("ui_right"):
		dir = Vector2i.RIGHT
	elif Input.is_action_pressed("ui_left"):
		dir = Vector2i.LEFT
	elif Input.is_action_pressed("ui_down"):
		dir = Vector2i.DOWN
	elif Input.is_action_pressed("ui_up"):
		dir = Vector2i.UP
	if dir != Vector2i.ZERO:
		try_move(dir)
