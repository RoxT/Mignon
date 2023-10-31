extends Node2D

var save_game:AllChickens
const COST_RACE := 5
const COST_NEW := 10
onready var racer_label := $RacerLabel
onready var selected_dot := $SelectedDot
onready var mate_dot := $MateDot
onready var mate_dot2 := $MateDot2
onready var mating_pen := $BreedingPen/PenRect
onready var mating:Timer = $BreedingPen/PenRect/Mating
onready var birthing:Timer = mating_pen.get_node("Birthing")
onready var food_box := $UI/Food/Panel/FoodBox
onready var camera := $Camera2D
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
		save_game.save()
		print("New Game")
	chicken_stats = save_game.get_all()
	
	pen = get_node("Pens/" + save_game.pen) as ReferenceRect
	pen.border_color = Color.greenyellow
	pen.modulate = Color.white
	$TextureRect.texture = load("res://Coop/Grass%s.jpg" % save_game.pen)
	$TextureRect.rect_position = pen.rect_position
	
	match save_game.pen:
		"Starter": camera.zoom = Vector2(0.7, 0.7)
		"Medium": camera.zoom = Vector2(0.8, 0.8)
		"Large": camera.zoom = Vector2(1.0, 1.0)
	
	save_game.temp_racer = null
	var marked
	for stats in chicken_stats:
		var chicken = preload("res://chicken/CoopChicken.tscn").instance()
		chicken.stats = stats
		add_child(chicken)
		var bottom = pen.get_end().y + 16*camera.zoom.y
		chicken.position = Vector2(943, bottom)
		chicken.connect("clicked", self, "_on_chicken_clicked")
		chicken.connect("unclicked", self, "_on_chicken_unclicked")
		if save_game.racer == stats || !marked:
			marked = chicken
		chicken.pen = Rect2(pen.rect_position, pen.rect_size)
		chicken.zoom = camera.zoom.x
		
	set_racer(marked)
	update_money()
	update_food_box()
	
	#$Race.call_deferred("grab_focus")

func _on_chicken_clicked(chicken:Node):
	selected = chicken
	selected_dot.get_parent().remove_child(selected_dot)
	selected.add_child(selected_dot)
	$UI/StatsPanel.stats = selected.stats
	$UI/StatsPanel.set_mate(mate, mate2, birthing.time_left > 0)
	if get_adult_chicken(chicken) == null:
		$UI/StatsPanel.stop_sell(true)
	if not chicken.stats.is_chick():
		get_tree().call_group("drop", "show")
		set_race_text(chicken)
		if chicken.breeding == true:
			_on_StatsPanel_requested_breed(chicken)

func _on_chicken_unclicked(chicken:Node):
	var drops:= get_tree().get_nodes_in_group("drop")
	for drop in drops:
		var d:ReferenceRect = drop as ReferenceRect
		if  d.get_global_rect().has_point(get_viewport().get_mouse_position()):
			var place:String = d.get_parent().name
			print("Dropped chicken in " + place)
			if place == "Race": _on_Race_pressed(chicken)
			elif place == "PenRect": _on_StatsPanel_requested_breed(chicken)
			break
	get_tree().call_group("drop", "hide")
	set_race_text(racer)

func set_racer(chicken:Node):
	if not valid_adult_chicken(chicken):
		chicken = get_adult_chicken()
		if chicken == null:
			remove_dot(racer_label)
			racer = null
			set_can_race()
			return
	racer = chicken
	save_game.racer = chicken.stats
	racer_label.get_parent().remove_child(racer_label)
	racer.add_child(racer_label)
	set_race_text(chicken)

func get_adult_chicken(exclude=null):
	var chickens:Array = get_tree().get_nodes_in_group("meander")
	for c in chickens:
		if valid_adult_chicken(c) and c != exclude:
			return c
	return null

func valid_adult_chicken(c:Node)->bool:
	return c != null and is_instance_valid(c) and not c.is_queued_for_deletion() and !c.stats.is_chick() 

func set_race_text(chicken):
	set_can_race()
	var nom:String = chicken.stats.nom
	$UI/Race.text = "RACE ($" + str(COST_RACE) + ") " + nom
	
func set_can_race():
	if racer == null or save_game.all.empty() or $BreedingPen/PenRect/Birthing.time_left > 0:
		$UI/Race.disabled = true
	else:
		$UI/Race.disabled = false

func update_money():
	$UI/Money.text = "Money: $" + str(save_game.money)

func update_food_box():
	food_box.get_node("BEST").count = save_game.foods[AllChickens.FOOD_TYPES.BEST]
	food_box.get_node("GOOD").count = save_game.foods[AllChickens.FOOD_TYPES.GOOD]
	food_box.get_node("BASIC").count = save_game.foods[AllChickens.FOOD_TYPES.BASIC]
	
func _on_Reset_pressed():
	save_game = AllChickens.new()
	save_game.save()
	var err := get_tree().change_scene("res://Coop.tscn")
	if err != OK:
		print("Error reseting game (loading coop)")

func _on_New_pressed(stats:= Chicken.new(), new_pos:=Vector2(100, 100)):
	var new_chicken = preload("res://chicken/CoopChicken.tscn").instance()
	stats.farm = "YOU"
	new_chicken.stats = stats
	save_game.money -= COST_NEW
	save_game.add_chicken_stats(stats)
	update_money()
	add_child(new_chicken)
	new_chicken.connect("clicked", self, "_on_chicken_clicked")
	new_chicken.connect("unclicked", self, "_on_chicken_unclicked")
	new_chicken.pen = pen.get_rect()
	new_chicken.position = new_pos
	if not racer: 
		set_racer(new_chicken)
	set_can_race()
	$UI/StatsPanel.stop_sell(get_adult_chicken(new_chicken) == null)

