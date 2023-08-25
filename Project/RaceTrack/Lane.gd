extends Node2D


onready var bar := $HSeparator

var stats:Chicken

# Called when the node enters the scene tree for the first time.
func _ready():
	bar.rect_min_size = Vector2(ProjectSettings.get_setting("display/window/size/width")-2,0)
	if not stats:
		stats = Chicken.new()
	$Name.text = stats.nom
	$Farm.text = "Farm: " + stats.farm
	$Racer.stats = stats
	
func did_win()->bool:
	return $Racer/Trophy.visible


func death():
	$Racer.animation = "death"
