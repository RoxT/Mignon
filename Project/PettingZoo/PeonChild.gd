extends KinematicBody2D


var target
var speed := 500
onready var line := $Line2D
onready var Floater:PackedScene = preload("res://Common/Floater.tscn")
onready var Wow:Texture = preload("res://PettingZoo/speech_bubble_WOW.png")
var thoughts := []
onready var child:bool = $ChickenSearch/CollisionShape2D.shape.radius < 50

const PET := "I pet the chicken!"
const SOFT := "So soft..."
const HERE := "Here birdy birdy"
const CHILD_THOUGHTS := [PET, SOFT, HERE]

const FAST := "So fast..."
const SEE := "Did you see that!?"
const ADULT_THOGUHTS := [FAST, SEE]
const BREED := "Is that a rare breed?"
const RARE := ["floof", "bigger floof"]

signal clicked(child, thoughts)

# Called when the node enters the scene tree for the first time.
func _ready():
#	add_to_group("Human")
	pass
		

func _on_ChickenSearch_area_entered(area:Area2D):
	var chicken := area.get_parent()
	if !chicken.has_method("random_meander"):return
	var wow = Floater.instance()
	wow.texture = Wow
	$Sprite.look_at(area.global_position)
	if child:
		if chicken.meander < 200:
			add_child(wow)
			thoughts.append(CHILD_THOUGHTS[randi()%CHILD_THOUGHTS.size()])
	else:
		var thought := ""
		if chicken.meander > 150:
			add_child(wow)
			thought = ADULT_THOGUHTS[randi()%ADULT_THOGUHTS.size()]
			if RARE.find(chicken.stats.breed) >= 0:
				if randf() > 0.5:
					thought = BREED
			thoughts.append(thought)

func _on_Peon_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		emit_signal("clicked", child, thoughts)
