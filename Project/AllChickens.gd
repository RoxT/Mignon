extends Resource
class_name AllChickens
export(Array, Resource) var all setget , get_all
export(Resource) var racer setget set_racer
var racer_chicken:Chicken

const PATH := "user://chickens.tres"

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(new_all = []):
	all = new_all

static func exists()->bool:
	return ResourceLoader.exists(PATH)

func get_all()->Array:
	return all.duplicate()

func save():
	ResourceSaver.save(PATH, self)
	
func add_chicken_stats(value:Chicken):
	assert(value != null)
	value.index = all.size()
	all.append(value)
	save()
	
func reset():
	all = []
	save()

func set_racer(value:Resource):
	racer_chicken = value as Chicken
	
func winner(index:int):
	all[index].wins += 1
	save()
