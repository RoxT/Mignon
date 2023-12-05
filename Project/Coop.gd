extends Node2D

var save_game:AllChickens
var Badge:PackedScene = load("res://Coop/Badge.tscn")
const COST_RACE := 5
const COST_NEW := 10
const WHAT_ROUND := "League: %s\nRound: %s"
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
	if M.fade:
		modulate = Color("02004a")
		$AnimationPlayer.play("fade_in")
		
	M.fade = false
	get_tree().call_group("drop", "hide")
	get_tree().call_group("league_drop", "hide")
	var chicken_stats := []
	save_game = M.save_game
	if save_game == null:
		_on_Reset_pressed()
		return
	
	if save_game.show_diary:
		_goto_scene("res://Diary/Diary.tscn")
	chicken_stats = save_game.get_all()
	if save_game.connect("alert", self, "_on_alerted") != OK: 
		push_error("signal connection to save game failed")
	
	
	pen = load("res://Coop/Pens/" + save_game.pen + ".tscn").instance()
	$Pens.add_child(pen)
	pen.border_color = Color.greenyellow
	pen.modulate = Color.white
	camera.zoom = pen.get_zoom()

	save_game.temp_racer = null
	var marked
	for stats in chicken_stats:
		stats = stats as Chicken
		var chicken = preload("res://Coop/CoopChicken.tscn").instance()
		chicken.stats = stats
		add_child(chicken)
		var x := rand_range(pen.get_begin().x, pen.get_end().x)
		var y := rand_range(pen.get_begin().y, pen.get_end().y)
		chicken.position = Vector2(x, y)
		chicken.connect("clicked", self, "_on_chicken_clicked")
		chicken.connect("unclicked", self, "_on_chicken_unclicked")
		if save_game.racer == stats || !marked:
			marked = chicken
		chicken.pen = Rect2(pen.rect_position, pen.rect_size)
		chicken.zoom = camera.zoom.x
		if save_game.last_racer == stats:
			select_chicken(chicken)

		var sorted:Array = get_tree().get_nodes_in_group("meander")
		if sorted.size() >= 3:
			sorted.sort_custom(self, "compare_wins")
			add_badge(sorted[0],3)
			add_badge(sorted[1],2)
			add_badge(sorted[2],1)
		else:
			for c in sorted: add_badge(c, 1)
	if save_game.already_zooed():
		$UI/PettingZoo.text = "Today's Zoo Report"
		
	set_racer(marked)
	update_money()
	update_food_box()
	
	if save_game.league_in_progress:
		$UI/Race.disabled = true
		$UI/PettingZoo.disabled = true
		$UI/LeagueRace.theme_type_variation="RaceStyleBtn"
		$UI/LeagueRace/WhatLeague.text = WHAT_ROUND % [save_game.league_in_progress.league, save_game.current_round()]
	else:
		$UI/LeagueRace/WhatLeague.text = ""

	if save_game.new_alert:
		_on_alerted()
	else:
		$UI/Journal/Bang.hide()
	#$Race.call_deferred("grab_focus") 
	
func _on_alerted():
	$AnimationPlayer.play("alert")
	
func compare_wins(a, b)->bool:
	return a.stats.wins > b.stats.wins

func add_badge(chicken, rank):
	if chicken and chicken.stats.wins > 0:
		var b = Badge.instance()
		b.rank = rank
		chicken.add_child(b)

func _on_chicken_clicked(chicken:Node):
	select_chicken(chicken)
	if not chicken.stats.is_chick():
		if save_game.current_league:
			get_tree().call_group("league_drop", "show")
		else:
			get_tree().call_group("drop", "show")
			set_race_text(chicken)
		if chicken.breeding == true:
			_on_StatsPanel_requested_breed(chicken)
			
func select_chicken(chicken:Node):
	if chicken == null:return
	selected = chicken
	selected_dot.get_parent().remove_child(selected_dot)
	selected.add_child(selected_dot)
	$UI/StatsPanel.stats = selected.stats
	$UI/StatsPanel.set_mate(mate, mate2, birthing.time_left > 0)
	if get_adult_chicken(chicken) == null:
		$UI/StatsPanel.stop_sell(true)

