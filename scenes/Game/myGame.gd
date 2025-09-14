extends Game

@onready var map:Map = %Map

func _on_cards_in_hand_card_played() -> void:
	map.add_new_building_randomly()
