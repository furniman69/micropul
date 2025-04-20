extends TextureButton

# Identificador del tile representado
@export var tile_id: int = -1

# Señal emitida al hacer clic en el botón (para seleccionar ficha)
signal tile_selected(tile_id: int)

# Asigna el gráfico y comportamiento del botón
func set_tile_data(data: Dictionary):
	tile_id = data.id
	var path := "res://tiles/tile_%02d.png" % tile_id

	# Cargar la textura del botón si está disponible
	if ResourceLoader.exists(path):
		texture_normal = load(path)
	else:
		print("⚠️ No se encontró la imagen del tile ", tile_id)

	# Tamaño mínimo para mantener proporción y legibilidad
	custom_minimum_size = Vector2(100, 133)

# Se conecta al evento de presionado para emitir la señal
func _ready():
	connect("pressed", Callable(self, "_on_pressed"))

# Informa que se seleccionó esta ficha
func _on_pressed():
	emit_signal("tile_selected", tile_id)
