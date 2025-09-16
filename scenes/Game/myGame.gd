extends Game
class_name MyGame

enum building_type{Production, Residence}

@onready var map:Map = %Map

func _on_cards_in_hand_card_played() -> void:
	map.add_new_building_randomly()


func _on_cards_in_hand_drawing_card() -> void:
	$AudioStreamPlayer_drawing_card.play()
	pass # Replace with function body.


func _on_cards_in_hand_removing_card() -> void:
	$AudioStreamPlayer_removing_card.play()
	
	pass # Replace with function body.
