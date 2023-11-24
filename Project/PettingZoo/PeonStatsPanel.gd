extends Panel

onready var block : = $RichTextStats
onready var spyglass := $SpyGlass


# Called when the node enters the scene tree for the first time.
func _ready():
	block.text = "Click on a guest to see what they're saying"
	block.show()


func _on_Human_clicked(peon:Node, thoughts:Array):
	add_stylebox_override("panel", preload("res://resources/panel_stats.tres"))
	spyglass.get_parent().remove_child(spyglass)
	peon.add_child(spyglass
	)
	block.clear()
	if peon.child:
		block.add_text("Age: Child")
	else:
		block.add_text("Age: Adult")
	block.newline()
	block.newline()
	block.newline()
	for thought in thoughts:
		block.add_text("\"" + thought + "\"")
		block.newline()
	block.show()
