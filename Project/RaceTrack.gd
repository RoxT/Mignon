extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	var racers := get_tree().get_nodes_in_group("racer")
	var track:=1
	for r in racers:
		# Chickens
		r.track = track
		var label := Label.new()
		
		# UI Decorations
		var separation = r.TRACK_SEPARATION
		label.text = r.nom
		label.rect_position = Vector2(900, track * separation - separation/4)
		add_child(label)
		var bar := HSeparator.new()
		add_child(bar)
		bar.rect_position.y = track * separation - separation/3
		bar.rect_min_size = Vector2(get_viewport_rect().size.x,0)
		
		track += 1


func _on_ToCoop_pressed():
	var err := get_tree().change_scene("res://Coop.tscn")
	if err != OK:
		push_error("Error switching scenes: " + str(err))
		assert(false)
