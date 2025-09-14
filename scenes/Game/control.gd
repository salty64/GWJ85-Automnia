extends Control

@export var hand:Hand

func _on_button_3_pressed() -> void:
	hand.clear_all_cards()
	await hand.clear_card_done
	hand.cards_deck(3)
	hand.rearrange_cards()

	pass # Replace with function body.


func _on_button_4_pressed() -> void:
	hand.clear_all_cards()
	await hand.clear_card_done
	hand.cards_deck(4)
	hand.rearrange_cards()
	pass # Replace with function body.


func _on_button_5_pressed() -> void:
	hand.cards_deck(5)
	hand.rearrange_cards()
	pass # Replace with function body.


func _on_button_6_pressed() -> void:
	hand.cards_deck(1)
	hand.rearrange_cards()
	pass # Replace with function body.
