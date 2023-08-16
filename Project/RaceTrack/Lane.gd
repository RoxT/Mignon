extends Node2D


onready var bar := $HSeparator

export var nom:String setget set_nom
export var farm:String setget set_farm

var chicken:Chicken setget set_chicken

# Called when the node enters the scene tree for the first time.
func _ready():
	bar.rect_min_size = Vector2(get_viewport_rect().size.x-2,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_chicken(value:Chicken):
	chicken = value
	set_nom(chicken.nom)
	set_farm(chicken.farm)

func set_nom(value:String):
	nom = value
	$Name.text = value

func set_farm(value:String):
	farm = value
	$Farm.text = "Farm: " + value
