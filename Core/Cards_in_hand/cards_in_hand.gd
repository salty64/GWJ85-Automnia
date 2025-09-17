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

#CARD SIZE
const RECT_W := 150
const RECT_H := 200
const ARC_RATIO := 0.8 #pourcentage de la largeur ecran

func _ready():
	draw_card(5)
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
		var anglerect = Vector2(0, 1).angle_to(v)
		create_card(Ids.ChampiHouse,Vector2(cx,cy),anglerect)
	
func _process(_delta):
	pass
	
func create_card(id:Ids, pos:Vector2, anglerect:float):
	var card = CARD.instantiate()
	card.position = pos
	card.rotation = anglerect
	add_child(card)
	
	var data = Cards[id];
	
	card.initialize_card(
		Card_Background[data[Cards_Data.Type]],
		data[Cards_Data.Cost],
		data[Cards_Data.Score],
		data[Cards_Data.Texture]
	)

func clear_all_cards(except: CardUI = null):
	var tw0:Tween = null
	var childrens = get_children()
	if childrens: tw0 = create_tween()
	for card in childrens:
		if card is CardUI and card != except:
			card.disable_card()
			
			tw0.tween_callback(emit_removing_card)
			tw0.tween_interval(0.2)
			tw0.chain().tween_property(card, "scale", Vector2.ZERO, 0.5) \
			  .set_trans(Tween.TRANS_BACK) \
			  .set_ease(Tween.EASE_IN)
			tw0.chain().tween_callback(Callable(self, "remove_child").bind(card))
			tw0.chain().tween_callback(Callable(card, "queue_free"))
	
	if childrens : 
		await tw0.finished
		clear_card_done.emit()

func emit_card_done():
	emit_signal("clear_card_done")

func emit_removing_card():
	removing_card.emit()

func emit_drawing_card():
	drawing_card.emit()
