class_name CardUI
extends Control

@onready var hand:Hand = get_parent()

@onready var card = $Card
@onready var background = %Background
@onready var costLabel = %Cost
@onready var scoreLabel = %Score
@onready var imageTextureRect = %Image
@onready var nameLabel = %Name

var is_played:bool=false

var zoom_tween:Tween

var m_id:MyGame.Ids

const illustration_sprites = {
	MyGame.Ids.bigMushroom:preload("res://Assets/Building/Illustration/I_4.png"),
	MyGame.Ids.pumpkin:preload("res://Assets/Building/Illustration/I_9.png"),
	MyGame.Ids.candle:preload("res://Assets/Building/Illustration/I_6.png"),
	MyGame.Ids.manyMushroom:preload("res://Assets/Building/Illustration/I_1.png"),
	MyGame.Ids.pumpkin2:preload("res://Assets/Building/Illustration/I_5.png"),
	MyGame.Ids.pineCone2:preload("res://Assets/Building/Illustration/I_2.png"),
	MyGame.Ids.acorn2:preload("res://Assets/Building/Illustration/I_3.png"),
	MyGame.Ids.leaf:preload("res://Assets/Building/Illustration/I_0.png"),
	MyGame.Ids.teapot:preload("res://Assets/Building/Illustration/I_7.png"),
	MyGame.Ids.pineCone:preload("res://Assets/Building/Illustration/I_8.png"),
	MyGame.Ids.umbrella:preload("res://Assets/Building/Illustration/I_13.png"),
	MyGame.Ids.chestnut:preload("res://Assets/Building/Illustration/I_12.png"),
	MyGame.Ids.mushroom3:preload("res://Assets/Building/Illustration/I_10.png"),
	MyGame.Ids.pumpkin3:preload("res://Assets/Building/Illustration/I_11.png"),
	MyGame.Ids.acorn:preload("res://Assets/Building/Illustration/I_14.png")
}

func initialize_card(card_background:Texture2D, cost:int, score:int, id:int):
	background.texture = card_background
	imageTextureRect.texture = illustration_sprites[id]
	costLabel.text = str(cost)
	scoreLabel.text = str(score)

	m_id = id

	nameLabel.text = str(id)

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
	hand.hover_card.emit(m_id)
	
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
	if !is_played:
		zoom_tween = create_tween()
		zoom_tween.tween_property(self, "scale", Vector2(1, 1), 0.25)


func disable_card():
	card.mouse_filter = MOUSE_FILTER_IGNORE

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action("select_card") and event.is_pressed() and not event.is_echo():
		is_played = true
		disable_card()
		play_card_animation()
		hand.clear_all_cards(self)
		hand.card_played.emit(m_id)
	else:
		pass
