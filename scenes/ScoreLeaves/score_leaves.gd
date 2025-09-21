extends Sprite2D

var camera:Camera2D
var target 
var speed

func _ready() -> void:
	var offset = Vector2(0,get_viewport_rect().size.y/2)
	speed = randf_range(70,200)
	modulate.h = randf_range(0,0.30)
	
	print(camera.position - offset,get_viewport_rect().size.y/2)
	
	
func _process(delta: float) -> void:
	var target = Vector2(camera.position.x,camera.position.y-360) 
	var dir = position.direction_to(target)
	position += dir * speed * delta
	
	if position.distance_to(target)<1.5:
		queue_free()
	
