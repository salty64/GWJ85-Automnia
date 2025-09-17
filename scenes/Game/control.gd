extends Control

@export var hand:Hand

func _on_button_3_pressed() -> void:
	hand.clear_all_cards()
	await hand.clear_card_done
	hand.draw_card(3)

	pass # Replace with function body.


func _on_button_4_pressed() -> void:
	hand.clear_all_cards()
	await hand.clear_card_done
	hand.draw_card(4)
	pass # Replace with function body.


func _on_button_5_pressed() -> void:
	hand.draw_card(5)
	pass # Replace with function body.


func _on_button_6_pressed() -> void:
	hand.draw_card(1)
	pass # Replace with function body.
