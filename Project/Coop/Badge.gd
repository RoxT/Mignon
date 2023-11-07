extends Sprite


export(int, 1, 2, 3) var rank
const PATH := "res://Coop/badge%s.png"

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = load(PATH % rank)
	modulate = Color.white
	self_modulate = Color.white
