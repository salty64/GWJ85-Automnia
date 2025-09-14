extends Node2D
class_name Hand

signal clear_card_done

const CARD = preload("res://Core/Card/Core_Card.tscn")
@export_category("Curves")
@export var spread_curve: Curve
@export var height_curve: Curve
@export var rotation_curve: Curve

var current_card: CardUI
var card_index: int = 0
var hand_ratio: float = 0.5
var destination: Vector2
var rot_angle: int = 15
const ANIMATION_DURATION: float = 0.2
var mouse_pos: float

func _ready():
	cards_deck(5)
	rearrange_cards()

func _process(_delta):
	pass

func cards_deck(card_amount: int) -> void:
	for child_index in range(card_amount):
		var card = CARD.instantiate()
		add_child(card)
		card.initialize_card()

func clear_all_cards(except: CardUI = null):
	var tw0 = null
	var childrens = get_children()
	if childrens: tw0 = create_tween()
	for card in childrens:
		
		if card is CardUI and card != except:
			tw0.chain().tween_property(card, "scale", Vector2.ZERO, 0.3) \
			  .set_trans(Tween.TRANS_BACK) \
			  .set_ease(Tween.EASE_IN)
			tw0.chain().tween_callback(Callable(self, "remove_child").bind(card))
			tw0.chain().tween_callback(Callable(card, "queue_free"))
	
	
	if childrens : 
		await tw0.finished
		print(name)
		clear_card_done.emit()
	

func emit_card_done():
	print(name)
	emit_signal("clear_card_done")
	
	
func calculate_position(card: CardUI) -> Vector2:
	var bottom_offset = get_viewport_rect().size.y / 6
	var y_position = get_viewport_rect().size.y - bottom_offset - card.get_rect().size.y

	return Vector2(
		get_viewport_rect().get_center().x - card.get_rect().size.x / 2,
		y_position
	)


func calculate_card_destination(card: CardUI, ratio: float, width: float, height: float, new_position: Vector2 = Vector2.ZERO) -> Vector2:
	if new_position == Vector2.ZERO:
		position = calculate_position(card)
	mouse_pos = 0.0

	position.x += spread_curve.sample(ratio) * width
	position += height_curve.sample(ratio + mouse_pos) * Vector2.UP * height

	return position

func calculate_rotation(ratio: float, base_rotation: int) -> float:
	return rotation_curve.sample(ratio) * deg_to_rad(base_rotation)

func rearrange_cards() -> void:
	for card in get_children():
		current_card = card
		card_index = card.get_index()

		if get_child_count() > 1:
			hand_ratio = float(card_index) / float(get_child_count() - 1)
		else:
			hand_ratio = 0.5

		var hand_params = calculate_hand_parameters(get_child_count())
		destination = calculate_card_destination(card, hand_ratio, hand_params[0], hand_params[2])
		var new_rotation = calculate_rotation(hand_ratio, hand_params[1])

		card.animate_to_position(destination, ANIMATION_DURATION, new_rotation)

func calculate_hand_parameters(child_count: int) -> Vector3:
	if child_count == 2:
		return Vector3(40, 2, 10)
	elif child_count == 3:
		return Vector3(80, 8, 8)
	elif child_count <= 10:
		return Vector3(child_count * 50, 12, 25) # child_count * X espacement horizontal
	else:
		# Handle other cases or provide default values
		return Vector3(350, 12, 25)
