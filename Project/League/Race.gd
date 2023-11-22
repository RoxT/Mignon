
extends Resource
export(String) var winner_name
export(String) var winner_farm
export(Array, String) var competitors
export(int) var day

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(new_winner_name = "", new_winner_farm = "", new_competitors = []):
	winner_name = new_winner_name
	competitors = new_competitors
	winner_farm = new_winner_farm
