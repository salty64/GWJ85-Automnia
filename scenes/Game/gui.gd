extends CanvasLayer
class_name Gui

@onready var scoreLabel:Label = %ScoreLabel

func set_score(i:int):
	scoreLabel.text = str(i)
