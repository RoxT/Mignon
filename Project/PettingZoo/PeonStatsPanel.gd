extends Panel

onready var block : = $RichTextStats


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Human_clicked(child:bool, thoughts:Array):
	block.clear()
	if child:
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
