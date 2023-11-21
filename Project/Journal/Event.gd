extends Resource

class_name Event
#export(Resource) var sub_resource
#export(Array, String) var strings
export(int) var day
export(String) var key
export(Array) var args

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(new_day:=-1, new_key:="UNKNOWN", new_args := []):
	day = new_day
	key = new_key
	args = new_args
