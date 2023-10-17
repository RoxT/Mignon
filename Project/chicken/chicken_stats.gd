extends Resource
class_name Chicken
const LOW_SPEED := 40
const HIGH_SPEED := 500
const breeds := ["brown", "white", "floof", "bigger floof", "rooster"]

export(String) var nom
export(int) var top_speed
export(Color) var colour
export(bool) var white
export(String) var farm
export(String) var breed

export(int) var wins
export(int) var fatigue
export(int) var age
var boost := 1.0


# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(new_top_speed = _random_speed(), new_nom = random_name(), new_wins = 0, new_colour:=_random_colour(), new_white:=_random_white(), new_farm:="", new_fatigue := 0, new_breed := _random_breed(), new_age:=2):
	top_speed = new_top_speed
	nom = new_nom
	wins = new_wins
	colour = new_colour
	white = new_white
	farm = new_farm
	fatigue = new_fatigue
	breed = new_breed
	if breed == "white": white = true
	age = new_age

func is_chick()->bool:
	return age < 2

func get_speed()->int:
	var s:float = clamp(fatigue * 0.1 * top_speed, 0, top_speed) * boost
	return top_speed - round(s)

func is_exhausted()->bool:
	return fatigue >= 3 and get_speed() <= LOW_SPEED

func get_bracket()->String:
	if top_speed < 200: return "poor"
	elif top_speed < 350: return "good"
	else: return "great"

func _random_speed()->int:
	randomize()
	return randi() % (HIGH_SPEED-LOW_SPEED) + LOW_SPEED

static func random_name()->String:
	return EnemyChickens.get_random_nom()
	
func _random_colour()->Color:
	var c := Color.white
	c.r -= rand_range(0, 0.35)
	c.g -= rand_range(0, 0.35)
	c.b -= rand_range(0, 0.35)
	return c
	
func _random_white()->bool:
	return randi() % 5 == 0
	
func _random_breed()->String:
	return breeds[randi() % breeds.size()]

func _to_string():
	var text := ""
	for p in get_property_list():
		if p.usage == 8199:
			if p.type == 14:
				text += p.name + ": " + str(get(p.name).r8) + ", " + str(get(p.name).g8) + ", " + str(get(p.name).b8) + " "
			else:
				text += p.name + ": " + str(get(p.name)) + ", "
	return text

