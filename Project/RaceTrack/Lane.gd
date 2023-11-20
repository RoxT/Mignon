extends Node2D


onready var bar := $HSeparator
onready var rect:Rect2 = $TextureRect.get_rect()

var stats:Chicken

# Called when the node enters the scene tree for the first time.
func _ready():
	var window_width:float = ProjectSettings.get_setting("display/window/size/width")
	position.x = (window_width - rect.size.x)/2
	var finish_line:float = rect.end.x-64
	bar.rect_min_size.x = rect.end.x-2
	if not stats:
		push_warning("Made a new chicken to race")
		stats = Chicken.new()
	$Name.text = stats.nom
	$Farm.text = "Farm: " + stats.farm
	$Racer.stats = stats
	$Racer.finish_line = finish_line
	$Wins.text = "Wins " + str(stats.wins)
	
func update_wins():
	$Wins.text = "Wins " + str(stats.wins)
	
func did_win()->bool:
	return $Racer/Trophy.visible


func death():
	$Racer.animation = "death"
