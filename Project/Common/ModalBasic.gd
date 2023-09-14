extends CanvasLayer

const HELP := "[center]HOW TO PLAY MIGNON ALPHA[/center]\n\n\nRESET:  New game, new chickens\nNEW CHICKEN: Random new chicken\nRACE: Pay to enter race. Tap the button to race the default racer or drag a chicken onto the button to race it\n\nStats: Tap a chicken to see it's portrait and stats. You can make it the defaut racer or put it in the breeding pen\n\nBreeding: Drag a chicken into the breeding pen in the bottom right or tap Breed from its portrait. Once 2 chickens are in the pen they will start breeding. \nOnce the egg is dropped, you will not be able to leave the farm (race) or disturb the parents until it hatches. The parents will automatically return to the regular pen after (some are slow). \n\nPens: Tap the name of a pen to move all chickens there. In the future, you will have to use your hard earned racing money to move to a bigger pen. "

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_text(text:String):
	$Border/Panel/RichTextLabel.text = text


func _on_Okay_pressed():
	queue_free()
