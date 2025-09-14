extends Node2D
class_name Map

var godot = preload("res://icon.svg")

var tile_size = 128

var available_pos:PackedVector2Array = [
	Vector2i(1, 0),
	Vector2i(1, 1),
	Vector2i(0, 1),
	Vector2i(-1, 1),
	Vector2i(-1, 0),
	Vector2i(-1, -1),
	Vector2i(0, -1),
	Vector2i(1, -1),
]

func instantiate_building(pos:Vector2i):
	var sprite = Sprite2D.new()
	
	sprite.texture = godot
	
	sprite.position = Vector2i(pos.x * tile_size, pos.y * tile_size)
	
	add_child(sprite)
	
func get_random_pos() -> Vector2i:
	var index = randi_range(0, available_pos.size() - 1)
	
	var pos = available_pos[index]
	
	available_pos.remove_at(index)
	
	return pos
	
func add_new_building_randomly():
	instantiate_building(get_random_pos())

func _ready() -> void:
	var sprite = Sprite2D.new()
	
	sprite.texture = godot
	
	add_child(sprite)
