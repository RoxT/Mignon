extends AnimatedSprite

export(Resource) var stats setget set_stats
onready var label : = $Label
onready var rest := $Rest

onready var window_width:int = ProjectSettings.get_setting("display/window/size/width")
onready var window_height:int = ProjectSettings.get_setting("display/window/size/height")
var pen:Rect2

var target
var meander:float
var top_speed

signal clicked(chicken)

# Called when the node enters the scene tree for the first time.
func _ready():
	label.hide()
	set_label()
	if stats.is_chick(): scale = scale/2
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		var new_pos := Vector2(256, 256)
		new_pos.x = move_toward(position.x, target.x, meander*delta)
		new_pos.y = move_toward(position.y, target.y, meander*delta)
		flip_h = new_pos.x < position.x
		if new_pos.distance_to(position) < 1:
			target = null
		else: 
			position = new_pos
	else:
		if randi() % 3 > 0:
			target = get_pen_target()
			meander = rand_range(0, top_speed)
			play("run")
		else:
			wait()
			
func wait():
	target = null
	rest.start(rand_range(0.5, 2))
	set_process(false)
	play("stand")

func get_pen_target()->Vector2:
	var x := clamp(random_meander(position.x), pen.position.x + 32, pen.end.x-32)
	var y := clamp(random_meander(position.y), pen.position.y + 32, pen.end.y-32)
	return Vector2(x, y)

func random_meander(pos:float)->float:
	return rand_range(pos-600, pos+600)

func set_stats(value:Chicken):
	stats = value
	modulate = stats.colour
	top_speed = stats.get_speed()
	set_label()
	if stats.white:
		frames = load("res://chicken/animations_white.tres")

func set_label():
	if label:
		if stats.is_chick():
			label.text = stats.nom
		else:
			var text = stats.nom + ". " + "W: " + str(stats.wins)
			if stats.fatigue > 0:
				text += " F: " + str(stats.fatigue)
			label.text = text

func _on_Area2D_mouse_entered():
	label.show()


func _on_Area2D_mouse_exited():
	label.hide()


func _on_Rest_timeout():
	set_process(true)


func _on_TouchScreenButton_pressed():
	emit_signal("clicked", self)