func _on_Race_pressed(chicken=null):
	save_game.money -= COST_RACE
	if chicken:
		save_game.temp_racer = chicken.stats
	save_game.save()
	var err := get_tree().change_scene("res://RaceTrack/RaceTrack.tscn")
	if err != OK:
		push_error("Error switching scenes: " + str(err))
		assert(false)

func _on_StatsPanel_chose_racer():
	set_racer(selected)

func _on_StatsPanel_requested_breed(chicken:Node=null):
	if birthing.time_left > 0: return
	if not chicken:
		chicken = selected
	if chicken.stats.is_chick(): return
	if not mate:
		mate_dot.get_parent().remove_child(mate_dot)
		mate = chicken
		mate.add_child(mate_dot)
		var projected_center:Vector2 = chicken.get_projected_pen().get_center()
		var projected_width:int = 32*camera.zoom.x
		mate.position = Vector2(projected_center.x+projected_width*2, projected_center.y)
		mate.breeding = true
		mate.wait()
	elif mate == chicken:
		mating.stop()
		mate.breeding = false
		remove_dot(mate_dot)
		mate = null
	elif not mate2:
		mate_dot2.get_parent().remove_child(mate_dot2)
		mate2 = chicken
		mate2.add_child(mate_dot2)
		var projected_center:Vector2 = chicken.get_projected_pen().get_center()
		var projected_width:int = 32*camera.zoom.x
		mate2.position = Vector2(projected_center.x-projected_width*2, projected_center.y)
		mate2.breeding = true
		mate2.wait()
	elif mate2 == chicken:
		mating.stop()
		mate2.breeding = false
		remove_dot(mate_dot2)
		mate2 = null
	if mate and mate2:
		mating.start(rand_range(4, 8))
	$UI/StatsPanel.set_mate(mate, mate2, birthing.time_left > 0)

func remove_dot(dot:Node):
	if dot:
		dot.get_parent().remove_child(dot)
	add_child(dot)

func _on_Mating_timeout():
	var egg:AnimatedSprite = load("res://Coop/Egg.tscn").instance()
	add_child(egg)
	if randi() % 2 == 0:
		egg.position = mate.position
	else:
		egg.position = mate2.position
	var err := birthing.connect("timeout", self, "_on_Birthing_timeout", [egg])
	if err != OK: push_error("err connecting " + str(err))
	birthing.start(rand_range(5, 8))
	mate.birthing = true
	mate2.birthing = true
	if selected == mate or selected == mate2: 
		$UI/StatsPanel.show(false)
		remove_dot(selected_dot)
	set_can_race()
	
func _on_Birthing_timeout(egg:AnimatedSprite):
	birthing.disconnect("timeout", self, "_on_Birthing_timeout")
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
	$UI/StatsPanel.set_mate(mate, mate2, birthing.time_left > 0)
	set_can_race()
	egg.queue_free()

	
func _on_Info_pressed():
	var modal = load("res://Common/ModalBig.tscn").instance()
	modal.set_text(modal.HELP)
	add_child(modal)


func _on_StatsPanel_sell_requested(price:int):
	save_game.sell(selected.stats, price)
	var floater = load("res://Common/Floater.tscn").instance()
	if selected.stats.wins > 1: 
		floater.texture = load("res://Common/dollar.png")
	add_child(floater)
	if selected.stats.is_chick(): floater.scale = Vector2(0.5, 0.5)
	floater.position = selected.position
	selected.queue_free()
	if racer == selected:
		set_racer(null)
	if mate == selected:
		remove_dot(mate_dot)
		mate = null
	elif mate2 == selected:
		remove_dot(mate_dot2)
		mate2 = null
	remove_dot(selected_dot)
	selected = null
	update_money()
	set_can_race()
	$UI/StatsPanel.show(false)


func _on_StatsPanel_edited():
	save_game.save()

func _on_BuyFood_pressed(type:String, cost:int):
	save_game.add_food(AllChickens.FOOD_TYPES[type.to_upper()], 5, cost)
	update_food_box()
	update_money()


func _on_Shop_pressed():
	var shop := "res://Store/Store.tscn"
	var err = get_tree().change_scene(shop)
	match err:
		 OK: return
		 ERR_CANT_OPEN: push_error("ERR_CANT_OPEN " + shop + " path cannot be loaded into a PackedScene")
		 ERR_CANT_CREATE : push_error("ERR_CANT_CREATE " + shop + " cannot be instantiated.")
	push_error("Error " + str(err) + "changing to  " + shop + " ")


func _on_PettingZoo_pressed():
	var zoo := "res://PettingZoo/PettingZoo.tscn"
	var err = get_tree().change_scene(zoo)
	match err:
		 OK: return
		 ERR_CANT_OPEN: push_error("ERR_CANT_OPEN " + zoo + " path cannot be loaded into a PackedScene")
		 ERR_CANT_CREATE : push_error("ERR_CANT_CREATE " + zoo + " cannot be instantiated.")
	push_error("Error " + str(err) + "changing to  " + zoo + " ")
