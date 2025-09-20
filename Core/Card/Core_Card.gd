class_name CardUI
extends Control

@onready var hand:Hand = get_parent()

@onready var card = $Card
@onready var background = %Background
@onready var costLabel = %Cost
@onready var scoreLabel = %Score
@onready var imageTextureRect = %Image

var zoom_tween:Tween

func initialize_card(card_background:Texture2D, cost:int, score:int, image:Texture2D):
	background.texture = card_background
	costLabel.text = str(cost)
	scoreLabel.text = str(score)
	imageTextureRect.texture = image

func play_card_animation():
	var viewport_size = get_viewport_rect().size

	# Tween maître
	var master = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	## centrage et redressage de la carte
	z_index = 2
	master.tween_property(self, "position", Vector2(0, -viewport_size.y / 2), 0.3)
	master.tween_property(self, "rotation_degrees", 0, 0.2)
	master.tween_property(self, "scale", Vector2(3, 3), 0.2)
	
	
	$AudioStreamPlayer_play.play()
	
	## zoom out et suppression
	master.chain().tween_property(self, "scale", Vector2.ONE * 0.2, 1) \
					  .set_trans(Tween.TRANS_BACK) \
					  .set_ease(Tween.EASE_IN)
	master.tween_callback(Callable(self, "queue_free"))

func _on_mouse_entered() -> void:
	if is_instance_valid(zoom_tween):
		zoom_tween.kill()
		
	z_index = 1
	$AudioStreamPlayer_hover.play()
	zoom_tween = create_tween()
	zoom_tween.tween_property(self, "scale", Vector2(2, 2), 0.25)

func _on_mouse_exited() -> void:
	if is_instance_valid(zoom_tween):
		zoom_tween.kill()
		
	z_index = 0
		
	zoom_tween = create_tween()
	zoom_tween.tween_property(self, "scale", Vector2(1, 1), 0.25)

func disable_card():
	card.mouse_filter = MOUSE_FILTER_IGNORE

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action("select_card") and event.is_pressed() and not event.is_echo():
			disable_card()
			play_card_animation()
			hand.clear_all_cards(self)
			hand.card_played.emit()
	else:
		pass
