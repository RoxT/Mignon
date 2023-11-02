extends Node2D

onready var camera := $Camera2D
onready var admissions := $UI/Admissions
onready var Adult:PackedScene= preload("res://PettingZoo/PeonAdult.tscn")
onready var Child:PackedScene= preload("res://PettingZoo/PeonChild.tscn")

var save_game:AllChickens
var pen:ReferenceRect
var child_count := 0.0
var adult_count := 0.0

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
	

		
	save_game.save()

func _on_chicken_clicked(chicken:Node2D):
		$UI/StatsPanel.stats = chicken.stats
		
func _add_human(total:int, rate:float):
	if total > 0:
		var peon:Node2D
		if randf() <= rate:
			peon = Adult.instance()
		else:
			peon = Child.instance()
		add_child(peon)
		peon.position = Vector2(rand_range(pen.rect_position.x, pen.rect_position.x + pen.rect_size.x), rand_range(pen.rect_position.y, pen.rect_position.y + pen.rect_size.y))
		peon.connect("clicked", $UI/StatsPanel, "_on_Human_clicked")
		admissions.text = str(int(admissions.text) + 1)
		
		var t := Timer.new()
		t.connect("timeout", self, "_add_human", [total-1, rate])
		t.one_shot = true
		add_child(t)
		t.start(rand_range(0.8, 1.2))
		

func _on_ToCoop_pressed():
	var coop := "res://Coop.tscn"
	var err = get_tree().change_scene(coop)
	match err:
		 OK: return
		 ERR_CANT_OPEN: push_error("ERR_CANT_OPEN " + coop + " path cannot be loaded into a PackedScene")
		 ERR_CANT_CREATE : push_error("ERR_CANT_CREATE " + coop + " cannot be instantiated.")
	push_error("Error " + str(err) + "changing to  " + coop + " ")


func _on_Start_timeout():
	var rate:float = adult_count/(adult_count+child_count)
	_add_human(adult_count + child_count, rate)
