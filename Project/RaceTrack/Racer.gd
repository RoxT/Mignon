extends AnimatedSprite

const linear:Curve = preload("res://RaceTrack/linear_curve.tres")
const ease_in:Curve = preload("res://RaceTrack/ease_in_curve.tres")
const ease_out:Curve = preload("res://RaceTrack/ease_out_curve.tres")
const smooth:Curve = preload("res://RaceTrack/smooth_curve.tres")

onready var sweat := $Sweat
onready var tween:Tween = $Tween
onready var start_x:float = position.x

export(float) var finish_line = 0.0

export(Resource) var stats setget set_stats
var speed
var this_curve:Curve
var step

var distance:float
var time_s:float

var x_on_curve:float = 0.0
var s_passed:float = 0.0

signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)
	playing = false
	this_curve = [linear, ease_in, ease_in, smooth][randi()%4]
	
func start():
	assert(finish_line != 0.0)
	if speed == 0: speed = 4
	
	distance = finish_line+2-position.x
	time_s = distance/speed

	set_physics_process(true)
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
	set_physics_process(false)
	sweat.stop()
	playing = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	s_passed += delta
	x_on_curve = s_passed/time_s	
	var y_on_curve = this_curve.interpolate_baked(x_on_curve)
	var x_pos:float = start_x + y_on_curve * distance
	var speed_this_tick = (x_pos - position.x) / delta
	speed_scale = speed_this_tick / speed
	
	position.x = x_pos
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
