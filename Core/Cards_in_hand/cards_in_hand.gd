extends Control
class_name Hand

signal card_played
signal clear_card_done

signal drawing_card
signal removing_card

const Card_Background = [
	preload("res://Assets/Cards/greencard.svg"),
	preload("res://Assets/Cards/redcard.svg")
]

enum Ids {ChampiHouse}
enum Cards_Data {Texture, Type, Cost, Score}

const Cards = {
	Ids.ChampiHouse: {
		Cards_Data.Texture: preload("res://Assets/champi_maison.png"),
		Cards_Data.Type: MyGame.building_type.Production,
		Cards_Data.Cost: 1,
		Cards_Data.Score: 1
	}
}

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



#CARD SIZE
const RECT_W := 150
const RECT_H := 200
const ARC_RATIO := 0.8 #pourcentage de la largeur ecran

#const N := 8 # entre 3 et 6



func _ready():
	cards_deck(5)
	#rearrange_cards()
	#draw_card()
	create_blue_card(0,0,0)
	pass
	
	
func draw_card(N:int):
	
	var ARC_OPENING_DEG := N * 7 #angle de eventail
	var cam : Camera2D = get_parent().get_parent().get_node("Camera2D")
	var vp_size : Vector2 = get_viewport().size
	var zoom_factor : float = cam.zoom.x   # assume uniform zoom
	var visible_in_units : Vector2 = vp_size / zoom_factor
	print("Viewport (px):", vp_size)
	print("Visible area (world units):", visible_in_units)
	
	var SURFACE_W = vp_size.x
	var SURFACE_H = vp_size.y

	var Cx = 0
	var Cy = +420 #SURFACE_H - 600  # centre du cercle placé en dessous de l’écran
	var R = (SURFACE_W * ARC_RATIO) / 2.0
	var angle_span = deg_to_rad(ARC_OPENING_DEG)
	var angle_start = -angle_span / 2.0
#	var angle_end = +angle_span / 2.0
	var offset = -PI/2   # -> 0 rad = axe -Y
	

	for i in range(N):
		var angle = offset + angle_start + i * (angle_span / float(N - 1))
		var cx = Cx + R * cos(angle)
		var cy = Cy + R * sin(angle)
		var P_rect = Vector2(cx, cy)
		var P_arc = Vector2(Cx, Cy)  # centre du cercle
		var v = P_arc - P_rect
		var anglerect = Vector2(0, -1).angle_to(v)
		create_blue_card(cx,cy,anglerect)

func create_blue_card(cx:float,cy:float,anglerect:float):
	var home = Control.new()
	home.position=Vector2(cx,cy)
	var rect = ColorRect.new()
	rect.color = Color(0.3, 0.6, 1.0, 0.8)
	rect.size = Vector2(RECT_W, RECT_H)
	rect.pivot_offset = rect.size / 2.0
	rect.position = Vector2(-RECT_W/2, -RECT_H/2)
	print ("coord Carte: X=",cx,"Y=",cy)
	rect.rotation = anglerect
	home.add_child(rect)

	add_child(home)
	
func _process(_delta):
	pass
	
func create_card(id:Ids):
	var card = CARD.instantiate()
	add_child(card)
	
	var data = Cards[id];
	
	card.initialize_card(
		Card_Background[data[Cards_Data.Type]],
		data[Cards_Data.Cost],
		data[Cards_Data.Score],
		data[Cards_Data.Texture]
	)

func cards_deck(card_amount: int) -> void:
	draw_card(card_amount)
	#for child_index in range(card_amount):
		#create_card(Ids.ChampiHouse)
		

func clear_all_cards(except: CardUI = null):
	var tw0 = null
	var childrens = get_children()
	if childrens: tw0 = create_tween()
	for card in childrens:
		
		if card is CardUI and card != except:
			
			tw0.chain().tween_property(card, "scale", Vector2.ZERO, 0.5) \
			  .set_trans(Tween.TRANS_BACK) \
			  .set_ease(Tween.EASE_IN)
			tw0.chain().tween_callback(Callable(self, "remove_child").bind(card))
			tw0.chain().tween_callback(Callable(card, "queue_free"))
			tw0.chain().tween_callback(emit_removing_card)
	
	if childrens : 
		await tw0.finished
		print(name)
		clear_card_done.emit()
	

func emit_card_done():
	emit_signal("clear_card_done")

func emit_removing_card():
	removing_card.emit()

func emit_drawing_card():
	drawing_card.emit()

func calculate_position(card: CardUI) -> Vector2:
	var bottom_offset = get_viewport_rect().size.y / 30
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
		
		emit_drawing_card()

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
