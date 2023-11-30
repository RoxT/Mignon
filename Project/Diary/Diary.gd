extends Control

var save_game:AllChickens
onready var player:AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	save_game = M.save_game
	
	if !save_game.has_day1:
		player.play("Day1")
		save_game.has_day1 = true
		save_game.events.append(Event.new(save_game.day, "DIARY1"))
		save_game.save()
	else:
		$Contents.visible_characters = -1

func _on_ToCoop_pressed():
	player.play("fade_away")


func go_to_coop():
	var path := "res://Coop.tscn"
	var err = get_tree().change_scene(path)
	match err:
		 OK: return
		 ERR_CANT_OPEN: push_error("ERR_CANT_OPEN " + path + " path cannot be loaded into a PackedScene")
		 ERR_CANT_CREATE : push_error("ERR_CANT_CREATE " + path + " cannot be instantiated.")
	push_error("Error " + str(err) + "changing to  " + path + " ")
