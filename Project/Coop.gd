extends Node2D

var save_game:AllChickens
const COST_RACE := 5
onready var racer_dot := $RacerDot
onready var selected_dot := $SelectedDot
onready var mate_dot := $MateDot
var racer:Node
var mate:Node

var selected:Node

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
	selected = chicken
	selected_dot.get_parent().remove_child(selected_dot)
	selected.add_child(selected_dot)
	$StatsPanel.stats = selected.stats
	$StatsPanel.set_mate(mate)
	

func set_racer(chicken:Node):
	racer_dot.get_parent().remove_child(racer_dot)
	racer = chicken
	save_game.racer = chicken.stats
	racer.add_child(racer_dot)
	
func _on_Reset_pressed():
	selected_dot.get_parent().remove_child(selected_dot)
	add_child(selected_dot)
	mate_dot.get_parent().remove_child(mate_dot)
	add_child(mate_dot)
	mate = null
	racer_dot.get_parent().remove_child(racer_dot)
	add_child(racer_dot)
	racer = null
	
	get_tree().call_group("meander", "queue_free")
	save_game = AllChickens.new()
	save_game.save()
	_on_New_pressed()
	$Money.text = "Money: $" + str(save_game.money)

func _on_New_pressed(stats:= Chicken.new()):
	var new_chicken = preload("res://chicken/CoopChicken.tscn").instance()
	stats.farm = "YOU"
	
	new_chicken.stats = stats
	save_game.add_chicken_stats(stats)
	add_child(new_chicken)
	new_chicken.connect("clicked", self, "_on_chicken_clicked")
	

func _on_Race_pressed():
	save_game.money -= COST_RACE
	save_game.save()
	var err := get_tree().change_scene("res://RaceTrack/RaceTrack.tscn")
	if err != OK:
		push_error("Error switching scenes: " + str(err))
		assert(false)

func _on_StatsPanel_chose_racer():
	set_racer(selected)

func _on_StatsPanel_requested_breed():
	if not mate:
		mate_dot.get_parent().remove_child(mate_dot)
		mate = selected
		mate.add_child(mate_dot)
	elif mate == selected:
		mate_dot.get_parent().remove_child(mate_dot)
		mate = null
		add_child(mate_dot)
	else:
		var baby:Chicken = AllChickens.do_mating(selected.stats, mate.stats)
		var d:RichTextLabel = $Debug
		d.clear()
		d.add_text("DEBUG")
		d.newline()
		d.add_text(str(selected.stats))
		d.newline()
		d.add_text(str(mate.stats))
		d.newline()
		d.add_text("--> BABY: " + str(baby))
		
		_on_New_pressed(baby)
