extends ReferenceRect


const LENGTH := 1078
const END := 1357

	
func get_zoom()->Vector2:
	var pen_length := get_rect().size.x
	var difference := pen_length/LENGTH
	return Vector2(difference, difference)

func get_projected_length():
	pass

