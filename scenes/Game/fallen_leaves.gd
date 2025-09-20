extends Node2D

func _ready():
	var in_game = self.get_parent()
	
	if in_game.name == "Game" :
		print (in_game.name)
		self.position = Vector2(-640,-320)
