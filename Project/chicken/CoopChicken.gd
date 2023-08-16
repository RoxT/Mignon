extends AnimatedSprite

export(Resource) var stats setget set_stats

onready var label : = $Label
onready var rest := $Rest
var target
var meander:float
var top_speed

signal clicked(chicken)

# Called when the node enters the scene tree for the first time.
func _ready():
	label.hide()
	if !stats:
		set_stats(Chicken.new())
	set_label()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		var new_pos:Vector2
		new_pos.x = move_toward(position.x, target.x, meander*delta)
		new_pos.y = move_toward(position.y, target.y, meander*delta)
		flip_h = new_pos.x < position.x
		if new_pos.distance_to(position) < 1:
			target = null
		else: 
			position = new_pos
	else:
		if randi() % 3 > 0:
			var view:Rect2= get_viewport_rect()
			var x = clamp(random_range(position.x), view.position.x+32,view.size.x-32)
			var y = clamp(random_range(position.y), view.position.y+64,view.size.y-32)
			target = Vector2(x, y)
			meander = rand_range(0, top_speed)
			play("run")
		else:
			rest.start(rand_range(0.5, 2))
			set_process(false)
			play("stand")

func random_range(v:float)->float:
	return rand_range(v-600, v+600)

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


func _on_Area2D_input_event(viewport:Node, event:InputEvent, shape_idx:int):
	if event.is_pressed():
		emit_signal("clicked", self)
