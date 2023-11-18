extends Node2D

onready var Lane := preload("res://RaceTrack/Lane.tscn")

const lane_offset_y := 112
const lane_separation_y := 192
const lane_count := 4
const winnings := 50
var track := 0
var has_tired := false
var speed_guess := -1

var save_game:AllChickens

# Called when the node enters the scene tree for the first time.
func _ready():
	if AllChickens.exists():
		save_game = load(AllChickens.PATH)
	else:
		push_error("No save file found")
	var first_chicken:Chicken
	first_chicken = save_game.temp_racer if save_game.temp_racer else save_game.racer
	save_game.last_racer = first_chicken
	first_chicken.boost = save_game.speed_boost
	speed_guess = first_chicken.get_speed()
	save_game.speed_boost = 1.0

	add_lane(first_chicken)
	var competition := save_game.get_competition(lane_count-1)
	for c in competition:
		var r = randi() % 6 + 1
		c.fatigue = r if r <= 3 else 0
		add_lane(c)
	$ToCoop.disabled = first_chicken.is_exhausted()
	
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
	if $Lane.did_win():
		save_game.money += winnings
		$CL/Winnings.text = "YOU WON $" + str(winnings) 
		$CL/Winnings.show()
		$CL/Winnings/Rice.emitting = true
		save_game.wins += 1
	else:
		$CL/Lost.show()
		save_game.losses += 1
	if not has_tired:
		your_chicken.stats.tire(2)
	has_tired = true
	your_chicken.stats.speed_guess = speed_guess
	save_game.save()
	get_tree().call_group("Lane", "update_wins")
	$ToCoop.disabled = false
	$ToCoop.grab_focus()
	
	
func add_lane(stats:Chicken):
	var lane := Lane.instance()
	lane.stats = stats
	add_child(lane)
	lane.position.y = lane_offset_y + lane_separation_y * track
	track += 1

func _on_ToCoop_pressed():
	if not has_tired: $Lane/Racer.stats.tire(2)
	save_game.pass_day()
	var err := get_tree().change_scene("res://Coop.tscn")
	if err != OK:
		push_error("Error switching scenes: " + str(err))


func _on_StartGun_timeout():
	get_tree().call_group("racer", "start")
