extends Control

var save_game:AllChickens

var CARE := "[b]CARE AND FEEDING[/b]\n\nChickens need to eat every day. They are happy to eat cheap nutritious pellets but will thirve with more variety. Chickens will eat the best food possible as soon as they need it - you just have to have it around. Talk to your local chicken feed supplier about what they have. They will typically sell you bundles with a day's worth of food, so larger farms are more expensive.\n\nChickens get tired from activities like racing, raising a chick, or showing off for guests. They need time to rest afterwards.\n\nYour chickens won't be young spring chickens forever - once they're mature they will need more time to recover their energy. Eventually they will reach a more distinguished age and need even more time to recover. This is a great time to sell a chicken with some wins to farm with a less demanding schedule.\n\nFinally, how do you know how fast your girl really is? Well at WebChickens we know the quest for knowedge is never ending - but the next best thing is racing your chicken in their most relaxed state. Every chicken at the daily races gets their speed measured for that day on site."

var RACING := "[b]RACING[/b]\n\nThere are two kinds of races, the kind that happen every day and are for anyone, and league races which are special events\n\n[b]EVERY DAY RACES[/b]\nIn order to be part of the racing circut, you must compete  in one the races held every day. Every farm in the circuit competes but because there are multiple races held on the same day your racer will only face 3 other farms per race. This is a great way to show off your flock and maybe earn some money.\n\n[b]LEAGUE RACES[/b]\nThese are special event you can enter. They are multiple races in one day and to win you must win every race. You will face the same farms in each round of a league but you won't know what chicken they'll be bringing out.(This feature not ready yet)"

var BREEDING := "[b]BREEDING[/b]\n\nRacing chickens need very little to get in the mood - just a private spot a some dark lighting. If you have a breeding pen you just need to put two chickens there and wait. The more tired they are the longer you may have to wait. Once they have laid an egg they'll need undisturbed time with it but once the chick is born the 'family' will seek out their old friends on their own.\n\nEach of a chick's traits (colour, breed, and speed) is inherited from one parrent or the other. \n\nSpeed is more complicated than one simple gene and might be slightly different from it's parent, usually chicks born on your farm will be faster than the parent they inherited speed from. The only way to know for sure what your new chick's speed is is to race it when it's fully rested and eating plain food.\n\nGenes for breed sometimes combine to make somthing new instead of being just one or the other - you should take notes of what you've discovered. This is called hybridizing and the resulting chick will often be a little faster.\n\nColour is the most straight forward trait. Chicks inherit one or the other parent's colour variation, but it will look different on different breeds."

const PETTING_ZOO := "[b]PETTING ZOO[/b]\n\nTo earn extra money and get a sense of your farm you can open it up to visitors. Visitors will find any excuse to see your chickens and once the doors are closed you can make a report of what you've seen. Admission is the same but adults come to see the fast chickens and children prefer slower ones they can pet."

onready var content :RichTextLabel= $Content
onready var links := $Links

# Called when the node enters the scene tree for the first time.
func _ready():
	if AllChickens.exists():
		save_game = load(AllChickens.PATH) as AllChickens
	else:
		push_error("No chickens found")
	save_game.save()
	$Links/Care.pressed = true

func switch_to(target:LinkButton):
	content.clear()
	get_tree().call_group("beast", "queue_free")
	for l in links.get_children():
		if l != target:
			l.pressed = false


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

func _on_PettingZoo_toggled(button_pressed):
	if button_pressed:
		switch_to($Links/PettingZoo)
		content.bbcode_text = PETTING_ZOO
