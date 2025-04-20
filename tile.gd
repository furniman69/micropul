
extends Node2D

# Identificador único de la ficha
var tile_id: int = -1
# Diccionario de micropuls (colores o tipos en posiciones específicas)
var micropuls: Dictionary = {}
# Diccionario de catalizadores (otras propiedades, opcional)
var catalysts: Dictionary = {}
# Datos originales sin rotación
var original_data: Dictionary = {}
# Estado de rotación (0 a 3, en pasos de 90 grados)
var rotation_state: int = 0

func _ready():
	print("✅ Tile ", tile_id, " cargado con micropuls: ", micropuls)

# Establece los datos de la ficha desde un diccionario externo
func set_tile_data(data: Dictionary):
	tile_id = data.id
	original_data = data
	remap_positions()

	# Carga y asigna la imagen del tile si existe
	if has_node("Sprite2D"):
		var sprite := $Sprite2D
		var path := "res://tiles/tile_%02d.png" % tile_id
		if ResourceLoader.exists(path):
			sprite.texture = load(path)
		else:
			print("⚠️ No se encontró imagen para tile ", tile_id, ": ", path)

# Rota la ficha 90° en sentido horario y actualiza sus datos de posición
func rotate_clockwise():
	rotation_state = (rotation_state + 1) % 4
	rotation_degrees = rotation_state * 90
	remap_positions()

# Reasigna las posiciones de micropuls y catalizadores tras la rotación
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

# Aplica rotación a una celda individual según el estado de rotación actual
func rotate_cell(pos: Vector2i) -> Vector2i:
	match rotation_state:
		0: return pos
		1: return Vector2i(1 - pos.y, pos.x)
		2: return Vector2i(1 - pos.x, 1 - pos.y)
		3: return Vector2i(pos.y, 1 - pos.x)
	return pos
