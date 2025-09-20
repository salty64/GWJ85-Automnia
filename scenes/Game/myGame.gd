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

var current_cards:Dictionary

func _ready() -> void:
	var n_cards = 5
	
	map.add_new_rectangle_pts()
	
	var array_random_pos = map.get_n_random_pos(n_cards)
	
	var array:PackedByteArray
	
	for i in range(15):
		array.append(i)
	
	var index = 0
	
	for i in n_cards:
		index = randi_range(0, array.size() - 1)
		
		var card_id = array[index]
		
		current_cards[card_id] = array_random_pos[i]
		
		array.remove_at(index)
	
	card_in_hand.draw_card(current_cards.keys())

func _on_cards_in_hand_card_played() -> void:
	map.add_new_building_randomly()


func _on_cards_in_hand_drawing_card() -> void:
	$AudioStreamPlayer_drawing_card.play()
	pass # Replace with function body.


func _on_cards_in_hand_removing_card() -> void:
	$AudioStreamPlayer_removing_card.play()
	
	pass # Replace with function body.
