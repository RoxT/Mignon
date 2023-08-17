extends Node2D

onready var Lane := preload("res://RaceTrack/Lane.tscn")

const lane_offset_y := 32
const lane_separation_y := 155
const winnings := 50
var track := 0

var save_game:AllChickens

# Called when the node enters the scene tree for the first time.
func _ready():
	if AllChickens.exists():
		save_game = load(AllChickens.PATH)
	else:
		save_game = AllChickens.new()
	
	var first_chicken:Chicken
	if save_game.racer:
		first_chicken = save_game.racer
	else:
		first_chicken = save_game.get_by_index(0)
	add_lane(first_chicken)
	add_lane(Chicken.new())
	add_lane(Chicken.new())
	add_lane(Chicken.new())
	
	for r in get_tree().get_nodes_in_group("racer"):
		var err = r.connect("finished", self, "_on_racer_finished")
		if err != OK: push_error("Error connect finished signal: " + str(err))
	
func _on_racer_finished():
	get_tree().call_group("racer", "stop")
	var your_chicken := get_node("Lane/Racer")
	your_chicken.stats.fatigue += 2
	if $Lane.did_win():
		save_game.money += winnings
		$Winnings.text = "YOU WON $" + str(winnings) 
		$Winnings.show()
		$Winnings/Rice.emitting = true
	else:
		$Lost.show()
	$ToCoop.grab_focus()
	save_game.pass_day()
	
func add_lane(stats:Chicken):
	var lane := Lane.instance()
	lane.stats = stats
	add_child(lane)
	lane.position.y = lane_offset_y + lane_separation_y * track
	track += 1

func _on_ToCoop_pressed():
	var err := get_tree().change_scene("res://Coop.tscn")
	if err != OK:
		push_error("Error switching scenes: " + str(err))
		assert(false)


func _on_StartGun_timeout():
	get_tree().call_group("racer", "start")
