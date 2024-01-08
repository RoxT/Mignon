extends Node2D

onready var Lane := preload("res://RaceTrack/Lane.tscn")
onready var audioStreamPlayer := $AudioStreamPlayer

const lane_offset_y := 150
const lane_separation_y := 192
const lane_count := 4
const winnings := 50
var track := 0
var has_tired := false
var speed_guess := -1

signal began_race
signal race_finished(you_won)

var save_game:AllChickens

# Called when the node enters the scene tree for the first time.
func _ready():
	M.fade = true
	save_game = M.save_game
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
	
	var err
	for r in get_tree().get_nodes_in_group("racer"):
		err = r.connect("finished", self, "_on_racer_finished")
		if err != OK: push_error("Error connect finished signal: " + str(err))
	
	err = connect("began_race", Music, "began_race")
	if err != OK: push_error("Error connect began_race signal: " + str(err))
	err = connect("race_finished", Music, "race_finished")
	if err != OK: push_error("Error connect race_finished signal: " + str(err))
	emit_signal("began_race")
	
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
		audioStreamPlayer.stream = Music.get_success()
		save_game.money += winnings
		$CL/Winnings.text = "YOU WON $" + str(winnings) 
		$CL/Winnings.show()
		$CL/Winnings/Rice.emitting = true
		save_game.wins += 1
		for loser in get_tree().get_nodes_in_group("racer"):
			if !save_game.has_beat_vanchockens and loser.stats.farm == "Vanchokons":
				save_game.has_beat_vanchockens = true
				save_game.new_alert_event(Event.new(save_game.day, "BEAT_VANCHOKENS", [your_chicken.stats.nom]))
				your_chicken.stats.fame += 1
			save_game.add_to_leagues_ongoing(loser.stats, your_chicken.stats)
			
	else:
		audioStreamPlayer.stream = Music.get_failure()
		$CL/Lost.show()
		save_game.losses += 1
	audioStreamPlayer.play()
	if not has_tired:
		your_chicken.stats.tire(2)
	has_tired = true
	your_chicken.stats.speed_guess = speed_guess
	save_game.save()
	get_tree().call_group("Lane", "update_wins")
	$ToCoop.text = "<-- To Coop"
	$ToCoop.disabled = false
	$ToCoop.grab_focus()
	
func add_lane(stats:Chicken):
	var lane := Lane.instance()
	lane.stats = stats
	add_child(lane)
	lane.position.y = lane_offset_y + lane_separation_y * track
	track += 1

func _on_ToCoop_pressed():
	$ToCoop.disabled = true
	save_game.save_backup()
	emit_signal("race_finished")
	disconnect("began_race", Music, "began_race")
	disconnect("race_finished", Music, "race_finished")
	if not has_tired: $Lane/Racer.stats.tire(2)
	save_game.pass_day()
	$AnimationPlayer.play("fade_out")

func go_to_coop():
	var err := get_tree().change_scene("res://Coop.tscn")
	if err != OK:
		push_error("Error switching scenes: " + str(err))

func _on_StartGun_timeout():
	get_tree().call_group("racer", "start")
