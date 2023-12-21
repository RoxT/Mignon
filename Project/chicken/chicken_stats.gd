extends Resource
class_name Chicken
const LOW_SPEED := 40
const HIGH_SPEED := 290

export(String) var nom
export(int) var top_speed
export(Color) var colour
export(String) var farm
export(String) var breed
export(int) var unique_no

export(int) var wins
export(int) var fatigue
export(int) var age
export(Array) var parents_grandparents
var boost := 1.0
export(float)var speed_guess setget set_speed_guess
export(int) var fame setget , get_fame

const TEXTURE_PATH := "res://chicken/breeds/%s_spf.tres"

const MATURE := 30
const ELDERLY := 60

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(new_top_speed = _random_speed(), new_nom = random_name(), new_wins = 0, new_colour:=_random_colour(), new_farm:="", new_fatigue := 0, new_breed := _random_breed(), new_parents_grandparents = [], new_unique_no := -1, new_age:=2, new_speed_guess=-1.0, new_fame=0):
	top_speed = new_top_speed
	nom = new_nom
	wins = new_wins
	colour = new_colour
	farm = new_farm
	fatigue = new_fatigue
	breed = new_breed
	age = new_age
	speed_guess = new_speed_guess
	parents_grandparents = new_parents_grandparents
	unique_no = new_unique_no
	fame = new_fame
	
func is_chick()->bool:
	return age < 2
	
func is_mature()->bool:
	return age >= MATURE
	
func is_elderly()->bool:
	return age >= ELDERLY

func get_speed()->int:
	var entropy:float = 1.0 - fatigue*0.1
	if is_chick():
		return top_speed * entropy * boost / 2
	return top_speed * entropy * boost

func is_exhausted()->bool:
	return fatigue >= 3 and get_speed() <= LOW_SPEED

func get_fame()->int:
	if is_famous():
		return fame + 1
	else:
		return fame

func is_famous()->bool:
	return wins >= 10
	
func tire(amount:int):
	fatigue += amount
	if is_mature(): 
		fatigue += 1
	if is_elderly():
		fatigue += 1
	
func set_speed_guess(value:float):
	if speed_guess == top_speed: return
	speed_guess = value
	
func is_related(b:Chicken)->bool:
	if b.parents_grandparents.has(unique_no):
		return true
	if parents_grandparents.has(b.unique_no):
		return true
	for p in parents_grandparents:
		if b.parents_grandparents.has(p):
			return true
	return false
	

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
	
func _random_breed()->String:
	return M.DEFUALT_BREEDS[randi() % M.DEFUALT_BREEDS.size()]
	
func get_price()->int:
	var tired = 1-(fatigue * 0.05)
	if wins == 0:
		return int(5 * tired)
	if is_famous():
		return 5 + int((wins * 20) * tired)
	else:
		return 5 + int((wins * 10) * tired)

func apply_sprite(sprite:AnimatedSprite):
	sprite.frames = load(TEXTURE_PATH % breed) as SpriteFrames
	sprite.modulate = colour
	if is_mature():
		if breed == M.WHITE_CORNISH_HEN:
			sprite.modulate.b += 0.1
			sprite.modulate.g += 0.1 
			sprite.modulate.r += 0.1 
		sprite.material = preload("res://chicken/mature_shader_material.tres")
	else:
		sprite.material = null

func _to_string():
	var text := ""
	for p in get_property_list():
		if p.usage == 8199:
			if p.type == 14:
				text += p.name + ": " + str(get(p.name).r8) + ", " + str(get(p.name).g8) + ", " + str(get(p.name).b8) + " "
			else:
				text += p.name + ": " + str(get(p.name)) + ", "
	return text