func _on_chicken_unclicked(chicken:Node):
	var drops
	if save_game.current_league:
		drops = get_tree().get_nodes_in_group("league_drop")
	else:
		drops = get_tree().get_nodes_in_group("drop")
		set_race_text(racer)
	for drop in drops:
		var d:ReferenceRect = drop as ReferenceRect
		if  d.get_global_rect().has_point(get_viewport().get_mouse_position()):
			var place:String = d.get_parent().name
			if place == "Race": _on_Race_pressed(chicken)
			elif place == "PenRect": _on_StatsPanel_requested_breed(chicken)
			elif place == "LeagueRace": _on_LeagueRace_pressed(chicken)
			break
	get_tree().call_group("league_drop", "hide")
	get_tree().call_group("drop", "hide")
	

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
	if racer == null or save_game.all.empty() or $BreedingPen/PenRect/Birthing.time_left > 0 or save_game.league_in_progress:
		$UI/Race.disabled = true
	else:
		$UI/Race.disabled = false

func update_money():
	$UI/Money.text = "Money: $" + str(save_game.money)

func update_food_box():
	food_box.get_node("Label").visible = save_game.foods == [0,0,0]
	food_box.get_node("BEST").count = save_game.foods[AllChickens.FOOD_TYPES.BEST]
	food_box.get_node("GOOD").count = save_game.foods[AllChickens.FOOD_TYPES.GOOD]
	food_box.get_node("BASIC").count = save_game.foods[AllChickens.FOOD_TYPES.BASIC]
	
func _on_Reset_pressed():
	M.reset()
	_goto_scene("res://Diary/Diary.tscn")

func _on_New_pressed(paid:bool, stats:= Chicken.new(), new_pos:=Vector2(pen.rect_position.x, pen.rect_position.y)):
	var new_chicken = preload("res://Coop/CoopChicken.tscn").instance()
	stats.farm = "YOU"
	new_chicken.stats = stats
	if paid:
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
		if mate2 and chicken.stats.is_related(mate2.stats):
			return
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
		if mate and chicken.stats.is_related(mate.stats):
			return
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
		var fatigue = max(mate.stats.fatigue, mate2.stats.fatigue)
		mating.start(rand_range(1, 3) * (1 + fatigue))
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
	get_tree().set_group("action", "disabled", true)
	set_can_race()
	
func _on_Birthing_timeout(egg:AnimatedSprite):
	birthing.disconnect("timeout", self, "_on_Birthing_timeout")
	var baby:Chicken = save_game.do_mating(mate2.stats, mate.stats)
	baby.age = 0
	
	_on_New_pressed(false, baby, egg.position)
	mate.stats.tire(1)
	mate.breeding = false
	mate.wait()
	mate2.stats.tire(1)
	mate2.breeding = false
	mate2.wait()
	remove_dot(mate_dot)
	remove_dot(mate_dot2)
	mate = null
	mate2 = null
	$UI/StatsPanel.set_mate(mate, mate2, birthing.time_left > 0)
	set_can_race()
	get_tree().set_group("action", "disabled", false)
	egg.queue_free()

	
func _on_Info_pressed():
	var modal = load("res://Common/ModalBig.tscn").instance()
	add_child(modal)
	modal.set_text(modal.HELP)


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
	_goto_scene(shop)

func _on_PettingZoo_pressed():
	var zoo := "res://PettingZoo/PettingZoo.tscn"
	_goto_scene(zoo)

func _on_LeagueRace_pressed(chicken=null):
	if chicken:
		save_game.temp_racer = chicken.stats
	_goto_scene("res://League/League.tscn")

func _goto_scene(path:String):
	var err = get_tree().change_scene(path)
	match err:
		 OK: return
		 ERR_CANT_OPEN: push_error("ERR_CANT_OPEN " + path + " path cannot be loaded into a PackedScene")
		 ERR_CANT_CREATE : push_error("ERR_CANT_CREATE " + path + " cannot be instantiated.")
	push_error("Error " + str(err) + "changing to  " + path + " ")

func _on_WebChickens_pressed():
	_goto_scene("res://Browser/Browser.tscn")


func _on_Journal_pressed():
	_goto_scene("res://Journal/Journal.tscn")
