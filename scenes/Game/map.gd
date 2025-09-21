extends Node2D
class_name Map

const Building_Sprite = preload("res://scenes/BuildingSprite/building_sprite.tscn")

var tile_size = 128

var available_pos:PackedVector2Array

var available_pos_rect := Rect2i(-1, -1, 3, 3)

const map_width = 7
var tiles:PackedInt32Array

enum ghost_buildings_data{pos, node}
var ghost_buildings:Dictionary

const building_sprites = {
	MyGame.Ids.bigMushroom:preload("res://Assets/Building/Iso/B_4.png"),
	MyGame.Ids.pumpkin:preload("res://Assets/Building/Iso/B_9.png"),
	MyGame.Ids.candle:preload("res://Assets/Building/Iso/B_6.png"),
	MyGame.Ids.manyMushroom:preload("res://Assets/Building/Iso/B_1.png"),
	MyGame.Ids.pumpkin2:preload("res://Assets/Building/Iso/B_5.png"),
	MyGame.Ids.pineCone2:preload("res://Assets/Building/Iso/B_2.png"),
	MyGame.Ids.acorn2:preload("res://Assets/Building/Iso/B_3.png"),
	MyGame.Ids.leaf:preload("res://Assets/Building/Iso/B_0.png"),
	MyGame.Ids.teapot:preload("res://Assets/Building/Iso/B_7.png"),
	MyGame.Ids.pineCone:preload("res://Assets/Building/Iso/B_8.png"),
	MyGame.Ids.umbrella:preload("res://Assets/Building/Iso/B_13.png"),
	MyGame.Ids.chestnut:preload("res://Assets/Building/Iso/B_12.png"),
	MyGame.Ids.mushroom3:preload("res://Assets/Building/Iso/B_10.png"),
	MyGame.Ids.pumpkin3:preload("res://Assets/Building/Iso/B_11.png"),
	MyGame.Ids.acorn:preload("res://Assets/Building/Iso/B_14.png")
}

func set_tile(pos:Vector2i, id:MyGame.Ids):
	var index = pos.y * map_width + pos.x

	if index > tiles.size() - 1:
		return

	tiles[index] = id

func get_tile(pos:Vector2i) -> int:
	var index = pos.y * map_width + pos.x

	if index > tiles.size() - 1:
		return -1

	return tiles[pos.y * map_width + pos.x]

func get_surrounded_tiles_ids(pos:Vector2i) -> PackedInt32Array:
	var out_array:PackedInt32Array
	out_array.resize(8)

	var surrouded_pos = PackedVector2Array([
		Vector2i(0, -1),
		Vector2i(1, -1),
		Vector2i(1, 0),
		Vector2i(1, 1),
		Vector2i(0, 1),
		Vector2i(-1, 1),
		Vector2i(-1, 0),
		Vector2i(-1, -1)
	])

	for i in surrouded_pos.size():
		var i_pos:Vector2i = surrouded_pos[i]

		var next_pos:Vector2i = pos + i_pos

		var id = get_tile(next_pos)

		out_array[i] = id

	return out_array

func _ready() -> void:
	tiles.resize(49)
	tiles.fill(-1)
	
	add_new_rectangle_pts()

	var sprite = Building_Sprite.instantiate()

	sprite.texture = building_sprites[0]

	add_child(sprite)

	set_tile(Vector2i(0, 0), MyGame.Ids.bigMushroom)

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
	
func instantiate_ghost_buildings(dic:Dictionary):
	ghost_buildings = dic.duplicate(true)

	for id in dic:
		var sprite = Building_Sprite.instantiate()

		sprite.texture = building_sprites[id]

		sprite.self_modulate.a = 0.5

		var pos = ghost_buildings[id][ghost_buildings_data.pos]

		sprite.position = Vector2(150, 174) * (pos.x * Vector2(1, 0.5) + pos.y * Vector2(-1, 0.5))

		ghost_buildings[id][ghost_buildings_data.node] = sprite

		add_child(sprite)

func hover_ghost_building(id:MyGame.Ids):
	var sprite = ghost_buildings[id][ghost_buildings_data.node]
	
	sprite.self_modulate = Color.GREEN
	sprite.self_modulate.a = 0.5
	
func unhover_ghost_building(id:MyGame.Ids):
	var sprite = ghost_buildings[id][ghost_buildings_data.node]
	
	sprite.self_modulate = Color.WHITE
	sprite.self_modulate.a = 0.5

func build(id:MyGame.Ids):
	for i_id in ghost_buildings:
		if i_id == id:
			ghost_buildings[i_id][ghost_buildings_data.node].self_modulate = Color.WHITE
			
			set_tile(ghost_buildings[i_id][ghost_buildings_data.pos], i_id)
			continue
		
		available_pos.append(ghost_buildings[i_id][ghost_buildings_data.pos])

		ghost_buildings[i_id][ghost_buildings_data.node].queue_free()

func get_random_pos() -> Vector2i:
	if available_pos.is_empty():
		available_pos_rect.position -= Vector2i.ONE
		available_pos_rect.size += Vector2i(2, 2)

		add_new_rectangle_pts()

	var index = randi_range(0, available_pos.size() - 1)
	
	var pos = available_pos[index]
	
	available_pos.remove_at(index)
	
	return pos
	
func get_n_random_pos(n:int) -> PackedVector2Array:
	var array_out:PackedVector2Array

	for i in n:
		array_out.append(get_random_pos())

	return array_out
