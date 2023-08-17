extends Node2D

var save_game:AllChickens
const COST_RACE := 5
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
	var marked
	for stats in chicken_stats:
		var chicken = preload("res://chicken/CoopChicken.tscn").instance()
		chicken.stats = stats
		add_child(chicken)
		chicken.position = Vector2(rand_range(0, 256), rand_range(0, 256))
		chicken.connect("clicked", self, "_on_chicken_clicked")
		if save_game.racer == stats || !marked:
			marked = chicken
	set_racer(marked)
	$Money.text = "Money: $" + str(save_game.money)
	$Race.text = "RACE ($" + str(COST_RACE) + ")"
	#$Race.call_deferred("grab_focus")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_chicken_clicked(chicken:Node):
	set_racer(chicken)
	

func set_racer(chicken:Node):
	if racer:
		racer.remove_child(dot)
	else:
		remove_child(dot)
	racer = chicken
	save_game.racer = chicken.stats
	racer.add_child(dot)
	

func _on_Reset_pressed():
	get_tree().call_group("meander", "queue_free")
	save_game = AllChickens.new()
	save_game.save()
	_on_New_pressed()
	$Money.text = "Money: $" + str(save_game.money)

func _on_New_pressed():
	var new_chicken = preload("res://chicken/CoopChicken.tscn").instance()
	var stats := Chicken.new()
	stats.farm = "YOU"
	
	new_chicken.stats = stats
	save_game.add_chicken_stats(stats)
	add_child(new_chicken)
	

func _on_Race_pressed():
	save_game.money -= COST_RACE
	save_game.save()
	var err := get_tree().change_scene("res://RaceTrack/RaceTrack.tscn")
	if err != OK:
		push_error("Error switching scenes: " + str(err))
		assert(false)
