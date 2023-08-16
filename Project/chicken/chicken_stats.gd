extends Resource
class_name Chicken
const LOW_SPEED := 40
const HIGH_SPEED := 500
const names := ["Aimeé","Belle","Bijou","Chérie","Coquette","Fleur","Lyonette","Mignon"]

export(int) var top_speed
export(String) var nom
export(Color) var colour
export(bool) var white
export(String) var farm
export(int) var index

export(int) var wins
export(int) var fatigue

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(new_top_speed = random_speed(), new_nom = random_name(), new_wins = 0, new_colour:=random_colour(), new_white:=random_white(), new_farm:="", new_index:=-1, new_fatigue := 0):
	top_speed = new_top_speed
	nom = new_nom
	wins = new_wins
	colour = new_colour
	white = new_white
	farm = new_farm
	index = new_index
	fatigue = new_fatigue

func get_speed()->int:
	var s:float = clamp(fatigue * 0.1 * top_speed, 0, top_speed)
	return top_speed - round(s)

func random_speed()->int:
	randomize()
	return randi() % (HIGH_SPEED-LOW_SPEED) + LOW_SPEED

func random_name()->String:
	return names[randi() % names.size()]
	
func random_colour()->Color:
	var c := Color.white
	c.r -= rand_range(0, 0.35)
	c.g -= rand_range(0, 0.35)
	c.b -= rand_range(0, 0.35)
	return c
	
func random_white()->bool:
	return randi() % 5 == 0
