extends Control

var DIARY1 := "[b]Day 1[/b]\n\nDear Diary,\nI'm really doing it. My cousin got me three racing chickens.\n\nI put down some turf and straw on the balcony of my apartment and put up a flag so you can't see them from the street. I found a great website, ChickenWeb, about raising and racing them.\n\nI drove out to the farm store for food and they gave me a sample pack of 5 days of their specialty grasses.\n\nThe fastest chicken I got is Mignon. My cousin said she's the offspring of a chicken from the famous Vanchokens racing farm that didn't meet expectations so she was cheap.\n\nThere's a race every day, I guess I'll see how she does!\n\n<3"

var save_game:AllChickens

var CHICKEN_COUNT := "[b]Day %s[/b]\nChickens in coop: %s\n"
var WINS_AND_LOSSES := "Wins: %s\nLosses: %s\n"
var RIVAL := "%s (%s wins against you) from %s"

const BEAST := "res://Browser/Beast.tscn"
const DATE := "[b]Day %s[/b]\n\n"

onready var content := $Content
onready var links := $Links


# Called when the node enters the scene tree for the first time.
func _ready():
	if AllChickens.exists():
		save_game = load(AllChickens.PATH) as AllChickens
	else:
		push_error("No chickens found")
	save_game.save()
	$Links/Diary.pressed = true

func switch_to(target:LinkButton):
	content.clear()
	get_tree().call_group("beast", "queue_free")
	for l in links.get_children():
		if l != target:
			l.pressed = false

func _on_Diary_toggled(button_pressed):
	if !button_pressed: return
	switch_to($Links/Diary)
	content.append_bbcode(CHICKEN_COUNT % [save_game.day, str(save_game.get_all().size())])
	content.append_bbcode(WINS_AND_LOSSES % [save_game.wins, save_game.losses])
	content.append_bbcode("Greatest Rival: ")
	if save_game.day > 1: 
		var rival:Chicken = save_game.enemy_farms[0].get_enemies()[0]
		for farm in save_game.enemy_farms:
			for enemy in farm.chickens:
				if enemy.wins > rival.wins:
					rival = enemy
		if rival.wins > 0:
			content.append_bbcode(RIVAL % [rival.nom, rival.wins, rival.farm])
		else:
			content.append_bbcode("None yet")
	content.append_bbcode("\n\n")
	var events:Array = save_game.events
	for i in range(events.size()-1,-1,-1):
		var e:Event = events[i]
		content.append_bbcode(DATE % e.day)
		content.append_bbcode(tr(e.key) % e.args)
		content.append_bbcode("\n\n")
	


func _on_Breeds_toggled(button_pressed):
	if button_pressed:
		switch_to($Links/Breeds)
		var i := 0
		for key in save_game.breeds_discovered.keys():
			if save_game.breeds_discovered[key]:
				add_beast(key, i)
			else: 
				add_beast("unknown", i)
			i += 1
	
func add_beast(breed:String, i:int):
	var beast:Control = load(BEAST).instance()
	beast.breed = breed
	content.add_child(beast)
	beast.rect_position.y = i * 128


func _on_ToCoop_pressed():
	save_game.save()
	var err := get_tree().change_scene("res://Coop.tscn")
	if err != OK:
		push_error("Error switching scenes: " + str(err))
