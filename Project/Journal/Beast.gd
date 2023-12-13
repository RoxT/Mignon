extends Control


export(String) var breed := "" setget set_breed

onready var label := $RichTextLabel

const BEASTIARY := {
	M.LEGHORN_BROWN : "The most common racing chicken.",
	M.WHITE_CORNISH_HEN : "A common racing chicken breed.",
	M.RUSSIAN_ORLOFF : "Soft, gorgeous feathers.",
	M.SUSSEX : "An interesting mix with a mottled pattern.",
	M.BROWN_ROOSTER : "It's a boy! A curious chicken with an unusualy large comb and wattles.",
	M.SILKIE : "This racing chicken looks huge but its all feathers.",
	M.BLACK_ONYX : "There's a green shimmer when the light hits this chicken.",
	"unknown" : "There must be more breeds to discover."
	}
	
const TEXTURES := "res://chicken/breeds/%s.png"

const BRED_FROM := " Bred from [b]%s[/b] and [b]%s[/b] chickens."



# Called when the node enters the scene tree for the first time.
func _ready():
	_set_text()


func set_breed(value:String):
	breed = value
	_set_text()

func _set_text():
	if label:
		label.clear()
		label.push_bold()
		label.append_bbcode(breed.capitalize())
		label.pop()
		label.newline()
		label.append_bbcode(BEASTIARY[breed])
		var parents = M.capitalized_parents(breed)
		if parents.size() == 2:
			label.append_bbcode(BRED_FROM % parents)
		$Sprite.texture = load(TEXTURES % breed)
