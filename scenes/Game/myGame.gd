extends Game
class_name MyGame

enum Ids {
	bigMushroom = 0,
	pumpkin,
	candle,
	manyMushroom,
	pumpkin2,
	pineCone2,
	acorn2,
	leaf,
	teapot,
	pineCone,
	umbrella,
	chestnut,
	mushroom3,
	pumpkin3,
	acorn
}

@onready var card_in_hand:Hand = %Cards_in_hand
@onready var map:Map = %Map
@onready var gui:Gui = $GUI
@onready var camera:Camera2D = %Camera2D
@onready var pts_labels:Control = %PtsLabels

const Max_Cards_Played = 25
var current_cards_played = 0

enum current_cards_data{pos, score}
var current_cards:Dictionary

var score := 0

var hover_id_tmp := 0

## Turn
# draw five cards
# each card have a unique id / building

func _ready() -> void:
	gui.set_cards(0, Max_Cards_Played)
	
	draw_cards()

func set_pts_label_pos(index:int, pos:Vector2):
	pts_labels.get_child(index).position = pos

func draw_cards():
	current_cards.clear()
	
	map.ghost_buildings.clear()
	
	var n_cards = 5
	
	var array_random_pos = map.get_n_random_pos(n_cards)
	
	var array:PackedByteArray
	
	for i in range(1, 15):
		array.append(i)
	
	var index = 0
	
	for i in n_cards:
		index = randi_range(0, array.size() - 1)
		
		var card_id = array[index]
		
		var random_pos = array_random_pos[i]
		
		current_cards[card_id] = {current_cards_data.pos:random_pos}
		
		current_cards[card_id][current_cards_data.score] = calculate_card_score(card_id)
		
		map.instantiate_ghost_building(card_id, random_pos)
		
		array.remove_at(index)
	
	card_in_hand.draw_card(current_cards)

func calculate_building_score(card_id:int, building_id:int) -> int:
	if building_id != -1 and card_id != building_id:
		return 1
		
	return 0

func calculate_card_score(id:Ids) -> int:
	var score := 0
	
	var ids = map.get_surrounded_tiles_ids(current_cards[id][current_cards_data.pos])
	
	for i_id in ids:
		score += calculate_building_score(id, i_id)
	
	return score

func _on_cards_in_hand_card_played(id:Ids) -> void:
	hover_id_tmp = 0
	
	map.build(id)
	
	score += current_cards[id][current_cards_data.score]
	
	gui.set_score(score)
	
	current_cards_played += 1
	
	gui.set_cards(current_cards_played, Max_Cards_Played)

func _on_cards_in_hand_drawing_card() -> void:
	$AudioStreamPlayer_drawing_card.play()
	pass # Replace with function body.

func _on_cards_in_hand_removing_card() -> void:
	$AudioStreamPlayer_removing_card.play()
	pass # Replace with function body.

func _on_cards_in_hand_clear_card_done() -> void:
	if current_cards_played < Max_Cards_Played:
		draw_cards()
	else:
		end_menu.end_message.text = "Your score: " + str(score)
		end_menu.show()
		get_tree().paused = true

func _on_cards_in_hand_hover_card(id: Variant) -> void:
	if hover_id_tmp != 0:
		map.unhover_ghost_building(hover_id_tmp)
	
	hover_id_tmp = id
	
	map.hover_ghost_building(id)
	
	var surrounded_ids = map.get_surrounded_tiles_data(current_cards[id][current_cards_data.pos])
	
	for i in surrounded_ids.size():
		var i_id = surrounded_ids[i][0]
	
		if i_id == -1:
			pts_labels.set_label_visible(i, false)
			continue
		
		var building_pos = map.map_to_local(surrounded_ids[i][1])
		
		pts_labels.set_label(i, building_pos, calculate_building_score(id, i_id))
		
		pts_labels.set_label_visible(i, true)
	
	camera.position = map.ghost_buildings[id][map.ghost_buildings_data.node].position
