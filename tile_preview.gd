extends TextureButton

@export var tile_id: int = -1
signal tile_selected(tile_id: int)

func set_tile_data(data: Dictionary):
	tile_id = data.id
	var path := "res://tiles/tile_%02d.png" % tile_id
	if ResourceLoader.exists(path):
		texture_normal = load(path)
	else:
		print("⚠️ No se encontró la imagen del tile ", tile_id)

	custom_minimum_size = Vector2(100, 133)

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	emit_signal("tile_selected", tile_id)
