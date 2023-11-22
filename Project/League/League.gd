extends Node2D

var ShowChicken:PackedScene = preload("res://Common/ShowChicken.tscn")
onready var panel := $Panel
onready var rich_text:RichTextLabel = $Panel/Diary

var leagues := {
	"BRONZE" : ["St. Germain’s", "Anualonacu", "QkChkns"],
	"SILVER" : ["Bec-de-Beak", "Jam Jar Farms", "QkChkns", "Anualonacu"],
	"GOLD" : ["Vanchokons", "Martot", "Jam Jar Farms", "Bec-de-Beak"]
}

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


func _on_Go_pressed():
	remove_child(panel)
	var stadium:Node2D = load("res://League/Stadium.tscn").instance()
	var lanes := stadium.get_children()
	var farm_names:Array = leagues[save_game.current_league]
	for i in range(farm_names.size()):
		var farm:Farm = save_game.get_some_farms(farm_names)[i]
		lanes[i].stats = farm.get_random()
	add_child(stadium)
	for r in get_tree().get_nodes_in_group("racer"):
		var err = r.connect("finished", self, "_on_racer_finished")
		if err != OK: push_error("Error connect finished signal: " + str(err))
	
func _on_racer_finished():
	get_tree().call_group("racer", "stop")
	var your_chicken := get_node("Lane/Racer")
	if your_chicken.stats.is_exhausted():
		your_chicken.play("death")
		var modal = load("res://RaceTrack/ModalDeath.tscn").instance()
		modal.nom = your_chicken.stats.nom
		modal.epitaph = your_chicken.stats.get_bracket()
		modal.reason = "Death"
		save_game.death(your_chicken.stats)
		add_child(modal)
