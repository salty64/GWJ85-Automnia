extends Node2D
class_name Map

var godot = preload("res://icon.svg")

var tile_size = 128

var available_pos:PackedVector2Array

var available_pos_rect := Rect2i(-1, -1, 3, 3)

func add_new_rectangle_pts():
	for i in range(available_pos_rect.size.x):
		for j in range(available_pos_rect.size.y):
			if (i == 0 or i == available_pos_rect.size.x - 1) or\
				(j == 0 or j == available_pos_rect.size.y - 1):
				available_pos.append(
					Vector2i(
						available_pos_rect.position.x + i,
						available_pos_rect.position.y + j
				))
	pass

func instantiate_building(pos:Vector2i):
	var sprite = Sprite2D.new()
	
	sprite.texture = godot
	
	sprite.position = Vector2i(pos.x * tile_size, pos.y * tile_size)
	
	add_child(sprite)
	
func get_random_pos() -> Vector2i:
	if available_pos.is_empty():
		available_pos_rect.position -= Vector2i.ONE
		available_pos_rect.size += Vector2i(2, 2)
		
		add_new_rectangle_pts()
	
	var index = randi_range(0, available_pos.size() - 1)
	
	var pos = available_pos[index]
	
	available_pos.remove_at(index)
	
	return pos
	
func add_new_building_randomly():
	instantiate_building(get_random_pos())

func _ready() -> void:
	add_new_rectangle_pts()
	
	var sprite = Sprite2D.new()
	
	sprite.texture = godot
	
	add_child(sprite)
