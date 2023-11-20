extends AnimatedSprite

onready var sweat := $Sweat

export(float) var finish_line = 0.0

export(Resource) var stats setget set_stats
var speed

signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func start():
	assert(finish_line != 0.0)
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
	if position.x > finish_line:
		$Trophy.show()
		stats.wins += 1
		emit_signal("finished")
	
func set_stats(value:Chicken):
	if value:
		stats = value
		speed = value.get_speed()
		modulate = stats.colour
		value.apply_sprite(self)
		animation = "run"
