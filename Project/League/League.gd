extends Node2D

var ShowChicken:PackedScene = preload("res://Common/ShowChicken.tscn")
onready var panel := $Panel
onready var rich_text:RichTextLabel = $Panel/Diary
onready var go_button := $Panel/Go
onready var prizes := $Panel/Prizes
onready var welcome := $Panel/Welcome
var stadium:Node
var control:Control
var league_name:String
var your_racer:Chicken

const WELCOME := "Welcome to %s League"
const PRIZE := "Prize per race: $%s               Prize for league: %s"
const GO_BUTTON := "Round %s, Go!"

var leagues := {
	"BRONZE" : {"farms":["St. Germain's", "Anualonacu", "QkChkns"],
				"prize_race": 20, "prize_all":200},
	"SILVER" : {"farms":["Bec-de-Beak", "Jam Jar Farms", "QkChkns",],
				"prize_race": 20, "prize_all":400},
	"GOLD" : {"farms":["Vanchokons", "Martot", "Bec-de-Beak"],
			  "prize_race": 20, "prize_all":600}
}

var save_game:AllChickens
var enemy_farms:Array

# Called when the node enters the scene tree for the first time.
func _ready():
	save_game = M.save_game
	your_racer = save_game.temp_racer if save_game.temp_racer else save_game.racer
	$Panel/ShowChicken.stats = your_racer
	var in_progress = save_game.league_in_progress
	if in_progress:
		$Panel/Bronze.disabled = in_progress.league != "BRONZE"
		$Panel/Silver.disabled = in_progress.league != "SILVER"
		$Panel/Gold.disabled = in_progress.league != "GOLD"
		load_league(in_progress.league)
	else:
		load_league(save_game.current_league)

func _on_League_toggled(button_pressed:bool, new_league_name:String):
	if button_pressed:
		call_deferred("load_league", new_league_name)
			
func load_league(title:String):
	league_name = title
	var league:Dictionary = leagues[title]
	welcome.text = WELCOME % title
	prizes.text = PRIZE % [str(league.prize_race), str(league.prize_all)]
	enemy_farms = save_game.get_some_farms(
		league.farms, save_game.enemy_farms)
	rich_text.clear()
	if control: control.queue_free()
	control = Control.new()
	$Panel/Diary.add_child(control)
	
	var offset = 0
	for farm in enemy_farms:
		farm = farm as Farm
		var label := Label.new()
		label.text = (farm.nom + "\n")
		label.name = farm.nom
		control.add_child(label)
		label.rect_position.y = offset
		var width = 64
		for stats in farm.chickens:
			var chicken = ShowChicken.instance()
			chicken.stats = stats
			label.add_child(chicken)
			chicken.position = Vector2(width, 32+3)
			width += 128
		offset += 256
	go_button.text = "Round " + str(save_game.current_round()) + ", Go!"	

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
	stadium = load("res://League/Stadium.tscn").instance()
	stadium.position = Vector2(0, 192)
	var lanes := stadium.get_children()
	lanes[0].stats = your_racer
	for i in range(enemy_farms.size()):
		var farm:Farm = enemy_farms[i]
		lanes[i+1].stats = farm.get_random()
	add_child(stadium)
	for r in get_tree().get_nodes_in_group("racer"):
		var err = r.connect("finished", self, "_on_racer_finished")
		if err != OK: push_error("Error connect finished signal: " + str(err))
	
func _on_racer_finished():
	get_tree().call_group("racer", "stop")
	var your_chicken := stadium.get_node("Lane/Racer")
	if your_chicken.stats.is_exhausted():
		your_chicken.play("death")
		var modal = load("res://RaceTrack/ModalDeath.tscn").instance()
		modal.nom = your_chicken.stats.nom
		modal.epitaph = your_chicken.stats.get_bracket()
		modal.reason = "Death"
		save_game.death(your_chicken.stats)
		add_child(modal)
	if stadium.get_node("Lane").did_win():
		save_game.update_league_in_progress(your_chicken.stats.nom, league_name)
	else:
		save_game.league_in_progress = {}
	save_game.save()


