extends Control

var save_game:AllChickens
onready var player:AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	save_game = M.save_game
#	get_tree().call_group("content", "hide")
	if player.connect("animation_finished", self, "_on_animation_finished") != OK:
		push_error("Error connecting singal")
	$Day.text = "Day " + str(save_game.day)
	$Day.hide()
	
	if save_game.find_event("BRONZE") > 0:
		player.play("Bronze")
		$Bronze.show()
	else:
		$ToCoop.show()
		player.play("Day1")
		save_game.events.append(Event.new(save_game.day, "DIARY1"))
		$Day1.show()
	
	save_game.show_diary = false
		
func _on_animation_finished(_anim_name: String):
	$ToCoop.show()
	if $Dots:
		$Dots.queue_free()

func _on_ToCoop_pressed():
	player.play("fade_away")


func go_to_coop():
	save_game.save()
	var path := "res://Coop.tscn"
	var err = get_tree().change_scene(path)
	match err:
		 OK: return
		 ERR_CANT_OPEN: push_error("ERR_CANT_OPEN " + path + " path cannot be loaded into a PackedScene")
		 ERR_CANT_CREATE : push_error("ERR_CANT_CREATE " + path + " cannot be instantiated.")
	push_error("Error " + str(err) + "changing to  " + path + " ")


func _on_Day_Timer_timeout():
	$Day.show()
