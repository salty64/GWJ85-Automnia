extends CanvasLayer
class_name Gui

@onready var scoreLabel:Label = %ScoreLabel
@onready var cardLabel:Label = %CardLabel

var score_tmp := 0

var score_tween:Tween

func set_score(i:int):
	if is_instance_valid(score_tween):
		score_tween.kill()
	
	score_tween = create_tween()
	
	score_tween.tween_method(update_score_label, score_tmp, i, 0.5)
	score_tween.set_ease(Tween.EASE_OUT)
	score_tween.set_trans(Tween.TRANS_CIRC)

func update_score_label(i:int):
	score_tmp = i
	
	scoreLabel.text = str(score_tmp)

func set_cards(current_card:int, max_card:int):
	cardLabel.text = str(current_card) + "/" + str(max_card)
