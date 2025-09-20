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
	var array:PackedByteArray
	
	for i in range(15):
		array.append(i)
		
	var out_array:PackedByteArray
	
	var index = 0
	
	for i in range(5):
		index = randi_range(0, array.size() - 1)
		
		out_array.append(array[index])
		
		array.remove_at(index)
	
	card_in_hand.draw_card(out_array)

func _on_cards_in_hand_card_played() -> void:
	map.add_new_building_randomly()


func _on_cards_in_hand_drawing_card() -> void:
	$AudioStreamPlayer_drawing_card.play()
	pass # Replace with function body.


func _on_cards_in_hand_removing_card() -> void:
	$AudioStreamPlayer_removing_card.play()
	
	pass # Replace with function body.
