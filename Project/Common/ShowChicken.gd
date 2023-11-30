extends AnimatedSprite


export(Resource) var stats setget set_stats

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func set_stats(value:Chicken):
	if value:
		stats = value
		modulate = stats.colour
		value.apply_sprite(self)
		animation = "stand"
		$Name.text = stats.nom
		$Wins.text = "Wins: " + str(stats.wins)
