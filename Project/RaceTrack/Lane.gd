extends Node2D


onready var bar := $HSeparator

var stats:Chicken

# Called when the node enters the scene tree for the first time.
func _ready():
	bar.rect_min_size = Vector2(get_viewport_rect().size.x-2,0)
	if not stats:
		stats = Chicken.new()
	$Name.text = stats.nom
	$Farm.text = "Farm: " + stats.farm
	$Racer.stats = stats

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
