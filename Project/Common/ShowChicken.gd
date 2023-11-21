extends AnimatedSprite


export(Resource) var stats setget set_stats

# Called when the node enters the scene tree for the first time.
func _ready():
	if stats == null:
		push_warning("Random chicken loaded into Show")
		var save_game = load(AllChickens.PATH) as AllChickens
		save_game.save()
		var chickens:Array = save_game.get_all()
		set_stats(chickens[randi() % chickens.size()])


func set_stats(value:Chicken):
	if value:
		stats = value
		modulate = stats.colour
		value.apply_sprite(self)
		animation = "stand"
		$Name.text = stats.nom
		$Wins.text = "Wins: " + str(stats.wins)
