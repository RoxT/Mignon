extends Resource
class_name Chicken
const LOW_SPEED := 40
const HIGH_SPEED := 500
const names := ["Aimeé","Belle","Bijou","Chérie","Coquette","Fleur","Lyonette","Mignon"]

export(int) var speed
export(String) var nom
export(Color) var colour

export(int) var wins

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(new_speed = random_speed(), new_nom = random_name(), new_wins = 0, new_colour:=random_colour()):
	speed = new_speed
	nom = new_nom
	wins = new_wins
	colour = new_colour

func random_speed()->int:
	randomize()
	return randi() % (HIGH_SPEED-LOW_SPEED) + LOW_SPEED

func random_name()->String:
	return names[randi() % names.size()]
	
func random_colour()->Color:
	var c := Color.white
	c.r -= rand_range(0, 0.4)
	c.g -= rand_range(0, 0.4)
	c.b -= rand_range(0, 0.4)
	return c
	
