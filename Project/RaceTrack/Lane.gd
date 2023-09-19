extends Node2D


onready var bar := $HSeparator

var stats:Chicken

# Called when the node enters the scene tree for the first time.
func _ready():
	var window_width := Vector2(ProjectSettings.get_setting("display/window/size/width")-2,0)
	bar.rect_min_size = window_width
	if not stats:
		stats = Chicken.new()
	$Name.text = stats.nom
	$Farm.text = "Farm: " + stats.farm
	$Racer.stats = stats
	$Wins.text = "Wins " + str(stats.wins)
	
func update_wins():
	$Wins.text = "Wins " + str(stats.wins)
	
func did_win()->bool:
	return $Racer/Trophy.visible


func death():
	$Racer.animation = "death"
