extends Sprite


var stats : Chicken
const t := "Speed: %s\nWins: %s\nRatio: %s%%"

# Called when the node enters the scene tree for the first time.
func _ready():
	stats = Chicken.new()
	if stats.white == true:
		texture = load("res://chicken/standing_chicken_white.png")
	modulate = stats.colour


func label(wins:int, rate:int):
	$Label.text = t % [str(stats.get_speed()), str(wins), str(rate)]
