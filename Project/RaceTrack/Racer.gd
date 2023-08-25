extends AnimatedSprite

onready var sweat := $Sweat

onready var FINISH_LINE:int = ProjectSettings.get_setting("display/window/size/width")-64

export(Resource) var stats setget set_stats
var speed

signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	stop()
	
func start():
	set_process(true)
	if stats.fatigue > 0:
		sweat.show()
		if stats.fatigue < 3:
			speed_scale = 0.7
			sweat.play("1")
		else:
			speed_scale = 0.4
			sweat.play("2")
	else:
		speed_scale = 1
		sweat.hide()
	playing = true
	
func stop():
	if stats is Chicken and stats.is_exhausted():
		play("death")
	set_process(false)
	sweat.stop()
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
		speed = value.get_speed()
		modulate = stats.colour
		if stats.white:
			frames = load("res://chicken/animations_white.tres")
		animation = "run"
