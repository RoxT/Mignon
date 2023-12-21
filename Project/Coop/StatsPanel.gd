extends Panel

export(Resource) var stats setget set_stats
onready var portrait:TextureRect
onready var nom
onready var block : = $RichTextStats
onready var breed_btn
onready var name_edit

const breed_str := "Breed"
const breed_with_str := "Breed with "
const breed_stop_str := "Stop Breeding"
const sell_str := "Sell ($%s)"
const panel_box:StyleBoxFlat = preload("res://resources/panel_stats.tres")

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
	get_tree().call_group("star", "queue_free")
	add_stylebox_override("panel", panel_box)
	if breed_btn:
		$Sell.disabled = false
		$Choose.disabled = false
		breed_btn.disabled = false
		name_edit.hide()
		breed_btn.text = breed_str
	stats = value
	if portrait:
		if stats.breed == M.RUSSIAN_ORLOFF:
			portrait.texture = load("res://chicken/portraits/Test_Headshot.png")
		elif stats.breed == M.SILKIE:
			portrait.texture = load("res://chicken/portraits/silkie.jpg")
		elif stats.breed == M.BROWN_ROOSTER:
			portrait.texture = load("res://chicken/portraits/brown_rooster.jpg")
		elif stats.breed == M.WHITE_CORNISH_HEN:
			portrait.texture = load("res://chicken/portraits/white_cornish_hen.png")
		elif stats.breed == M.POLISH_CHICKEN:
			portrait.texture = load("res://chicken/portraits/white_cornish_hen.png")
			
		else:
			portrait.texture = load("res://chicken/portraits/leghorn_brown.png")
		portrait.rect_size.y = 293
		portrait.modulate = stats.colour
		var bottom:float = portrait.rect_size.y
		for i in range(stats.fame):
			var star := TextureRect.new()
			star.add_to_group("star")
			star.texture = preload("res://chicken/fame.png")
			star.show_on_top = true
			portrait.add_child(star)
			star.rect_position = Vector2(star.rect_size.x * i, bottom-star.rect_size.y)
		show()
	if nom:
		nom.bbcode_text = "[b]"+stats.nom+"[b]"
		show()
	if block:
		block.clear()
		block.add_text("Breed: " + stats.breed.capitalize())
		block.newline()
		if stats.age >= 2:
			block.add_text("Wins: " + str(stats.wins))
			if stats.fatigue > 0:
				block.newline()
				block.add_text("Fatigue Level: " + str(stats.fatigue))
			block.newline()
		block.add_text("%s day%s old" % [str(stats.age), "" if stats.age == 1 else "s"])
		if stats.is_chick():
			block.add_text(" (chick)")
		elif stats.is_elderly():
			block.add_text(" (elderly) ")
		elif stats.is_mature():
			block.add_text(" (mature)")
		block.newline()
		if stats.speed_guess == -1:
			block.add_text("Speed: ???")
		elif stats.speed_guess == stats.top_speed:
			block.add_text("Speed: " + str(stats.top_speed))
		else:
			block.add_text("Speed: " + str(round(stats.speed_guess)) + "?")
			
			
	if breed_btn:
		$Sell.text = sell_str % stats.get_price()
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
		if stats.is_related(mate2.stats):
			breed_btn.disabled = true	
	elif mate:
		breed_btn.text = breed_with_str + mate.stats.nom
		if stats.is_related(mate.stats):
			breed_btn.disabled = true
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
		
func _on_Human_clicked(peon:Node, thoughts:Array):
	show(false)
	block.clear()
	if peon.child:
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

func _on_Sell_pressed():
	emit_signal("sell_requested", stats.get_price())

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
