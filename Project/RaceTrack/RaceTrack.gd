extends Node2D

const lane_offset_y := 32
var save_game:AllChickens


# Called when the node enters the scene tree for the first time.
func _ready():
	var track:=1
#	var racers := get_tree().get_nodes_in_group("racer")
	if AllChickens.exists():
		save_game = load(AllChickens.PATH)
	else:
		save_game = AllChickens.new()
#	var racer_lane = preload("res://RaceTrack/Lane.tscn").instance()
	if save_game.racer:
		$Lane1.chicken = save_game.racer
	else:
		print("No racer found, using first in list")
		$Lane1.chicken = save_game.get_all()[0]
		save_game.racer = $Lane1.chicken
	
	for r in get_tree().get_nodes_in_group("racer"):
		var err = r.connect("finished", self, "_on_racer_finished")
		if err != OK: push_error("Error connect finished signal: " + str(err))
	
func _on_racer_finished(index:int):
	get_tree().call_group("racer", "stop")
	if index >= 0:
		save_game.winner(index)
	

func _on_ToCoop_pressed():
	var err := get_tree().change_scene("res://Coop.tscn")
	if err != OK:
		push_error("Error switching scenes: " + str(err))
		assert(false)


func _on_StartGun_timeout():
	get_tree().call_group("racer", "start")
