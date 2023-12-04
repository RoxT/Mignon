extends Node

	 # Breeds #
const BROWN := "brown"
const WHITE := "white"
const MOTTLED := "mottled"
const FLOOF := "floof"
const BIGGER_FLOOF := "bigger_floof"
const BROWN_ROOSTER := "brown_rooster"

const DEFUALT_BREEDS := [BROWN, WHITE]
const BREEDS_LIST := [
	WHITE, BROWN, MOTTLED, FLOOF, BIGGER_FLOOF, BROWN_ROOSTER
]

var fade := true

const pairs := {WHITE: {
					BROWN: MOTTLED, 
					FLOOF: BIGGER_FLOOF},
				BROWN: {
					WHITE: MOTTLED, 
					MOTTLED: FLOOF,
					FLOOF: BROWN_ROOSTER},
				MOTTLED: {
					BROWN: FLOOF},
				FLOOF: {
					BROWN: BROWN_ROOSTER,
					WHITE: BIGGER_FLOOF}
				}

var save_game:AllChickens setget ,get_save_game

# Called when the node enters the scene tree for the first time.
func _ready():
	if AllChickens.exists():
		save_game = load(AllChickens.PATH) as AllChickens
		if save_game == null:
			print(str(load(AllChickens.PATH)))
		else:
			save_game.save()

func get_save_game()->AllChickens:
	if save_game == null and AllChickens.exists():
		print(load(AllChickens.PATH))
	return save_game

static func get_uncommon_list()->Array:
	var u := BREEDS_LIST.duplicate()    
	for d in DEFUALT_BREEDS:
		u.erase(d)
	return u

static func parents(breed:String)->Array:
	for a in pairs.keys():
		for b in pairs[a].keys():
			if pairs[a][b] == breed:
				return [a, b]
	return []

func reset():
	get_tree().current_scene.save_game = null
	save_game = AllChickens.new()
	save_game.initialize_game()
	save_game.save()
	get_tree().current_scene.save_game = save_game
