extends CanvasLayer

onready var label := $Border/Panel/RichTextLabel

const HELP := "[center]HOW TO PLAY MIGNON ALPHA[/center]\n\nRESET:  New game, new chickens\nNEW CHICKEN: Random new chicken\nRACE: Pay to enter race. Tap the button to race the default racer or drag a chicken onto the button to race it\n\nStats: Tap a chicken to see it's portrait and stats. You can make it the defaut racer or put it in the breeding pen\n\nBreeding: Drag a chicken into the breeding pen in the bottom right or tap Breed from its portrait. Once 2 chickens are in the pen they will start breeding. \nOnce the egg is dropped, you will not be able to leave the farm (race) or disturb the parents until it hatches. The parents will automatically return to the regular pen after (some are slow). \n\nPens: Upgrade your pen in the shop. You can see chickens easier if you have a lot of them but food will cost more.\n\nFood: Your chickens must eat one bundle of food every day or they will not recover fatigue. You can find it in the shop. You can se e how much you have in the lower right corner of the screen."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_text(text:String):
	label.clear()
	label.bbcode_text = text


func _on_Okay_pressed():
	queue_free()
