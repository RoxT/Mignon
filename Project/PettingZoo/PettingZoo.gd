extends Node2D

onready var Adult:PackedScene= preload("res://PettingZoo/PeonAdult.tscn")
onready var Child:PackedScene= preload("res://PettingZoo/PeonChild.tscn")
onready var camera := $Camera2D
onready var report = $UI/ReportPanel
onready var final_report:RichTextLabel = $UI/ReportPanel/FinalReport

var save_game:AllChickens
var pen:ReferenceRect
var child_count := 0.0
var adult_count := 0.0
var fatigue_penalty := false
var many_fatigue_penalty := false
const FATIGUE_MULTIPLIER := 0.80
const MANY_FATIGUE_MULIPLIER := 0.4
const FLUSH_MULTIPLIER := 1.6
const TWO_PAIR_MULTIPLIER := 1.5
const RAINBOW_MODIFIER := 1.2
const MANY_BREEDS_MODIFIER := 1.15
const ALL_BREEDS_MODIFIER := 1.2
var uncommon_chickens := 0
var uncommon_breeds:Array = M.get_uncommon_list().duplicate()
var modifiers := []
var total:float
var pen_modifier := 1.0
var breeds := []
var colours:= []

# Called when the node enters the scene tree for the first time.
func _ready():
	$UI/PeonStatsPanel/RichTextStats.text = "Click on a guest to see what they're saying"
	$UI/PeonStatsPanel/RichTextStats.show()
	
	var chicken_stats := []
	save_game = load(AllChickens.PATH) as AllChickens
	save_game.save()
	chicken_stats = save_game.get_all()
	
	var pen_name = save_game.pen
	pen = get_node("Pens/" + pen_name) as ReferenceRect
	$TextureRect.texture = load("res://Coop/Grass%s.jpg" % pen_name)
	$TextureRect.rect_position = pen.rect_position
		
	match pen_name:
		"Starter": 
			camera.zoom = Vector2(0.7, 0.7)
		"Medium": 
			camera.zoom = Vector2(0.8, 0.8)
			pen_modifier = 0.6
		"Large": 
			camera.zoom = Vector2(1.0, 1.0)
			pen_modifier = 0.25
	
	var tired := 0
	for stats in chicken_stats:
		stats = stats as Chicken
		var chicken = preload("res://PettingZoo/PettingChicken.tscn").instance()
		chicken.stats = stats
		add_child(chicken)
		chicken.connect("clicked", self, "_on_chicken_clicked")
		var rect := pen.get_rect()
		chicken.pen = rect
		chicken.position = Vector2(rand_range(rect.position.x, rect.position.x + rect.size.x), rand_range(rect.position.y, rect.position.y + rect.size.y))
		if not stats.breed in breeds: 
			breeds.append(stats.breed)
		if not stats.colour in colours: 
			colours.append(stats.colour)
		
		
		if stats.top_speed >= 280:
			adult_count += 1
			if uncommon_breeds.has(stats.breed):
				uncommon_chickens += 1
				adult_count += 1			
		else:
			child_count += 1
			if uncommon_breeds.has(stats.breed):
				uncommon_chickens += 1
				child_count += 1
		
		if stats.is_chick():
			if stats.fatigue >= 5:
				tired += 1
		elif stats.fatigue >= 3:
			tired += 1
	

	if tired/(adult_count+child_count) >= 0.5:
		many_fatigue_penalty = true
		modifiers.append(MANY_FATIGUE_MULIPLIER)
	elif tired >= 2:
		fatigue_penalty = true
		modifiers.append(FATIGUE_MULTIPLIER)
	
	if breeds.size() == 1:
		modifiers.append(FLUSH_MULTIPLIER)
	elif breeds.size() == 2:
		modifiers.append(TWO_PAIR_MULTIPLIER)
	elif breeds.size() == M.BREEDS_LIST.size():
		modifiers.append(ALL_BREEDS_MODIFIER)
	elif breeds.size() > 0.5 * M.BREEDS_LIST.size():
		modifiers.append(MANY_BREEDS_MODIFIER)
		
	if breeds.size() >= 5:
		modifiers.append(RAINBOW_MODIFIER)
		
	total = adult_count + child_count
	for m in modifiers:
		total *= m

func _on_chicken_clicked(chicken:Node2D):
		$UI/PeonStatsPanel.stats = chicken.stats
		
func multiplier_to_str(value:float)->String:
	var text := str( -(1.0-value) * 100) + "%"
	if value > 1:
		text = "+" + text
	return text

func add_line_to_report(text:String, multiplier:float):
	final_report.add_text(text + multiplier_to_str(multiplier))
	final_report.newline()
		
func _add_human(count:int, rate:float):
	if count <= 0:
		final_report.clear()
		if fatigue_penalty:
			final_report.add_text("Tired Chickens: " + multiplier_to_str(FATIGUE_MULTIPLIER))
			final_report.newline()
		if many_fatigue_penalty:
			final_report.add_text("Most Chickens Tired: " + multiplier_to_str(MANY_FATIGUE_MULIPLIER))
			final_report.newline()
		if breeds.size() == 1:
			add_line_to_report("All " + breeds[0].capitalize() + " chickens: ", FLUSH_MULTIPLIER)
		elif breeds.size() == 2:
			var line := "All %s and %s: "
			add_line_to_report(
				line % [breeds[0].capitalize(), breeds[1].capitalize()], 
				TWO_PAIR_MULTIPLIER)
		elif breeds.size() == M.BREEDS_LIST.size():
			add_line_to_report("Every breed of chicken: ", ALL_BREEDS_MODIFIER)
		elif breeds.size() >= 0.5 * M.BREEDS_LIST.size():
			add_line_to_report("Differnet kinds of chickens: ", MANY_BREEDS_MODIFIER)
		if colours.size() >= 5:
			add_line_to_report("Rainbow chickens: ", RAINBOW_MODIFIER)

		final_report.add_text("Total Guests: " + str(round(total)))
		for stats in save_game.get_all():
			stats.tire(1)
	
	else:
		var peon:Node2D
		if randf() <= rate:
			peon = Adult.instance()
			report.adult()
		else:
			peon = Child.instance()
			report.child()
		add_child(peon)
		peon.position = Vector2(rand_range(pen.rect_position.x, pen.rect_position.x + pen.rect_size.x), rand_range(pen.rect_position.y, pen.rect_position.y + pen.rect_size.y))
		var err = peon.connect("clicked", $UI/PeonStatsPanel, "_on_Human_clicked")
		if err != OK:
			push_error("Error connecting to peon: " + str(err))
		
		var t := Timer.new()
		err = t.connect("timeout", self, "_add_human", [count-1, rate])
		if err != OK:
			push_error("Error connecting to timer: " + str(err))
		t.one_shot = true
		add_child(t)
		t.start(rand_range(0.7, 1.7) * pen_modifier)



func _on_ToCoop_pressed():
	save_game.money += report.collect_money()
	save_game.save()
	var coop := "res://Coop.tscn"
	var err = get_tree().change_scene(coop)
	match err:
		 OK: return
		 ERR_CANT_OPEN: push_error("ERR_CANT_OPEN " + coop + " path cannot be loaded into a PackedScene")
		 ERR_CANT_CREATE : push_error("ERR_CANT_CREATE " + coop + " cannot be instantiated.")
	push_error("Error " + str(err) + "changing to  " + coop + " ")



func _on_Start_timeout():
	var rate:float = adult_count/(adult_count+child_count)
	_add_human(round(total), rate)
