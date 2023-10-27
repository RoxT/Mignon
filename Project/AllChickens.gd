extends Resource
class_name AllChickens
export(Array, Resource) var all:Array setget , get_all
export(Array, Resource) var enemy_farms:Array setget , get_enemy_farms
export(Resource) var racer setget set_racer
export(Resource) var temp_racer setget set_temp_racer
export(int) var money
export(int) var deaths
export(String) var pen
export(Array) var foods
export(bool) var speed_boost

enum FOOD_TYPES {BEST, GOOD, BASIC}

const PATH := "user://chickens.tres"
const YOU := "YOU"

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(new_all = generate_mignon(), new_racer=null, new_money := 50, new_deaths := 0, new_temp_racer=null, new_pen="Starter", new_enemy_farms=generate_enemy_list(), new_foods=[0,10,0], new_speed_boost:=1.0):
	all = new_all
	racer = new_racer
	money = new_money
	deaths = new_deaths
	temp_racer = new_temp_racer
	pen = new_pen
	enemy_farms = new_enemy_farms
	foods = new_foods
	speed_boost = new_speed_boost
		
func pass_day():
	speed_boost = 1
	var fatigue := 0
	for i in range(foods.size()):
		if foods[i] > 0:
			foods[i] -= 1
			match i:
				0: 
					fatigue = 2
					speed_boost = 1.15
				1: speed_boost = 1.15
				2: fatigue = 1
			break
	for c in all:
		c.fatigue = max(c.fatigue-fatigue, 0)
		c.age += 1
	save()


static func exists()->bool:
	return ResourceLoader.exists(PATH)

func get_all()->Array:
	return all
	
func get_enemy_farms()->Array:
	return enemy_farms
	
static func do_mating(a:Chicken, b:Chicken)->Chicken:
	var bonus := rand_range(-2,5)
	return Chicken.new(one_of_two(a, b, "top_speed")+bonus, Chicken.random_name(), 0, one_of_two(a, b, "colour"), one_of_two(a, b, "white"), one_of_two(a, b, "farm"), 2, one_of_two(a, b, "breed"))

static func one_of_two(a:Chicken, b:Chicken, property:String):
	return [a.get(property), b.get(property)][randi()%2]

func save():
	var err := ResourceSaver.save(PATH, self)
	if err != OK: push_error("Error saving! " + str(err))

func sell(chicken:Chicken, price:int):
	if racer == chicken:
		racer = null
	all.erase(chicken)
	money += price
	save()

func add_chicken_stats(value:Chicken):
	assert(value != null)
	all.append(value)
	save()

func set_racer(value:Resource):
	racer = value as Chicken
	save()

func set_temp_racer(value:Resource):
	if value:
		temp_racer = value as Chicken
	else: temp_racer = value
	save()

func death(value:Chicken):
	if racer == value:
		racer = null
	all.erase(value)
	deaths += 1
	save()
	
func get_competition(lanes:int)->Array:
	if lanes > enemy_farms.size(): push_error("More lanes than Farms")
	var competition := []
	var farms = choose_farms(lanes, bag(enemy_farms.size()), enemy_farms)
	for f in farms:
		f = f as Farm
		competition.append(f.chickens[randi() % f.chickens.size()])
	return competition

static func choose_farms(lanes, bag_of_indexes, enemies)->Array:
	var farms := []
	while farms.size() < lanes:
		var i:int = bag_of_indexes[randi() % bag_of_indexes.size()]
		farms.append(enemies[i])
		bag_of_indexes.erase(i)
	
	return farms

static func bag(things:int)->Array:
	var bag := []
	for i in range(things):
		bag.append(i)
	return bag
	
func buy_food(type:int, amount:int, cost:=0):
	foods[type] += amount
	money -= cost
	save()
	
func generate_mignon()->Array:
	var new_coop := []
	var mignon := Chicken.new()
	mignon.top_speed = 280
	mignon.colour = Color.white
	mignon.white = false
	mignon.breed = "brown"
	mignon.farm = YOU
	mignon.nom = "Mignon"
	new_coop.append(mignon)
	
	var one := Chicken.new()
	one.top_speed = 240
	one.farm = YOU
	new_coop.append(one)
	
	var two := Chicken.new()
	two.top_speed = 250
	two.farm = YOU
	new_coop.append(two)
	
	return new_coop

static func generate_enemy_list()->Array:
	var e := []
	var file := File.new()
	var err = file.open("res://Common/JSON/enemy_chickens.json", File.READ)
	if err != OK: push_error("Error opening enemy_chickens.json" + str(err))
	var content = file.get_as_text()
	var list_of_farms:Dictionary = JSON.parse(content).result
	for f_key in list_of_farms.keys():
		var farm := Farm.new()
		farm.nom = f_key
		for c_key in list_of_farms[f_key].chickens.keys():
			var chicken := Chicken.new()
			chicken.nom = c_key
			var this_chicken:Dictionary = list_of_farms[f_key].chickens[c_key]
			for k in this_chicken.keys():
				chicken.set(k,this_chicken[k])
			chicken.farm = f_key
			farm.chickens.append(chicken)
		e.append(farm)
	
	file.close()
	return e
