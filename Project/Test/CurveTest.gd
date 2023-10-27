extends Node2D


export(Curve) var curve:Curve
export var runs := 200

# Called when the node enters the scene tree for the first time.
func _ready():
	for _i in range(runs):
		var point := curve.interpolate(randf())
		print(str(round(point)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
