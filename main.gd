extends Node2D

# Tamaño de cada celda de la cuadrícula
const GRID_SIZE := 133
# Número de columnas y filas en el tablero
const COLUMNS := 6
const ROWS := 8
# Escena de la ficha que se va a instanciar
const TILE_SCENE := preload("res://tile.tscn")

# Posición inicial (esquina superior izquierda del tablero)
var origin := Vector2.ZERO
# Ficha actualmente seleccionada (en mano)
var selected_tile = null
# Diccionario que representa el tablero, con Vector2i como clave
var board := {}  # key: Vector2i, value: Tile
# Habilita impresión de mensajes de depuración para validación
var DEBUG_COMPARISON := true

func _ready():
	calculate_origin()
	spawn_new_hand_tile()
	queue_redraw()
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_resize"))

# Centra el tablero en la pantalla
func calculate_origin():
	var screen_size = get_viewport().get_visible_rect().size
	var grid_size = Vector2(COLUMNS, ROWS) * GRID_SIZE
	origin = (screen_size - grid_size) / 2

# Recalcula el origen si la ventana cambia de tamaño
func _on_viewport_resize():
	calculate_origin()
	queue_redraw()

# Dibuja la cuadrícula del tablero
func _draw():
	var color = Color(1, 1, 1, 0.2)
	var thickness = 2.0
	for x in range(COLUMNS + 1):
		draw_line(origin + Vector2(x * GRID_SIZE, 0), origin + Vector2(x * GRID_SIZE, ROWS * GRID_SIZE), color, thickness)
	for y in range(ROWS + 1):
		draw_line(origin + Vector2(0, y * GRID_SIZE), origin + Vector2(COLUMNS * GRID_SIZE, y * GRID_SIZE), color, thickness)

# Crea una nueva ficha aleatoria y la pone en la mano
func spawn_new_hand_tile():
	selected_tile = TILE_SCENE.instantiate()
	var tile_data = TileLibrary.TILE_DATA[randi() % TileLibrary.TILE_DATA.size()]
	print("🧱 Spawning tile data: ", tile_data)
	selected_tile.set_tile_data(tile_data)
	selected_tile.modulate = Color(1.2, 1.2, 0.7, 0.9)  # color inicial con transparencia
	selected_tile.position = Vector2.ZERO
	add_child(selected_tile)

# Mueve la ficha en mano con el mouse y evalúa validez de colocación
func _process(_delta):
	if selected_tile:
		var mouse_pos = get_global_mouse_position()
		var local_pos = mouse_pos - origin
		var col = int(floor(local_pos.x / GRID_SIZE))
		var row = int(floor(local_pos.y / GRID_SIZE))
		var cell := Vector2i(col, row)

		selected_tile.position = origin + Vector2(cell) * GRID_SIZE + Vector2(GRID_SIZE / 2, GRID_SIZE / 2)

		var valid_cell := col >= 0 and col < COLUMNS and row >= 0 and row < ROWS
		var empty := not board.has(cell)
		var has_neighbor := has_orthogonal_neighbor(cell) or board.is_empty()

		# Cambia el color según si la posición es válida o no
		if valid_cell and empty and has_neighbor and is_valid_placement(selected_tile, cell):
			selected_tile.modulate = Color(1, 1, 1, 0.8)
		else:
			selected_tile.modulate = Color(1, 0.3, 0.3, 0.8)

# Maneja input: rotar o colocar ficha
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		if selected_tile:
			selected_tile.rotate_clockwise()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_tile:
			var mouse_pos = get_global_mouse_position()
			var local_pos = mouse_pos - origin
			var col = int(floor(local_pos.x / GRID_SIZE))
			var row = int(floor(local_pos.y / GRID_SIZE))
			var cell := Vector2i(col, row)

			if col >= 0 and col < COLUMNS and row >= 0 and row < ROWS:
				if board.has(cell):
					show_invalid_click(cell)
					return
				if not has_orthogonal_neighbor(cell) and not board.is_empty():
					show_invalid_click(cell)
					return
				if not is_valid_placement(selected_tile, cell):
					show_invalid_click(cell)
					return

				# Coloca la ficha en el tablero
				selected_tile.position = origin + Vector2(cell) * GRID_SIZE + Vector2(GRID_SIZE / 2, GRID_SIZE / 2)
				selected_tile.modulate = Color(1, 1, 1, 1)
				board[cell] = selected_tile
				selected_tile = null
				spawn_new_hand_tile()

# Verifica si hay fichas vecinas ortogonales
func has_orthogonal_neighbor(pos: Vector2i) -> bool:
	for offset in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if board.has(pos + offset):
			return true
	return false

# Muestra una animación roja cuando la colocación es inválida
func show_invalid_click(cell: Vector2i):
	var marker := ColorRect.new()
	marker.color = Color(1, 0, 0, 0.3)
	marker.size = Vector2(GRID_SIZE, GRID_SIZE)
	marker.position = origin + Vector2(cell) * GRID_SIZE
	marker.z_index = 100
	add_child(marker)
	var tween := create_tween()
	tween.tween_property(marker, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(Callable(marker, "queue_free"))

# Valida si se puede colocar la ficha en la celda dada
func is_valid_placement(tile, grid_pos: Vector2i) -> bool:
	if board.is_empty():
		return true

	var neighbor_dirs: Dictionary = {
		Vector2i.UP: [[Vector2i(0, 1), Vector2i(0, 0)], [Vector2i(1, 1), Vector2i(1, 0)]],
		Vector2i.DOWN: [[Vector2i(0, 0), Vector2i(0, 1)], [Vector2i(1, 0), Vector2i(1, 1)]],
		Vector2i.LEFT: [[Vector2i(1, 0), Vector2i(0, 0)], [Vector2i(1, 1), Vector2i(0, 1)]],
		Vector2i.RIGHT: [[Vector2i(0, 0), Vector2i(1, 0)], [Vector2i(0, 1), Vector2i(1, 1)]]
	}

	for dir: Vector2i in neighbor_dirs:
		var neighbor_pos: Vector2i = grid_pos + dir
		if board.has(neighbor_pos):
			var neighbor_tile = board[neighbor_pos]
			for pair: Array in neighbor_dirs[dir]:
				var a_pos: Vector2i = pair[0]
				var b_pos: Vector2i = pair[1]
				if neighbor_tile.micropuls.has(a_pos) and tile.micropuls.has(b_pos):
					var a_color: String = neighbor_tile.micropuls[a_pos]
					var b_color: String = tile.micropuls[b_pos]
					if a_color != b_color:
						if DEBUG_COMPARISON:
							print("❌ FALLIDA: Tile ", neighbor_tile.tile_id, " [", a_pos, " = ", a_color, "] vs Tile ", tile.tile_id, " [", b_pos, " = ", b_color, "] dir ", dir)
						return false
					elif DEBUG_COMPARISON:
						print("✔️ VÁLIDA: Tile ", neighbor_tile.tile_id, " [", a_pos, " = ", a_color, "] vs Tile ", tile.tile_id, " [", b_pos, " = ", b_color, "] dir ", dir)
	return true
