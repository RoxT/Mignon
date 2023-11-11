extends Resource
class_name Chicken
const LOW_SPEED := 40
const HIGH_SPEED := 500
const breeds := ["brown", "white", "floof", "bigger floof", "rooster"]

export(String) var nom
export(int) var top_speed
export(Color) var colour
export(String) var farm
export(String) var breed

export(int) var wins
export(int) var fatigue
export(int) var age
var boost := 1.0
export(float)var speed_guess setget set_speed_guess


# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(new_top_speed = _random_speed(), new_nom = random_name(), new_wins = 0, new_colour:=_random_colour(), new_farm:="", new_fatigue := 0, new_breed := _random_breed(), new_age:=2, new_speed_guess=-1.0):
	top_speed = new_top_speed
	nom = new_nom
	wins = new_wins
	colour = new_colour
	farm = new_farm
	fatigue = new_fatigue
	breed = new_breed
	age = new_age
	speed_guess = new_speed_guess

func is_chick()->bool:
	return age < 2

func get_speed()->int:
	
	var entropy:float = 1.0 - fatigue*0.1
	return top_speed * entropy * boost

func is_exhausted()->bool:
	return fatigue >= 3 and get_speed() <= LOW_SPEED
	
func set_speed_guess(value:float):
	if speed_guess == top_speed: return
	speed_guess = value

func get_bracket()->String:
	if top_speed < 200: return "poor"
	elif top_speed < 350: return "good"
	else: return "great"

func _random_speed()->int:
	randomize()
	return randi() % (HIGH_SPEED-100-LOW_SPEED) + LOW_SPEED

static func random_name()->String:
	return EnemyChickens.get_random_nom()
	
func _random_colour()->Color:
	var c := Color.white
	c.r -= rand_range(0, 0.35)
	c.g -= rand_range(0, 0.35)
	c.b -= rand_range(0, 0.35)
	return c
	
func _random_breed()->String:
	return breeds[randi() % breeds.size()]

func get_sprite_frames()->SpriteFrames:
	var path := ""
	match breed:
		"brown": path = "res://chicken/breeds/brown_spf.tres"
		"white": path = "res://chicken/breeds/white_spf.tres"
		"rooster": path = "res://chicken/breeds/brown_rooster_spf.tres"
		"floof": path = "res://chicken/breeds/brown_varied.tres"
		"bigger floof": path = "res://chicken/breeds/fat_brown_spf.tres"
		"mottled": path = "res://chicken/breeds/mottled_spf.tres"
		var b: push_error("Unknown breed: " + b)
	
	return load(path) as SpriteFrames

func _to_string():
	var text := ""
	for p in get_property_list():
		if p.usage == 8199:
			if p.type == 14:
				text += p.name + ": " + str(get(p.name).r8) + ", " + str(get(p.name).g8) + ", " + str(get(p.name).b8) + " "
			else:
				text += p.name + ": " + str(get(p.name)) + ", "
	return text

