extends Node2D

var save_game:AllChickens
onready var dot := $Dot
var racer:Node

# Called when the node enters the scene tree for the first time.
func _ready():
	var chicken_stats := []
	if AllChickens.exists():
		save_game = load(AllChickens.PATH) as AllChickens
	else:
		save_game = AllChickens.new()
	chicken_stats = save_game.get_all()
	if chicken_stats.empty():
		_on_New_pressed()
	get_tree().call_group("meander", "queue_free")
	for stats in chicken_stats:
		var chicken = preload("res://chicken/CoopChicken.tscn").instance()
		add_child(chicken)
		chicken.stats = stats
		if save_game.racer == stats || !racer:
			remove_child(dot)
			set_racer(chicken)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_racer(chicken:Node):
	racer = chicken
	racer.add_child(dot)
	

func _on_Reset_pressed():
	get_tree().call_group("meander", "queue_free")
	save_game.reset()
	_on_New_pressed()


func _on_New_pressed():
	var new_chicken = preload("res://chicken/CoopChicken.tscn").instance()
	var stats := Chicken.new()
	stats.farm = "YOU"
	
	new_chicken.stats = stats
	save_game.add_chicken_stats(stats)
	add_child(new_chicken)
	


func _on_Race_pressed():
	var err := get_tree().change_scene("res://RaceTrack/RaceTrack.tscn")
	if err != OK:
		push_error("Error switching scenes: " + str(err))
		assert(false)
