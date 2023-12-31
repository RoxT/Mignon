extends AnimatedSprite

export(Resource) var stats setget set_stats
onready var label : = $Label
onready var rest := $Rest

onready var window_width:int = ProjectSettings.get_setting("display/window/size/width")
onready var window_height:int = ProjectSettings.get_setting("display/window/size/height")
var breeding_pen:Rect2
var pen:Rect2
var zoom:float

var breeding := false setget set_breeding
var birthing := false
var target
var meander:float
var top_speed

var dragging := false

signal clicked(chicken)
signal unclicked(chicken)

# Called when the node enters the scene tree for the first time.
func _ready():
	label.hide()
	set_label()
	var ren_reference := get_parent().get_node("BreedingPen/PenRect") as ReferenceRect
	breeding_pen = Rect2(ren_reference.rect_position, ren_reference.rect_size)
	set_process_input(false)
	if stats.is_chick(): scale = scale/2


func _input(event:InputEvent):
	if dragging:
		if event is InputEventMouseButton:
			dragging = event.is_pressed()
		elif event is InputEventMouseMotion:
			position = get_global_mouse_position()
			
		

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

func get_pen_target()->Vector2:
	var x := clamp(random_meander(position.x), pen.position.x + 32, pen.end.x-32)
	var y := clamp(random_meander(position.y), pen.position.y + 32, pen.end.y-32)
	return Vector2(x, y)

func get_breeding_pen_target()->Vector2:
	var projected_pen := get_projected_pen()
	var x := rand_range(projected_pen.position.x,projected_pen.end.x)
	var y := rand_range(projected_pen.position.y, projected_pen.end.y)
	return Vector2(x, y)
	
func get_projected_pen()->Rect2:
	var p := Vector2(pen.end.x, pen.end.y-breeding_pen.size.y*zoom)
	var s := breeding_pen.size*zoom
	return Rect2(p, s)
	
func get_width()->int:
	return frames.get_frame(animation, frame).get_width()

func random_meander(pos:float)->float:
	return rand_range(pos-600, pos+600)

func set_stats(value:Chicken):
	stats = value
	top_speed = stats.get_speed()
	set_label()
	value.apply_sprite(self)

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


func drag(value:=true):
	if not stats.is_chick():
		dragging = value
		set_process_input(value)
		set_process(!value)
		target = null
	if value:
		emit_signal("clicked", self)
	else:
		emit_signal("unclicked", self)


func _on_TouchScreenButton_pressed():
	if not birthing:
		drag()


func _on_TouchScreenButton_released():
	if not birthing:
		drag(false)

func set_breeding(value:bool):
	breeding = value
	if not value: birthing = false
