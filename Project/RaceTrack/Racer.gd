extends AnimatedSprite

var speed:int
onready var FINISH_LINE:= get_viewport_rect().end.x-64

export(Resource) var stats setget set_stats

signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	stop()
	
func start():
	set_process(true)
	playing = true
	
func stop():
	set_process(false)
	playing = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += speed * delta
	if position.x > FINISH_LINE:
		$Trophy.show()
		stats.wins += 1
		emit_signal("finished")
	
func set_stats(value:Chicken):
	if value:
		stats = value
		speed = stats.speed
		modulate = stats.colour
		if stats.white:
			frames = load("res://chicken/animations_white.tres")
