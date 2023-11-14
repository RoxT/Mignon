extends Control

var save_game:AllChickens

var DIARY1 := "[b]Day 1[/b]\n\nDear Diary,\nI'm really doing it. My cousin got me three racing chickens.\n\nI put down some turf and straw on the balcony of my apartment and put up a flag so you can't see them from the street. I found a great website, ChickenWeb, about raising and racing them.\n\nI drove out to the farm store for food and they gave me a sample pack of 5 days of their specialty grasses.\n\nThe fastest chicken I got is Mignon. My cousin said she's the offspring of a chicken from the famous Vanchokens racing farm that didn't meet expectations so she was cheap.\n\nThere's a race every day, I guess I'll see how she does!\n\n<3"

var CARE := "Chickens need to eat every day. They are happy to eat cheap nutritious pellets but will thirve with more variety. Chickens will eat the best food possible as soon as they need it - you just have to have it around. Talk to your local chicken feed supplier about what they have. They will typically sell you bundles with a day's worth of food, so larger farms are more expensive.\nChickens get tired from activities like racing, raising a chick, or showing off for guests. They need time to rest afterwards."

var RACING := "There are two kinds of races, the kind that happen every day and are for anyone, and league races which are special events\n\n[b]EVERY DAY RACES[/b]\nIn order to be part of the racing circut, you must compete  in one the races held every day. Every farm in the circuit competes but because there are multiple races held on the same day your racer will only face 3 other farms per race. This is a great way to show off your flock and maybe earn some money.\n\n[b]LEAGUE RACES[/b]\nThese are special event you can enter. They are multiple days long and to win you must win every race. You will face the same 4 farms in each race of a league but you won't know what chicken they'll be bringing out."

var BREEDING := "Racing chickens need very little to get in the mood - just a private spot a some dark lighting. If you have a breeding pen you just need to put two chickens there and wait. The more tired they are the longer you may have to wait. Once they have laid an egg they'll need undisturbed time with it but once the chick is born the 'family' will seek out their old friends on their own."

var CHICKEN_COUNT := "[b]Day %s[/b]\nChickens in coop: %s\n"
var WINS_AND_LOSSES := "Wins: %s\nLosses: %s\n"
var RIVAL := "%s (%s wins against you) from %s"

const BEAST := "res://Browser/Beast.tscn"

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
	content.append_bbcode(DIARY1)


func _on_Care_toggled(button_pressed):
	if button_pressed:
		switch_to($Links/Care)
		content.bbcode_text = CARE

func _on_Racing_toggled(button_pressed):
	if button_pressed:
		switch_to($Links/Racing)
		content.bbcode_text = RACING


func _on_ToCoop_pressed():
	save_game.save()
	var err := get_tree().change_scene("res://Coop.tscn")
	if err != OK:
		push_error("Error switching scenes: " + str(err))


func _on_Breeding_toggled(button_pressed):
	if button_pressed:
		switch_to($Links/Breeding)
		content.bbcode_text = BREEDING

func _on_Beastiary_toggled(button_pressed):
	if button_pressed:
		switch_to($Links/Beastiary)
		var i := 0
		for key in save_game.discovered.keys():
			if save_game.discovered[key]:
				add_beast(key, i)
			else: 
				add_beast("unknown", i)
			i += 1
	
func add_beast(breed:String, i:int):
	var beast:Control = load(BEAST).instance()
	beast.breed = breed
	content.add_child(beast)
	beast.rect_position.y = i * 128
	
