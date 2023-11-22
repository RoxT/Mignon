
extends Resource
export(Array) var farms
export(Array) var races
#export(Resource) var sub_resource
#export(Array, String) var strings

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(new_farms = [], new_races = []):
	farms = new_farms
	races = new_races
