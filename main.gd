extends Node2D

# Tamaño de cada celda de la cuadrícula
const GRID_SIZE := 133
# Número de columnas y filas en el tablero
const COLUMNS := 6
const ROWS := 8
# Escena de la ficha que se va a instanciar
const TILE_SCENE := preload("res://tile.tscn")

# Nodo que representa visualmente el mazo
@onready var deck_node := Sprite2D.new()

# Posición inicial (esquina superior izquierda del tablero)
var origin := Vector2.ZERO
# Ficha actualmente seleccionada (en mano)
var selected_tile = null
# Diccionario que representa el tablero, con Vector2i como clave y el nodo Tile como valor
var board := {}

# Modo depuración para imprimir validaciones de coincidencia
var DEBUG_COMPARISON := true

# Mazo de losetas aún por robar
var deck: Array = []
# Historial de losetas usadas (opcional)
var used_tiles: Array = []

# Manos de los jugadores, indexadas por ID
var player_hands := {
	1: [],
	2: []
}

var current_player := 1
var state := "setup"

# Dibuja la cuadrícula del tablero
func _draw():
	var color = Color(1, 1, 1, 0.2)
	var thickness = 2.0
	for x in range(COLUMNS + 1):
		draw_line(origin + Vector2(x * GRID_SIZE, 0), origin + Vector2(x * GRID_SIZE, ROWS * GRID_SIZE), color, thickness)
	for y in range(ROWS + 1):
		draw_line(origin + Vector2(0, y * GRID_SIZE), origin + Vector2(COLUMNS * GRID_SIZE, y * GRID_SIZE), color, thickness)

# Maneja la entrada del jugador (teclado y ratón)
func _input(event):
	# Rotar o cancelar ficha con el teclado
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R and selected_tile:
			selected_tile.rotate_clockwise()
		elif event.keycode == KEY_ESCAPE and selected_tile:
			player_hands[current_player].append(selected_tile.original_data)
			selected_tile.queue_free()
			selected_tile = null
			show_player_hand()
	# Colocar ficha con clic izquierdo
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_tile:
			var mouse_pos = get_global_mouse_position()
			var local_pos = mouse_pos - origin
			var col = int(floor(local_pos.x / GRID_SIZE))
			var row = int(floor(local_pos.y / GRID_SIZE))
			var cell := Vector2i(col, row)

			# Validaciones antes de colocar la ficha
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

				# Posiciona y registra la ficha colocada
				selected_tile.position = origin + Vector2(cell) * GRID_SIZE + Vector2(GRID_SIZE / 2, GRID_SIZE / 2)
				selected_tile.modulate = Color(1, 1, 1, 1)
				board[cell] = selected_tile
				selected_tile = null
				show_player_hand()

# Se ejecuta al seleccionar una ficha desde la mano
func _on_tile_selected(tile_id: int):
	var tile_data = player_hands[current_player].filter(func(d): return d.id == tile_id)[0]
	player_hands[current_player].erase(tile_data)

	if selected_tile:
		selected_tile.queue_free()

	selected_tile = TILE_SCENE.instantiate()
	selected_tile.set_tile_data(tile_data)
	add_child(selected_tile)

	show_player_hand()

# Recalcula el origen de la cuadrícula cuando cambia el tamaño de la ventana
func _on_viewport_resize():
	calculate_origin()
	queue_redraw()

# Mueve la ficha seleccionada con el cursor y muestra validez de la posición
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

		# Colorea la ficha según validez de la ubicación
		if valid_cell and empty and has_neighbor and is_valid_placement(selected_tile, cell):
			selected_tile.modulate = Color(1, 1, 1, 0.8)
		else:
			selected_tile.modulate = Color(1, 0.3, 0.3, 0.8)

# Configura el juego al iniciar
func _ready():
	calculate_origin()
	setup_game()
	queue_redraw()
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_resize"))

	# Configura el área de la mano del jugador
	$HandUI.anchor_top = 1.0
	$HandUI.anchor_bottom = 1.0
	$HandUI.anchor_left = 0.0
	$HandUI.anchor_right = 1.0
	$HandUI.custom_minimum_size = Vector2(0, 150)
	$HandUI.position = Vector2(0, get_viewport().get_visible_rect().size.y - 150)

# Calcula el origen (esquina superior izquierda) para centrar el tablero
func calculate_origin():
	var screen_size = get_viewport().get_visible_rect().size
	var grid_size = Vector2(COLUMNS, ROWS) * GRID_SIZE
	origin = (screen_size - grid_size) / 2

# Roba una loseta del mazo para un jugador específico
func draw_tile(player_id: int) -> Dictionary:
	if deck.is_empty():
		print("🛑 No hay más losetas en el mazo.")
		return {}

	var tile_data = deck.pop_back()
	player_hands[player_id].append(tile_data)
	print("🎴 Jugador %d roba tile %d" % [player_id, tile_data.id])
	return tile_data

# Roba y muestra la siguiente ficha para jugar
func draw_next_tile():
	if selected_tile:
		selected_tile.queue_free()

	var tile_data = player_hands[current_player].pop_front()
	selected_tile = TILE_SCENE.instantiate()
	selected_tile.set_tile_data(tile_data)
	add_child(selected_tile)

# Verifica si se puede colocar la ficha en la celda dada
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

# Verifica si hay vecinos ortogonales (no en diagonal)
func has_orthogonal_neighbor(pos: Vector2i) -> bool:
	for offset in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if board.has(pos + offset):
			return true
	return false

# Muestra una marca roja cuando el jugador intenta colocar en una celda inválida
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

# Refresca la interfaz visual de la mano del jugador
func show_player_hand():
	var hand_ui = $HandUI
	for child in hand_ui.get_children():
		child.queue_free()

	for tile_data in player_hands[current_player]:
		var preview = preload("res://TilePreview.tscn").instantiate()
		preview.set_tile_data(tile_data)
		preview.connect("tile_selected", Callable(self, "_on_tile_selected"))
		hand_ui.add_child(preview)

# Configura el estado inicial del juego
func setup_game():
	# 1. Clona y baraja el mazo base desde TileLibrary
	deck = TileLibrary.TILE_DATA.duplicate(true)
	deck.shuffle()

	# 2. Buscar y colocar la loseta "grande" en el centro del tablero
	var center_tile_data: Dictionary = {}
	for data in deck:
		if data.get("big", false):
			center_tile_data = data
			break

	if center_tile_data.is_empty():
		push_error("❌ No se encontró una loseta 'big' en el mazo.")
		return

	deck.erase(center_tile_data)

	var center_tile = TILE_SCENE.instantiate()
	center_tile.set_tile_data(center_tile_data)
	var center_pos = Vector2i(COLUMNS / 2, ROWS / 2)
	center_tile.position = origin + Vector2(center_pos) * GRID_SIZE + Vector2(GRID_SIZE / 2, GRID_SIZE / 2)
	center_tile.modulate = Color(1, 1, 1)
	board[center_pos] = center_tile
	add_child(center_tile)

	# 3. Repartir 6 fichas a cada jugador
	for i in range(6):
		draw_tile(1)
		draw_tile(2)

	# 4. Estado inicial
	selected_tile = null
	show_player_hand()
	state = "playing"
	current_player = 1

# Crea y muestra el sprite del mazo de losetas
func show_deck_visual():
	deck_node.texture = load("res://tiles/tile_back.png")
	deck_node.position = origin + Vector2(COLUMNS * GRID_SIZE + 50, GRID_SIZE)
	deck_node.scale = Vector2(0.75, 0.75)
	deck_node.modulate = Color(1, 1, 1, 0.8)
	add_child(deck_node)
