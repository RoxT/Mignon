extends Node2D

var save_game:AllChickens
const COST_RACE := 5
onready var racer_label := $RacerLabel
onready var selected_dot := $SelectedDot
onready var mate_dot := $MateDot
onready var mate_dot2 := $MateDot2
onready var breeding_pos:Vector2 = $PenRect.rect_position + (0.5 * $PenRect.rect_size)
var racer:Node
var mate:Node
var mate2:Node
var pen:ReferenceRect

var selected:Node

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().call_group("drop", "hide")
	var chicken_stats := []
	if AllChickens.exists():
		save_game = load(AllChickens.PATH) as AllChickens
	else:
		save_game = AllChickens.new()
	chicken_stats = save_game.get_all()
	$UI/Money.text = "Money: $" + str(save_game.money)
	save_game.temp_racer = null
	var marked
	if chicken_stats.empty():
		$UI/Race.disabled = true
		if save_game.deaths == 0:
			_on_New_pressed()
			marked = $Chicken
	else:
		for stats in chicken_stats:
			var chicken = preload("res://chicken/CoopChicken.tscn").instance()
			chicken.stats = stats
			add_child(chicken)
			chicken.position = Vector2(rand_range(0, 256), rand_range(0, 256))
			chicken.connect("clicked", self, "_on_chicken_clicked")
			chicken.connect("unclicked", self, "_on_chicken_unclicked")
			if save_game.racer == stats || !marked:
				marked = chicken
		
	set_racer(marked)
	for p in $Pens.get_children():
		p.get_node("Label").connect("pressed", self, "_on_Pen_pressed", [p.name])
	_on_Pen_pressed("Starter")
	
	#$Race.call_deferred("grab_focus")

func _on_chicken_clicked(chicken:Node):
	selected = chicken
	selected_dot.get_parent().remove_child(selected_dot)
	selected.add_child(selected_dot)
	$UI/StatsPanel.stats = selected.stats
	$UI/StatsPanel.set_mate(mate)
	get_tree().call_group("drop", "show")
	set_race_text(chicken.stats)

func _on_chicken_unclicked(chicken:Node):
	var drops:= get_tree().get_nodes_in_group("drop")
	for drop in drops:
		var d:ReferenceRect = drop as ReferenceRect
		if  d.get_global_rect().has_point(get_viewport().get_mouse_position()):
			var place:String = d.get_parent().name
			print("Dropped chicken in " + place)
			if place == "Race": _on_Race_pressed(chicken)
			return
		d.hide()
	set_race_text(save_game.racer)

func _on_Pen_pressed(pen_name:String):
	if pen:
		pen.border_color = Color.red
		pen.modulate = Color("7fffffff")
	pen = get_node("Pens/" + pen_name) as ReferenceRect
	pen.border_color = Color.greenyellow
	pen.modulate = Color.white
	get_tree().set_group("meander", "pen", pen.get_rect())
	

func set_racer(chicken:Node):
	if not chicken: return
	racer_label.get_parent().remove_child(racer_label)
	racer = chicken
	save_game.racer = chicken.stats
	racer.add_child(racer_label)
	set_race_text(chicken.stats)
	
func set_race_text(chicken:Chicken):
	$UI/Race.text = "RACE ($" + str(COST_RACE) + ") " + chicken.nom

func _on_Reset_pressed():
	selected_dot.get_parent().remove_child(selected_dot)
	add_child(selected_dot)
	selected = null
	mate_dot.get_parent().remove_child(mate_dot)
	add_child(mate_dot)
	mate = null
	racer_label.get_parent().remove_child(racer_label)
	add_child(racer_label)
	racer = null
	
	get_tree().call_group("meander", "queue_free")
	save_game = AllChickens.new()
	save_game.save()
	_on_New_pressed()
	$UI/Money.text = "Money: $" + str(save_game.money)

func _on_New_pressed(stats:= Chicken.new(), new_pos:=pen.get_node("Position2D").position):
	var new_chicken = preload("res://chicken/CoopChicken.tscn").instance()
	stats.farm = "YOU"
	
	new_chicken.stats = stats
	save_game.add_chicken_stats(stats)
	add_child(new_chicken)
	new_chicken.connect("clicked", self, "_on_chicken_clicked")
	new_chicken.connect("unclicked", self, "_on_chicken_unclicked")
	new_chicken.pen = pen.get_rect()
	new_chicken.position = new_pos
	if not racer: 
		set_racer(new_chicken)
	$UI/Race.disabled = false

func _on_Race_pressed(chicken=null):
	save_game.money -= COST_RACE
	save_game.temp_racer = chicken.stats
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
		mate.position = breeding_pos
		mate.breeding = true
		mate.wait()
	elif mate == selected:
		mate.breeding = false
		remove_dot(mate_dot)
		mate = null
	elif not mate2:
		mate_dot2.get_parent().remove_child(mate_dot2)
		mate2 = selected
		mate2.add_child(mate_dot2)
		mate2.position = breeding_pos
		mate2.breeding = true
		mate2.wait()
	elif mate2 == selected:
		mate2.breeding = false
		remove_dot(mate_dot2)
		mate2 = null
	if mate and mate2:
		$PenRect/Mating.start(rand_range(3, 4))

func remove_dot(dot:Node):
	dot.get_parent().remove_child(dot)
	add_child(dot)

func _on_Mating_timeout():
	var egg:AnimatedSprite = load("res://Coop/Egg.tscn").instance()
	var birthing:Timer = Timer.new()
	add_child(egg)
	egg.add_child(birthing)
	if randi() % 2 == 0:
		egg.position = mate.position
	else:
		egg.position = mate2.position
	var err := birthing.connect("timeout", self, "_on_Birthing_timeout", [egg])
	if err != OK: push_error("err connecting " + str(err))
	birthing.start(rand_range(3, 4))
	


func _on_Birthing_timeout(egg:AnimatedSprite):
	var baby:Chicken = AllChickens.do_mating(mate2.stats, mate.stats)
	baby.age = 0
	
	_on_New_pressed(baby, egg.position)
	mate.stats.fatigue += 1
	mate.breeding = false
	mate.wait()
	mate2.stats.fatigue += 1
	mate2.breeding = false
	mate2.wait()
	remove_dot(mate_dot)
	remove_dot(mate_dot2)
	mate = null
	mate2 = null
	$UI/StatsPanel.set_mate(null)	
	egg.queue_free()
