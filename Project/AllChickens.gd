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
	
func get_by_index(index:int)->Chicken:
	return all[index]

func save():
	var err := ResourceSaver.save(PATH, self)
	if err != OK: push_error("Error saving! " + str(err))
	
func add_chicken_stats(value:Chicken):
	assert(value != null)
	value.index = all.size()
	all.append(value)
	save()

func set_racer(value:Resource):
	racer = value as Chicken
	save()
	
func winner(index:int):
	all[index].wins += 1
	save()
