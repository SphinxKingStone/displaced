extends TextureButton


export(String) var hero_name
export(Texture) var portrait

func _ready():
	$TextureRect.texture = portrait
	$Label.text = tr(hero_name)
