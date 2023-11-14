extends Panel

export(Resource) var stats setget set_stats
onready var portrait
onready var nom
onready var block : = $RichTextStats
onready var breed_btn
onready var name_edit

const breed_str := "Breed"
const breed_with_str := "Breed with "
const breed_stop_str := "Stop Breeding"
const portrait_scaling := Vector2(0.095, 0.095)
const sell_str := "Sell ($%s)"

signal chose_racer
signal requested_breed
signal sell_requested(price)
signal edited

# Called when the node enters the scene tree for the first time.
func _ready():
	breed_btn = get_node_or_null("Breed")
	if breed_btn:
		breed_btn = $Breed
		name_edit = $Name/NameEdit
		portrait = $Portrait
		nom = $Name
	show(false)
	if stats:
		set_stats(stats)

func set_stats(value:Chicken):
	if breed_btn:
		$Sell.disabled = false
		$Choose.disabled = false
		breed_btn.disabled = false
		name_edit.hide()
		breed_btn.text = breed_str
	stats = value
	if portrait:
		if stats.breed == "floof":
			portrait.texture = load("res://chicken/portraits/Test_Headshot.png")
			portrait.scale = portrait_scaling
		elif stats.breed == "bigger floof":
			portrait.texture = load("res://chicken/portraits/Test_Full_body.jpg")
			portrait.scale = portrait_scaling
		elif stats.breed == "rooster":
			portrait.texture = load("res://chicken/portraits/rooster.jpg")
			portrait.scale = Vector2(0.202, 0.202)
		elif stats.breed == "white":
			portrait.texture = load("res://chicken/portraits/white1.png")
			portrait.scale = Vector2.ONE
		else:
			portrait.texture = load("res://chicken/portraits/brown1.png")
			portrait.scale = Vector2.ONE
		portrait.modulate = stats.colour
		show()
	if nom:
		nom.text = stats.nom
		show()
	if block:
		block.clear()
		if stats.age >= 2:
			block.add_text("Breed: " + stats.breed.capitalize())
			block.newline()
			block.add_text("Wins: " + str(stats.wins))
			if stats.fatigue > 0:
				block.newline()
				block.add_text("Fatigue Level: " + str(stats.fatigue))
			block.newline()
		block.add_text("%s day%s old" % [str(stats.age), "" if stats.age == 1 else "s"])
		if stats.is_chick():
			block.add_text(" (chick)")
		block.newline()
		if stats.speed_guess == -1:
			block.add_text("Speed: ???")
		elif stats.speed_guess == stats.top_speed:
			block.add_text("Speed: " + str(stats.top_speed))
		else:
			block.add_text("Speed: " + str(round(stats.speed_guess)) + "?")
			
			
	if breed_btn:
		$Sell.text = sell_str % get_price()
		if stats.is_chick():
			$Choose.disabled = true
			breed_btn.disabled = true
	show()

func set_mate(mate:Node, mate2:Node, birthing:=false):
	if birthing: breed_btn.disabled = true
	if (mate and mate.stats == stats) or (mate2 and mate2.stats == stats):
		breed_btn.text = breed_stop_str
	elif mate2:
		breed_btn.text = breed_with_str + mate2.stats.nom
	elif mate:
		breed_btn.text = breed_with_str + mate.stats.nom
	else:
		breed_btn.text = breed_str

func show(value := true):
	block.visible = value
	if breed_btn:
		portrait.visible = value
		nom.visible = value
		$Choose.visible = value
		$Breed.visible = value
		$Sell.visible = value
		$Edit.visible = value
		
func _on_Human_clicked(child:bool, thoughts:Array):
	show(false)
	block.clear()
	if child:
		block.add_text("Age: Child")
	else:
		block.add_text("Age: Adult")
	block.newline()
	block.newline()
	block.newline()
	for thought in thoughts:
		block.add_text("\"" + thought + "\"")
		block.newline()
	block.show()

func stop_sell(value:bool):
	$Sell.disabled = value

func _on_Choose_pressed():
	emit_signal("chose_racer")

func _on_Breed_pressed():
	emit_signal("requested_breed")

func get_price()->int:
	var tired = 1-(stats.fatigue * 0.05)
	if stats.wins == 0:
		return int(5 * tired)
	return 5 + int((stats.wins * 10) * tired)

func _on_Sell_pressed():
	emit_signal("sell_requested", get_price())


func _on_Edit_pressed():
	if name_edit.visible == true:
		_on_NameEdit_text_entered(name_edit.text)
	else:
		name_edit.text = stats.nom
		name_edit.show()
		name_edit.grab_focus()


func _on_NameEdit_text_entered(new_text):
	stats.nom = new_text
	$Name.text = stats.nom
	name_edit.hide()
	emit_signal("edited")
