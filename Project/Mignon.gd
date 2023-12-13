extends Node

	 # Breeds #
const BROWN := "brown"
const WHITE := "white"
const MOTTLED := "mottled"
const FLOOF := "floof"
const BIGGER_FLOOF := "bigger_floof"
const BROWN_ROOSTER := "brown_rooster"
const BLACK_ONYX := "black_onyx"

const DEFUALT_BREEDS := [BROWN, WHITE]
const BREEDS_LIST := [
	WHITE, BROWN, MOTTLED, FLOOF, BIGGER_FLOOF, BROWN_ROOSTER, BLACK_ONYX
]

var fade := true

const pairs := {WHITE: {
					BROWN: MOTTLED, 
					FLOOF: BIGGER_FLOOF},
				BROWN: {
					WHITE: MOTTLED, 
					MOTTLED: FLOOF,
					FLOOF: BROWN_ROOSTER,
					BIGGER_FLOOF: BLACK_ONYX},
				MOTTLED: {
					BROWN: FLOOF},
				FLOOF: {
					BROWN: BROWN_ROOSTER,
					WHITE: BIGGER_FLOOF},
				BIGGER_FLOOF: {
					BROWN: BLACK_ONYX
				}
				}

var save_game:AllChickens

# Called when the node enters the scene tree for the first time.
func _ready():
	if save_game == null:
		load_game()
			
func load_game():
	if AllChickens.exists():
		save_game = load(AllChickens.PATH) as AllChickens
		if save_game == null:
			var layer := CanvasLayer.new()
			var label := Label.new()
			layer.add_child(label)
			label.rect_position = Vector2(400, 300)
			get_tree().current_scene.add_child(layer)
			if AllChickens.backup_exists():
				label.text = "Save file corrupted, re-loaded from last day"
				save_game = load(AllChickens.PATH_BACKUP) as AllChickens
			if save_game == null:
				label.text = "Save file corrupted"
		else:
			save_game.save()
	else:
		reset()
			
func get_save_game()->AllChickens:
	if save_game == null:
		load_game()
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
	
static func capitalized_parents(breed:String)->Array:
	var caps := []
	for p in parents(breed):
		caps.append(p.capitalize())
	return caps

func reset():
	get_tree().current_scene.save_game = null
	save_game = AllChickens.new()
	save_game.initialize_game()
	save_game.save()
	get_tree().current_scene.save_game = save_game
