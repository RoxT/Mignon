extends Control

var save_game:AllChickens

var DIARY1 := "Day 1\n\nDear Diary,\nI'm really doing it. My cousin got me three racing chickens.\n\nI put down some turf and straw on the balcony of my apartment and put up a flag so you can't see them from the street. I found a great website, ChickenWeb, about raising and racing them.\n\nI drove out to the farm store for food and they gave me a sample pack of 5 days of their specialty grasses.\n\nThe fastest chicken I got is Mignon. My cousin said she's the offspring of a chicken from the famous Vanchokens racing farm that didn't meet expectations so she was cheap.\n\nThere's a race every day, I guess I'll see how she does!\n\n<3"

var CARE := "Chickens need to eat every day. They are happy to eat cheap nutritious pellets but will thirve with more variety. Chickens will eat the best food possible as soon as they need it - you just have to have it around. Talk to your local chicken feed supplier about what they have. They will typically sell you bundles with a day's worth of food, so larger farms are more expensive.\nChickens get tired from activities like racing, raising a chick, or showing off for guests/ They need time to rest afterwards."

var RACING := "There are two kinds of races, the kind that happen every day and are for anyone, and league races which are special events\n\n[b]EVERY DAY RACES[/b]\nIn order to be part of the racing circut, you must compete  in one the races held every day. Every farm in the circuit competes but because there are multiple races held on the same day your racer will only face 3 other farms per race. This is a great way to show off your flock and maybe earn some money.\n\n[b]LEAGUE RACES[/b]\nThese are special event you can enter. They are multiple days long and to win you must win every race. You will face the same 4 farms in each race of a league but you won't know what chicken they'll be bringing out."



onready var content := $Content
onready var links := $Links


# Called when the node enters the scene tree for the first time.
func _ready():
	if AllChickens.exists():
		save_game = load(AllChickens.PATH) as AllChickens
	else:
		push_error("No chickens found")
	save_game.save()

func switch_to(target:LinkButton):
	for l in links.get_children():
		if l != target:
			l.pressed = false

func _on_Diary_toggled(_button_pressed):
	switch_to($Links/Diary)
	content.clear()
	content.bbcode_text = DIARY1


func _on_Care_toggled(_button_pressed):
	switch_to($Links/Care)
	content.clear()
	content.bbcode_text = CARE

func _on_Racing_toggled(_button_pressed):
	switch_to($Links/Racing)
	content.clear()
	content.bbcode_text = RACING


func _on_ToCoop_pressed():
	save_game.save()
	var err := get_tree().change_scene("res://Coop.tscn")
	if err != OK:
		push_error("Error switching scenes: " + str(err))
