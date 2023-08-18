extends Panel

export(Resource) var stats setget set_stats
onready var portrait := $Portrait
onready var nom := $Name
onready var block : = $RichTextStats

# Called when the node enters the scene tree for the first time.
func _ready():
	show(false)
	if stats:
		set_stats(stats)

func set_stats(value:Chicken):
	stats = value
	if portrait:
		if stats.white:
			portrait.texture = load("res://chicken/portraits/white1.png")
		else:
			portrait.texture = load("res://chicken/portraits/brown1.png")
		portrait.modulate = stats.colour
		show()
	if nom:
		nom.text = stats.nom
		show()
	if block:
		block.clear()
		block.add_text("Wins: " + str(stats.wins))
		block.newline()
		if stats.fatigue > 0:
			block.add_text("Fatigue Level: " + str(stats.fatigue))
	show()

			

func show(value := true):
	portrait.visible = value
	nom.visible = value
	block.visible = value
