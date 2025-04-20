extends Node2D

# Identificador único de la ficha
var tile_id: int = -1
# Diccionario de micropuls: datos tipo "color" asignados a coordenadas 2D
var micropuls: Dictionary = {}
# Diccionario de catalizadores: efectos adicionales como "+", ".", "*"
var catalysts: Dictionary = {}
# Datos originales sin modificar (sin rotar)
var original_data: Dictionary = {}
# Rotación actual de la ficha (0 a 3 → 0°, 90°, 180°, 270°)
var rotation_state: int = 0

# Imprime datos al cargar la ficha
func _ready():
	print("✅ Tile ", tile_id, " cargado con micropuls: ", micropuls)

# Asigna los datos del tile desde un diccionario, y prepara su sprite
func set_tile_data(data: Dictionary):
	tile_id = data.id
	original_data = data
	remap_positions()

	# Carga el sprite correspondiente al tile, si está disponible
	if has_node("Sprite2D"):
		var sprite := $Sprite2D
		print("🎨 Sprite tiene textura: ", sprite.texture)
		var path := "res://tiles/tile_%02d.png" % tile_id
		if ResourceLoader.exists(path):
			sprite.texture = load(path)
		else:
			print("⚠️ No se encontró imagen para tile ", tile_id, ": ", path)

# Gira la ficha en sentido horario y actualiza su representación
func rotate_clockwise():
	rotation_state = (rotation_state + 1) % 4
	rotation_degrees = rotation_state * 90
	remap_positions()

# Reasigna los datos de micropuls y catalysts después de rotar la ficha
func remap_positions():
	micropuls.clear()
	catalysts.clear()

	for pos in original_data.micropuls:
		var new_pos = rotate_cell(pos)
		micropuls[new_pos] = original_data.micropuls[pos]

	for pos in original_data.get("catalysts", {}):
		var new_pos = rotate_cell(pos)
		catalysts[new_pos] = original_data.catalysts[pos]

	print("🧬 Remapped micropuls: ", micropuls)

# Aplica la rotación a una celda individual según el estado de rotación
func rotate_cell(pos: Vector2i) -> Vector2i:
	match rotation_state:
		0: return pos  # 0°: sin cambio
		1: return Vector2i(1 - pos.y, pos.x)  # 90° CW
		2: return Vector2i(1 - pos.x, 1 - pos.y)  # 180°
		3: return Vector2i(pos.y, 1 - pos.x)  # 270°
	return pos
