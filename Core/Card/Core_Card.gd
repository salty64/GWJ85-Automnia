class_name CardUI
extends Control

@onready var hand:Hand = get_parent()
@export var rotation_curve : Curve;

@onready var background = %Background
@onready var costLabel = %Cost
@onready var scoreLabel = %Score
@onready var imageTextureRect = %Image

var parent: Control

var original_index := 0

var tween: Tween
var rotation_tween : Tween
var disabled := false
var card_anime = null
var card_rotation :float

var zoom_tween:Tween

func animate_to_position(new_position: Vector2, duration: float, new_rotation: float) -> void:
	tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", new_position, duration)
	tween.tween_property(self, "rotation", -new_rotation, duration) #self.rotation = -new_rotation

func initialize_card(card_background:Texture2D, cost:int, score:int, image:Texture2D):
	background.texture = card_background
	costLabel.text = str(cost)
	scoreLabel.text = str(score)
	imageTextureRect.texture = image

func play_card_animation():
	var viewport_size = get_viewport_rect().size

	# Tween maître
	var master = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var center_pos = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	# carte jouée : monte puis zoom
	#var up_pos = global_position #- Vector2(0, 200) 
	master.tween_property(self, "position", Vector2.ZERO, 0.2)
	#master.tween_property(self, "scale", Vector2.ONE * 2, 0.1)  # ajuster le zoom si besoin


	#hand.clear_all_cards(self)
#
	### centrage er redressage de la carte
	
	#master.chain().tween_property(self, "global_position", center_pos, 0.1)
	#master.tween_property(self, "rotation_degrees", 0, 0.1)
	#master.tween_property(self, "scale", Vector2.ONE * 3, 0.1)  
	#$AudioStreamPlayer_play.play()
	### zoom out et suppression
	#master.chain().tween_property(self, "global_position", center_pos- Vector2(0, 100), 0.1)
	#master.tween_property(self, "scale", Vector2.ONE * 0.2, 0.2) \
					  #.set_trans(Tween.TRANS_BACK) \
					  #.set_ease(Tween.EASE_IN)
	#master.tween_callback(Callable(self, "queue_free"))

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

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action("select_card") and event.is_pressed() and not event.is_echo():
			mouse_filter = MOUSE_FILTER_IGNORE
			play_card_animation()
			hand.card_played.emit()
	else:
		pass
