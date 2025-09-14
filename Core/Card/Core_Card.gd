class_name CardUI
extends Control

@onready var hand:Hand = get_parent() 
@export var rotation_curve : Curve;

@onready var artwork:Sprite2D = $Card/Bg 
@onready var titre = $Card/Bg/VBoxContainer/Name
@onready var m_cost = $Card/Bg/VBoxContainer/HBoxContainer/Cost
@onready var m_effect =  $Card/Bg/VBoxContainer/HBoxContainer/Effect

var parent: Control

var original_index := 0

var tween: Tween
var rotation_tween : Tween
var disabled := false
var card_anime = null
var card_rotation :float

func _ready():
	card_anime = get_node("card_anime")
	$Card/Bg/hover_control.show()

func animate_to_position(new_position: Vector2, duration: float, new_rotation: float) -> void:
	tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", new_position, duration)
	tween.tween_property(self, "rotation", -new_rotation, duration) #self.rotation = -new_rotation

func initialize_card(card_background:Texture2D, cost:int, score:int):
	artwork.texture = card_background
	m_cost.text = str(cost)
	m_effect.text = str(score)

func _on_control_mouse_entered():
	card_anime.play("focus")

func _on_control_mouse_exited():
	card_anime.play_backwards("focus")


func disable_mouse_input():
	$Card/Bg/hover_control.mouse_filter = MOUSE_FILTER_IGNORE
	$Card/Bg/hover_control.hide()   # <‑ désactive le node

	
func enable_mouse_input():
	$Card/Bg/hover_control.mouse_filter = MOUSE_FILTER_PASS
	

	
func _on_collider_input_event(event):
	if event.is_action("select_card") and event.is_pressed() and not event.is_echo():
			disable_mouse_input()
			play_card_animation()
			hand.card_played.emit()
	else:
		pass


func play_card_animation():

	var viewport_size = get_viewport_rect().size

	# Tween maître
	var master = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# carte jouée : monte puis zoom
	var up_pos = global_position - Vector2(0, 200) # monte de 50 pixels
	master.tween_property(self, "global_position", up_pos, 0.2)
	master.tween_property(self, "scale", Vector2.ONE * 2, 0.1)  # ajuster le zoom si besoin
	#master.tween_interval(0.08)

	## animer les autres cartes (scale -> 0) et les queue_free
	#if hand:
		#for card in hand.get_children():
			#if card is CardUI and card != self:
				#master.tween_property(card, "scale", Vector2.ZERO, 0.2) \
					  #.set_trans(Tween.TRANS_BACK) \
					  #.set_ease(Tween.EASE_IN)
				#master.tween_callback(Callable(card, "queue_free"))
	hand.clear_all_cards(self)

	## centrage er redressage de la carte
	var center_pos = Vector2(viewport_size.x / 2 - size.x / 2, viewport_size.y / 2 - size.y / 2)
	master.tween_property(self, "global_position", center_pos, 0.1)
	master.tween_property(self, "rotation_degrees", 0, 0.1)
	master.tween_property(self, "scale", Vector2.ONE * 3, 0.1)  # ajuster le zoom si besoin

	## zoom out et suppression
	master.tween_property(self, "global_position", center_pos- Vector2(0, 100), 0.1)
	master.tween_property(self, "scale", Vector2.ONE * 0.2, 0.2) \
					  .set_trans(Tween.TRANS_BACK) \
					  .set_ease(Tween.EASE_IN)
	master.tween_callback(Callable(self, "queue_free"))
	
	enable_mouse_input()
