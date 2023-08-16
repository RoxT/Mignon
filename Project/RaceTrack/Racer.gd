extends AnimatedSprite

var speed:=100
const START_LINE:= 65
onready var FINISH_LINE:= get_viewport_rect().end.x-64
const TRACK_SEPARATION:= 128
var track:=0 setget set_track

export(String) var nom := ""
export(Resource) var stats setget set_stats

signal finished(index)

# Called when the node enters the scene tree for the first time.
func _ready():
	position.x = START_LINE
	if !stats:
		set_stats(Chicken.new())
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
		emit_signal("finished", stats.index)
		$Trophy.show()

func set_track(value:int):
	track = value
	position.y = TRACK_SEPARATION * track
	
func set_stats(value:Chicken):
	if value:
		stats = value
		nom = stats.nom
		speed = stats.speed
		modulate = stats.colour
