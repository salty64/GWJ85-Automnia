extends Node2D

func _ready():
	var in_game = self.get_parent()
	
	if in_game.name == "Game" :
		self.position = Vector2(-640,-320)
