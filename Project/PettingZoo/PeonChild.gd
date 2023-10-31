extends KinematicBody2D


var target
var speed := 500
onready var line := $Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if target:
		var motion = position.direction_to(target)*delta*speed
		var _body := move_and_collide(motion)
		line.clear_points()
		line.add_point(position)
		line.add_point(target)
		if position.distance_to(motion) <= 2:
			target = null
			print("hit")
	$Label.text = str(get_global_mouse_position())
		

func _on_ChickenSearch_area_entered(area:Area2D):
	
	target = area.global_position
		
	print(area.global_position)
