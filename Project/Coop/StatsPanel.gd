extends Panel

export(Resource) var stats setget set_stats
onready var portrait := $Portrait
onready var nom := $Name
onready var block : = $RichTextStats
onready var breed := $Breed
onready var mate_label := $Breed/Label

const breed_str := "Breed"
const breed_with_str := "Breed with "

signal chose_racer
signal requested_breed(value)

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

func has_mate_ready(mate):
	if mate is Node:
		breed.pressed = mate.stats == stats
		if mate.stats != stats:
			mate_label.text = breed_with_str + mate.stats.nom
		else:mate_label.text = breed_str
			
	else:
		mate_label.text = breed_str

func show(value := true):
	portrait.visible = value
	nom.visible = value
	block.visible = value
	$Choose.visible = value
	$Breed.visible = value

func _on_Choose_pressed():
	emit_signal("chose_racer")

func _on_Breed_toggled(button_pressed):
	breed.pressed = button_pressed
	emit_signal("requested_breed", button_pressed)
