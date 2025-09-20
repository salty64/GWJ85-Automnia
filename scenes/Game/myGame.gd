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

enum current_cards_data{pos, score}
var current_cards:Dictionary

var score := 0

var hover_id_tmp := 0

## Turn
# draw five cards
# each card have a unique id / building

func _ready() -> void:
	draw_cards()

func draw_cards():
	current_cards.clear()
	
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
		
		array.remove_at(index)
	
	map.instantiate_ghost_buildings(current_cards)
	
	card_in_hand.draw_card(current_cards)

func calculate_card_score(id:Ids) -> int:
	var score := 0
	
	var ids = map.get_surrounded_tiles_ids(current_cards[id][current_cards_data.pos])
	
	for i_id in ids:
		if i_id != -1 and i_id != id:
			score += 1
	
	return score

func _on_cards_in_hand_card_played(id:Ids) -> void:
	hover_id_tmp = 0
	
	map.build(id)
	
	score += current_cards[id][current_cards_data.score]
	
	gui.set_score(score)

func _on_cards_in_hand_drawing_card() -> void:
	$AudioStreamPlayer_drawing_card.play()
	pass # Replace with function body.

func _on_cards_in_hand_removing_card() -> void:
	$AudioStreamPlayer_removing_card.play()
	pass # Replace with function body.

func _on_cards_in_hand_clear_card_done() -> void:
	draw_cards()

func _on_cards_in_hand_hover_card(id: Variant) -> void:
	if hover_id_tmp != 0:
		map.unhover_ghost_building(hover_id_tmp)
	
	hover_id_tmp = id
	
	map.hover_ghost_building(id)
