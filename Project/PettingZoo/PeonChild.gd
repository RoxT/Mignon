extends KinematicBody2D


var target
var speed := 500
onready var line := $Line2D
onready var Floater:PackedScene = preload("res://Common/Floater.tscn")
onready var Wow:Texture = preload("res://PettingZoo/speech_bubble_WOW.png")
var thoughts := []
onready var child:bool = $ChickenSearch/CollisionShape2D.shape.radius < 50
var rare_breeds:Array

const PET := "I pet the chicken!"
const SOFT := "So soft..."
const HERE := "Here birdy birdy"
const CHILD_THOUGHTS := [PET, SOFT, HERE]

const TIRED := "That chicken looks tired"

const FAST := "So fast..."
const SEE := "Did you see that!?"
const ADULT_THOGUHTS := [FAST, SEE]
const BREED_THOUGHTS := ["Is that a rare breed?", "What is that?", "Is that a duck?"]

signal clicked(child, thoughts)

# Called when the node enters the scene tree for the first time.
func _ready():
	rare_breeds = M.get_uncommon_list()
		

func _on_ChickenSearch_area_entered(area:Area2D):
	var chicken := area.get_parent()
	if !chicken.has_method("random_meander"):return
	var wow = Floater.instance()
	wow.texture = Wow
	$Sprite.look_at(area.global_position)
	
	if thoughts.size() >= 10: return
	if child:
		if chicken.stats.fatigue >= 3:
			thoughts.append(TIRED)
		elif chicken.meander < 200:
			add_child(wow)
			thoughts.append(CHILD_THOUGHTS[randi()%CHILD_THOUGHTS.size()])
	else:
		var thought := ""
		if chicken.stats.fatigue >= 3:
			thoughts.append(TIRED)
		elif chicken.meander > 150:
			add_child(wow)
			thought = ADULT_THOGUHTS[randi()%ADULT_THOGUHTS.size()]
			if chicken.stats.breed in rare_breeds and randf() < 0.2:
				thought = rare_breeds[randi()%rare_breeds.size()]
			thoughts.append(thought)

func _on_Peon_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		emit_signal("clicked", child, thoughts)
