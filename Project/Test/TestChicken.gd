extends AnimatedSprite


var stats : Chicken
const t := "Speed: %s\nWins: %s\nRatio: %s%%"

# Called when the node enters the scene tree for the first time.
func _ready():
	stats = Chicken.new()
	stats.apply_sprite(self)


func label(wins:int, rate:int):
	$Label.text = t % [str(stats.get_speed()), str(wins), str(rate)]
