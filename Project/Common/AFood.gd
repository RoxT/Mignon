extends HBoxContainer

enum TYPES{
	BEST, GOOD, BASIC
}
export(TYPES) var food_type setget set_food_type
export(int) var count setget set_count

onready var atlas_tex:AtlasTexture = $TextureRect.texture
const SIZE := Vector2(32, 32)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_food_type(food_type)
	set_count(count)
	
func set_count(value:int):
	count = value
	if $Count:
		$Count.text = str(count)
		visible = count > 0

func set_food_type(value:int):
	food_type = value
	if atlas_tex:
		match value:
			TYPES.BEST:
				atlas_tex.region = Rect2(Vector2(0, 0), SIZE)
			TYPES.GOOD:
				atlas_tex.region = Rect2(Vector2(32, 0), SIZE)
			TYPES.BASIC:
				atlas_tex.region = Rect2(Vector2(64, 0), SIZE)
