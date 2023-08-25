extends CanvasLayer

onready var label := $Border/Panel/RichTextLabel

const bb_lost := "[center]You have lost all your chickens.\n\nStarting new game."

const bb_death := "[center]%s has died of exhaustion!\nYou have been fined $100\n\nRIP. %s"
const epitaph_poor := "She was never much of a runner."
const epitaph_good := "She was a decent chicken."
const epitaph_great := "She was a runner for the ages."

export(String, "Death", "Lost") var reason setget set_reason
export(String) var nom setget set_nom
export(String, "poor", "good", "great", "NA") var epitaph setget set_epitaph

var empty := true

# Called when the node enters the scene tree for the first time.
func _ready():
	do_label()

func _on_Okay_pressed():
	queue_free()

func do_label():
	if label and empty and !reason.empty():
		match reason:
			"Death":
				var about := ""
				if !epitaph.empty() and !nom.empty():
					match epitaph:
						"poor": about = epitaph_poor
						"good": about = epitaph_good
						"great": about = epitaph_great
					label.bbcode_text = bb_death % [nom, about]
					empty = false
			"Lost":
				label.bbcode_text = bb_lost
				empty = false
		
	
func set_nom(value:String):
	nom = value
	do_label()

func set_reason(value:String):
	reason = value
	do_label()
		
func set_epitaph(value:String):
	epitaph = value
	do_label()
