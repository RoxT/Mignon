extends AnimatedSprite

export(Resource) var stats setget set_stats
onready var label : = $Label
onready var rest := $Rest

onready var window_width:int = ProjectSettings.get_setting("display/window/size/width")
onready var window_height:int = ProjectSettings.get_setting("display/window/size/height")
onready var breeding_pen:Rect2
var pen:Rect2 setget set_pen

var breeding := false
var target
var meander:float
var top_speed

var dragging := false

signal clicked(chicken)

# Called when the node enters the scene tree for the first time.
func _ready():
	label.hide()
	if !stats:
		set_stats(Chicken.new())
	set_label()
	var ren_reference := get_parent().get_node("PenRect") as ReferenceRect
	breeding_pen = Rect2(ren_reference.rect_position, ren_reference.rect_size)


func _input(event:InputEvent):
	if dragging:
		
		if event is InputEventMouseButton:
			dragging = event.is_pressed()
		elif event is InputEventMouseMotion:
			position = get_viewport().get_mouse_position()
	else:
		drag(false)
			
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target and not dragging:
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
			if breeding:
				target = get_breeding_pen_target()
			else:
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
	
func set_pen(value:Rect2):
	pen = value
	if not breeding:
		if !pen.has_point(position):
			position = get_pen_target()
	target = null

func get_pen_target()->Vector2:
	var x := clamp(random_meander(position.x), pen.position.x + 32, pen.end.x-32)
	var y := clamp(random_meander(position.y), pen.position.y + 32, pen.end.y-32)
	return Vector2(x, y)

func get_breeding_pen_target()->Vector2:
	var x := rand_range(breeding_pen.position.x+32, breeding_pen.position.x + breeding_pen.size.x-32)
	var y := rand_range(breeding_pen.position.y+32, breeding_pen.position.y + breeding_pen.size.y-32)
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
		var text = stats.nom + ". " + str(stats.wins) + " wins."
		if stats.fatigue > 0:
			text += " Fatigue: " + str(stats.fatigue)
		label.text = text

func _on_Area2D_mouse_entered():
	label.show()


func _on_Area2D_mouse_exited():
	label.hide()


func _on_Rest_timeout():
	set_process(true)


func _on_Area2D_input_event(_viewport:Node, event:InputEvent, _shape_idx:int):
	if event.is_pressed():
		emit_signal("clicked", self)
		drag()


func drag(value:=true):
	dragging = value
	set_process_input(value)
	set_process(!value)
	target = null
