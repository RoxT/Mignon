extends Control

const PATH_ON_RESET := "res://Diary/Diary.tscn"
const PATH_COOP := "res://Coop.tscn"

var save_game:AllChickens

# Called when the node enters the scene tree for the first time.
func _ready():
	save_game = M.save_game
	$ResetControl/AreYouSure.hide()

func _on_Reset_pressed():
	$ResetControl/NewGame.hide()
	$ResetControl/AreYouSure.show()

func _on_YesReset_pressed():
	M.reset()
	_goto_scene("res://Diary/Diary.tscn")
	
func _goto_scene(path:String):
	var err = get_tree().change_scene(path)
	match err:
		 OK: return
		 ERR_CANT_OPEN: push_error("ERR_CANT_OPEN " + path + " path cannot be loaded into a PackedScene")
		 ERR_CANT_CREATE : push_error("ERR_CANT_CREATE " + path + " cannot be instantiated.")
	push_error("Error " + str(err) + "changing to  " + path + " ")


func _on_ToCoop_pressed():
	_goto_scene(PATH_COOP)
