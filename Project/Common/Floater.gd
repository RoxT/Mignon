extends Node2D


export(Texture) var texture setget set_texture

func _ready():
	$Sprite.texture = texture

func set_texture(value:Texture):
	texture = value
	if value and $Sprite:
		$Sprite.texture = texture
