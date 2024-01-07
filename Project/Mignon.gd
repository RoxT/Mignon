extends Node


var leagues := {
	BRONZE : {"farms":["St. Germain's", "Anualonacu", "QkChkns"],
				"prize_race": 20, "prize_all":200},
	SILVER : {"farms":["Bec-de-Beak", "Jam Jar Farms", "QkChkns",],
				"prize_race": 20, "prize_all":400},
	GOLD : {"farms":["Vanchokons", "Martot", "Bec-de-Beak"],
			  "prize_race": 20, "prize_all":600}
}

const BRONZE := "BRONZE"
const SILVER := "SILVER"
const GOLD := "GOLD"

	 # Farms #
const STARTER_PRICE := 200
const MEDIUM_PRICE := 300
const LARGE_PRICE := 400

	 # Breeds #
const PLYMOUTH_ROCK := "plymouth_rock"
const WHITE_CORNISH := "white_cornish"
const SUSSEX := "sussex"
const RUSSIAN_ORLOFF := "russian_orloff"
const SILKIE := "silkie"
const LEGHORN := "leghorn"
const MYSTIC_ONYX := "mystic_onyx"
const POLISH_CHICKEN := "polish_chicken"

const DEFUALT_BREEDS := [PLYMOUTH_ROCK, WHITE_CORNISH]
const BREEDS_LIST := [
	WHITE_CORNISH, PLYMOUTH_ROCK, SUSSEX, RUSSIAN_ORLOFF, SILKIE, LEGHORN, MYSTIC_ONYX, POLISH_CHICKEN
]

var fade := true

const pairs := {WHITE_CORNISH: {
					PLYMOUTH_ROCK: SUSSEX, 
					RUSSIAN_ORLOFF: SILKIE},
				PLYMOUTH_ROCK: {
					WHITE_CORNISH: SUSSEX, 
					SUSSEX: RUSSIAN_ORLOFF,
					RUSSIAN_ORLOFF: LEGHORN,
					SILKIE: MYSTIC_ONYX},
				SUSSEX: {
					PLYMOUTH_ROCK: RUSSIAN_ORLOFF},
				RUSSIAN_ORLOFF: {
					PLYMOUTH_ROCK: LEGHORN,
					WHITE_CORNISH: SILKIE,
					SILKIE: POLISH_CHICKEN},
				SILKIE: {
					PLYMOUTH_ROCK: MYSTIC_ONYX,
					RUSSIAN_ORLOFF: POLISH_CHICKEN
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
			if !save_game.breeds_discovered.has(M.POLISH_CHICKEN):
				save_game.breeds_discovered[M.POLISH_CHICKEN] = false
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
