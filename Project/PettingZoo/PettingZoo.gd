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
const FATIGUE_MULTIPLIER := 0.85
var modifiers := []
var total:float

# Called when the node enters the scene tree for the first time.
func _ready():
	var chicken_stats := []
	save_game = load(AllChickens.PATH) as AllChickens
	save_game.save()
	chicken_stats = save_game.get_all()
	
	var pen_name = save_game.pen
	pen = get_node("Pens/" + pen_name) as ReferenceRect
	$TextureRect.texture = load("res://Coop/Grass%s.jpg" % pen_name)
	$TextureRect.rect_position = pen.rect_position
		
	match pen_name:
		"Starter": camera.zoom = Vector2(0.7, 0.7)
		"Medium": camera.zoom = Vector2(0.8, 0.8)
		"Large": camera.zoom = Vector2(1.0, 1.0)
	
	var tired := 0
	for stats in chicken_stats:
		var chicken = preload("res://PettingZoo/PettingChicken.tscn").instance()
		chicken.stats = stats
		add_child(chicken)
		chicken.connect("clicked", self, "_on_chicken_clicked")
		var rect := pen.get_rect()
		chicken.pen = rect
		chicken.position = Vector2(rand_range(rect.position.x, rect.position.x + rect.size.x), rand_range(rect.position.y, rect.position.y + rect.size.y))
		if stats.top_speed >= 280:
			adult_count += 1
		else:
			child_count += 1
		if stats.fatigue >= 3:
			tired += 1
	

	if tired >= 2:
		fatigue_penalty = true
		modifiers.append(FATIGUE_MULTIPLIER)
	save_game.save()

func _on_chicken_clicked(chicken:Node2D):
		$UI/StatsPanel.stats = chicken.stats
		
func _add_human(count:int, rate:float):
	if count <= 0:
		final_report.clear()
		if fatigue_penalty:
			final_report.add_text("Tired Chickens: -" + str(1.0-FATIGUE_MULTIPLIER) + "%")
			final_report.newline()
		final_report.add_text("Total Guests: " + str(round(total)))
	if count > 0:
		var peon:Node2D
		if randf() <= rate:
			peon = Adult.instance()
			report.adult()
		else:
			peon = Child.instance()
			report.child()
		add_child(peon)
		peon.position = Vector2(rand_range(pen.rect_position.x, pen.rect_position.x + pen.rect_size.x), rand_range(pen.rect_position.y, pen.rect_position.y + pen.rect_size.y))
		var err = peon.connect("clicked", $UI/StatsPanel, "_on_Human_clicked")
		if err != OK:
			push_error("Error connecting to peon: " + str(err))
		
		var t := Timer.new()
		err = t.connect("timeout", self, "_add_human", [count-1, rate])
		if err != OK:
			push_error("Error connecting to timer: " + str(err))
		t.one_shot = true
		add_child(t)
		t.start(rand_range(0.8, 1.2))
		

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
	var total = adult_count + child_count
	for m in modifiers:
		total *= m
	_add_human(round(total), rate)
