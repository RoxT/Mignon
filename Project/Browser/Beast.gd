extends Control


export(String) var nom := "" setget set_nom

onready var label := $RichTextLabel


const BEASTIARY := {
	"brown" : "The most common racing chicken.",
	"white" : "A common racing chicken breed.",
	"floof" : "Soft, gorgeous feathers. Bred from [b]brown[/b] and [b]mottled[/b] chickens.",
	"mottled" : "An interesting mix. Bred from [b]brown[/b] and [b]white[/b] chickens.",
	"brown_rooster" : "A curious chicken with an unusualy large comb and wattles. Bred from [b]?????[/b] and [b]????[/b] chickens.",
	"bigger_floof" : "This racing chicken looks huge but its all feathers. Bred from [b]floof[b] and [b]white[/b] chickens.",
	"unknown" : "There must be more breeds to dicover."
	}
	
const TEXTURES := "res://chicken/breeds/%s.png"

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_text()


func set_nom(value:String):
	nom = value
	_set_text()

func _set_text():
	if label:
		label.clear()
		label.push_bold()
		label.append_bbcode(nom.capitalize())
		label.pop()
		label.newline()
		label.append_bbcode(BEASTIARY[nom])
		$Sprite.texture = load(TEXTURES % nom)
