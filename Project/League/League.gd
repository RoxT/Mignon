extends Node2D

var ShowChicken:PackedScene = preload("res://Common/ShowChicken.tscn")
onready var rich_text:RichTextLabel = $Panel/Diary

var save_game:AllChickens

# Called when the node enters the scene tree for the first time.
func _ready():
	if AllChickens.exists():
		save_game = load(AllChickens.PATH)
		save_game.save()
	else:
		push_error("No save file found")
	var enemy_farms:Array = save_game.enemy_farms
	rich_text.clear()
	var offset = 0
	for farm in enemy_farms:
		farm = farm as Farm
		var label := Label.new()
		label.text = (farm.nom + "\n")
		label.name = farm.nom
		rich_text.add_child(label)
		label.rect_position.y = offset
		var width = 64
		for stats in farm.chickens:
			var chicken = ShowChicken.instance()
			chicken.stats = stats
			label.add_child(chicken)
			chicken.position = Vector2(width, 32+3)
			width += 128
		offset += 256
			

func _on_ToCoop_pressed():
	var path := "res://Coop.tscn"
	var err = get_tree().change_scene(path)
	match err:
		 OK: return
		 ERR_CANT_OPEN: push_error("ERR_CANT_OPEN " + path + " path cannot be loaded into a PackedScene")
		 ERR_CANT_CREATE : push_error("ERR_CANT_CREATE " + path + " cannot be instantiated.")
	push_error("Error " + str(err) + "changing to  " + path + " ")
