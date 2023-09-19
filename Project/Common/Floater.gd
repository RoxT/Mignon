extends Node2D


export(Texture) var texture setget set_texture

func _ready():
	if texture:
		$Sprite.texture = texture

func set_texture(value:Texture):
	texture = value
	if value and $Sprite:
		$Sprite.texture = texture
