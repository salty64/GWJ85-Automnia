extends Control

func set_label(index:int, pos:Vector2, score:int):
	var handle = get_child(index)
	handle.position = pos
	
	var str = str(score)
	
	if score > 0:
		str = "+" + str
	
	handle.get_child(0).text = str

func set_label_visible(index:int, b:bool):
	get_child(index).get_child(0).visible = b
