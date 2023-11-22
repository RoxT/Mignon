extends Resource
class_name Farm
export(int) var nom
export(Array, Resource) var chickens:Array setget , get_enemies
#export(Resource) var sub_resource
#export(Array, String) var strings

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(new_nom = "FARM", new_chickens=[]):
	nom = new_nom
	chickens = new_chickens


func get_enemies()->Array:
	return chickens

func get_random()->Chicken:
	return chickens[randi() % chickens.size()]
