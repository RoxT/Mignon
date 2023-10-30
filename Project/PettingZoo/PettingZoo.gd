extends Node2D

onready var camera := $Camera2D

var save_game:AllChickens
var pen:ReferenceRect

# Called when the node enters the scene tree for the first time.
func _ready():
	var chicken_stats := []
	if AllChickens.exists():
		save_game = load(AllChickens.PATH) as AllChickens
	else:
		save_game = AllChickens.new()
		save_game.save()
		print("New Game")
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
		
	save_game.save()

func _on_chicken_clicked(chicken:Node2D):
		$UI/StatsPanel.stats = chicken.stats



func _on_ToCoop_pressed():
	var coop := "res://Coop.tscn"
	var err = get_tree().change_scene(coop)
	match err:
		 OK: return
		 ERR_CANT_OPEN: push_error("ERR_CANT_OPEN " + coop + " path cannot be loaded into a PackedScene")
		 ERR_CANT_CREATE : push_error("ERR_CANT_CREATE " + coop + " cannot be instantiated.")
	push_error("Error " + str(err) + "changing to  " + coop + " ")
