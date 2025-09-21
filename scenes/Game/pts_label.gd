extends Label

var follow_pos := Vector2.ZERO

func _process(_delta: float) -> void:
	position = follow_pos
