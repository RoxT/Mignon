extends Resource
class_name AllChickens
export(Array, Resource) var all:Array setget , get_all
export(Resource) var racer setget set_racer
export(Resource) var temp_racer setget set_temp_racer
export(int) var money
export(int) var deaths
export(String) var pen

const PATH := "user://chickens.tres"

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(new_all = [], new_racer=null, new_money := 50, new_deaths := 0, new_temp_racer=null, new_pen="Starter"):
	all = new_all
	racer = new_racer
	money = new_money
	deaths = new_deaths
	temp_racer = new_temp_racer
	pen = new_pen
		
func pass_day():
	for c in all:
		c.fatigue = max(c.fatigue-1, 0)
		c.age += 1
	save()

static func exists()->bool:
	return ResourceLoader.exists(PATH)

func get_all()->Array:
	return all
	
static func do_mating(a:Chicken, b:Chicken)->Chicken:
	return Chicken.new(one_of_two(a, b, "top_speed"), Chicken.random_name(), 0, one_of_two(a, b, "colour"), one_of_two(a, b, "white"), one_of_two(a, b, "farm"), 2, one_of_two(a, b, "breed"))

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
