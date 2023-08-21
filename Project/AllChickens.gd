extends Resource
class_name AllChickens
export(Array, Resource) var all setget , get_all
export(Resource) var racer setget set_racer
export(int) var money

const PATH := "user://chickens.tres"

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(new_all = [], new_racer=null, new_money := 50):
	all = new_all
	racer = new_racer
	money = new_money
		
func pass_day():
	for c in all:
		c.fatigue = max(c.fatigue-1, 0)
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
	
func add_chicken_stats(value:Chicken):
	assert(value != null)
	all.append(value)
	save()

func set_racer(value:Resource):
	racer = value as Chicken
	save()
