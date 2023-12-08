extends Node2D

onready var Adult:PackedScene= preload("res://PettingZoo/PeonAdult.tscn")
onready var Child:PackedScene= preload("res://PettingZoo/PeonChild.tscn")
onready var camera := $Camera2D
onready var report = $UI/ReportPanel
onready var final_report:RichTextLabel = $UI/ReportPanel/FinalReport

var save_game:AllChickens
var pen:ReferenceRect
var fatigue_penalty := false
var many_fatigue_penalty := false
const FATIGUE_MULTIPLIER := 0.80
const MANY_FATIGUE_MULIPLIER := 0.40
const FLUSH_MULTIPLIER := 1.65
const TWO_PAIR_MULTIPLIER := 1.60
const RAINBOW_MODIFIER := 1.10
const MANY_BREEDS_MODIFIER := 1.15
const ALL_BREEDS_MODIFIER := 1.22
const FAMOUS_MULTIPLIER := 1.05
var uncommon_chickens := 0
var uncommon_breeds:Array = M.get_uncommon_list().duplicate()
var modifiers := []
var total:float
var pen_modifier := 1.0
var breeds := []
var colours:= []
var regulars := 0
var fans := 0
var rate_adults := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var chicken_stats := []
	save_game = M.save_game
	chicken_stats = save_game.get_all()
	
	pen = load("res://Coop/Pens/" + save_game.pen + ".tscn").instance()
	$Pens.add_child(pen)
	pen.border_color = Color.greenyellow
	pen.modulate = Color.white
	camera.zoom = pen.get_zoom()
	match pen.name:
		"Large": pen_modifier = 0.25
		"Medium": pen_modifier = 0.5
	
	if save_game.already_zooed():
		print_report(true)
		$UI/PeonStatsPanel.hide()
		return

	var tired := 0
	var add_child := 0
	var add_adult := 0
	for stats in chicken_stats:
		stats = stats as Chicken
		var chicken = preload("res://PettingZoo/PettingChicken.tscn").instance()
		chicken.stats = stats
		add_child(chicken)
		var rect := pen.get_rect()
		chicken.pen = rect
		chicken.position = Vector2(rand_range(rect.position.x, rect.position.x + rect.size.x), rand_range(rect.position.y, rect.position.y + rect.size.y))
		if not stats.breed in breeds: 
			breeds.append(stats.breed)
		if not stats.colour in colours: 
			colours.append(stats.colour)
		if stats.wins >= 10:
			modifiers.append(FAMOUS_MULTIPLIER)
		
		if stats.top_speed >= 280:
			add_adult += 1
		else:
			add_child += 1
	
		if stats.fatigue >= 3:
			tired += 1
			
		if stats.is_mature():
			regulars += 1
		if stats.is_elderly():
			regulars += 2
	

	if tired/(float(chicken_stats.size())) >= 0.5:
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
		
	if colours.size() >= 5:
		modifiers.append(RAINBOW_MODIFIER)
	
	rate_adults = float(add_adult)/float(add_adult+add_child)
	total = add_child + add_adult + regulars
	for m in modifiers:
		total *= m
	
	$UI/ToCoop.disabled = true
	$Start.start()
		
func modifier_to_str(value:float)->String:
	var text := str( -(1.0-value) * 100) + "%"
	if value > 1:
		text = "+" + text
	return text

func add_line_to_report(text:String, multiplier:float):
	final_report.add_text(text + modifier_to_str(multiplier))
	final_report.newline()
	
		
func _add_human(count:int, rate:float):
	if count <= 0:
		$UI/ToCoop.disabled = false
		print_report()
		
		save_game.create_zoo_report(report.adults, report.children, modifiers, breeds, regulars)
		save_game.money += report.collect_money()
		for stats in save_game.get_all():
			stats.tire(1)
		save_game.save()
	
	else:
		var peon:Node2D
		if randf() <= rate:
			peon = Adult.instance()
			report.adult()
		else:
			peon = Child.instance()
			report.child()
		add_child(peon)
		peon.position = Vector2(
			rand_range(pen.rect_position.x, pen.rect_position.x + pen.rect_size.x), rand_range(pen.rect_position.y, pen.rect_position.y + pen.rect_size.y))
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

func print_report(done_already:=false):
	final_report.clear()
	if done_already:
		var last_report = save_game.last_zoo_report
		modifiers = last_report["modifiers"]
		report.children = last_report["children"]
		report.adults = last_report["adults"]
		breeds = last_report["breeds"]
		regulars = last_report["regulars"]
		total = report.children + report.adults
	var fame := 0.0
	for mod in modifiers:
		match(mod):
			FATIGUE_MULTIPLIER:
				add_line_to_report("Tired Chickens: ", FATIGUE_MULTIPLIER)
			MANY_FATIGUE_MULIPLIER:
				add_line_to_report("Most Chickens Tired: ", MANY_FATIGUE_MULIPLIER)
			FLUSH_MULTIPLIER:
				add_line_to_report("All " + breeds[0].capitalize() + " chickens: ", FLUSH_MULTIPLIER)
			TWO_PAIR_MULTIPLIER:
				var line := "All %s and %s: "
				add_line_to_report(
					line % [breeds[0].capitalize(), breeds[1].capitalize()], 
				TWO_PAIR_MULTIPLIER)
			ALL_BREEDS_MODIFIER:
				add_line_to_report("Every breed of chicken: ", ALL_BREEDS_MODIFIER)
			MANY_BREEDS_MODIFIER:
				add_line_to_report("Differnet kinds of chickens: ", MANY_BREEDS_MODIFIER)
			RAINBOW_MODIFIER:
				add_line_to_report("Rainbow chickens: ", RAINBOW_MODIFIER)
			FAMOUS_MULTIPLIER:
				fame += (FAMOUS_MULTIPLIER-1)
	if fame > 0.0:
		add_line_to_report("Famous chickens: ", 1 + fame)
	if regulars > 0:
		final_report.add_text("Regulars: " + str(regulars))
		final_report.newline()
	
	if done_already:
		report.show_all()
	final_report.newline()
	final_report.add_text("Total Guests: " + str(round(total)))

func _on_ToCoop_pressed():
	save_game.save()
	var coop := "res://Coop.tscn"
	var err = get_tree().change_scene(coop)
	match err:
		 OK: return
		 ERR_CANT_OPEN: push_error("ERR_CANT_OPEN " + coop + " path cannot be loaded into a PackedScene")
		 ERR_CANT_CREATE : push_error("ERR_CANT_CREATE " + coop + " cannot be instantiated.")
	push_error("Error " + str(err) + "changing to  " + coop + " ")

func _on_Start_timeout():
	_add_human(int(round(total)), rate_adults)
