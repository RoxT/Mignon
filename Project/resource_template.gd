# meta-name: Resource Template
# meta-default: true
extends Resource
export(int) var health
#export(Resource) var sub_resource
#export(Array, String) var strings

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(new_health = 0):
	health = new_health
