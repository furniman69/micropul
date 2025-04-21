extends Node2D

# Tamaño de cada celda de la cuadrícula
const GRID_SIZE := 133
# Número de columnas y filas en el tablero
const COLUMNS := 6
const ROWS := 8
# Escena de la ficha que se va a instanciar
const TILE_SCENE := preload("res://tile.tscn")

@onready var deck_node := Sprite2D.new()

# Posición inicial (esquina superior izquierda del tablero)
var origin := Vector2.ZERO
# Ficha actualmente setileleccionada (en mano)
var selected_tile = null
# Diccionario que representa el tablero, con Vector2i como clave
var board := {}  # key: Vector2i, value: Tile
# Habilita impresión de mensajes de depuración para validación
var DEBUG_COMPARISON := true

var deck: Array = []  # losetas aún por robar
var used_tiles: Array = []  # historial, si querés llevarlo
var player_hands := {
	1: [],
	2: []
}
var current_player := 1
var state := "setup"


# Dibuja la cuadrícula del tablero
func _draw():
	if board.is_empty():
		return

	var all_positions = board.keys()
	var min_x = all_positions.map(func(p): return p.x).min()
	var max_x = all_positions.map(func(p): return p.x).max()
	var min_y = all_positions.map(func(p): return p.y).min()
	var max_y = all_positions.map(func(p): return p.y).max()

	var color = Color(1, 1, 1, 0.2)
	var thickness = 2.0
	for x in range(min_x, max_x + 2):
		draw_line(origin + Vector2((x - min_x) * GRID_SIZE, 0), origin + Vector2((x - min_x) * GRID_SIZE, (max_y - min_y + 1) * GRID_SIZE), color, thickness)
	for y in range(min_y, max_y + 2):
		draw_line(origin + Vector2(0, (y - min_y) * GRID_SIZE), origin + Vector2((max_x - min_x + 1) * GRID_SIZE, (y - min_y) * GRID_SIZE), color, thickness)

		
# Maneja input: rotar o colocar ficha
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R and selected_tile:
			selected_tile.rotate_clockwise()
		elif event.keycode == KEY_ESCAPE and selected_tile:
			player_hands[current_player].append(selected_tile.original_data)
			selected_tile.queue_free()
			selected_tile = null
			show_player_hand()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_tile:
			var cell = to_grid_pos(get_global_mouse_position())

			if board.has(cell):
				show_invalid_click(cell)
				return
			if not has_orthogonal_neighbor(cell) and not board.is_empty():
				show_invalid_click(cell)
				return
			if not is_valid_placement(selected_tile, cell):
				show_invalid_click(cell)
				return

			selected_tile.position = to_screen_pos(cell)
			selected_tile.modulate = Color(1, 1, 1, 1)
			board[cell] = selected_tile

			# --- CATALIZADORES ---
			var has_plus := false
			var bonus_draws := 0

			for pos in selected_tile.catalysts:
				match selected_tile.catalysts[pos]:
					"+":
						has_plus = true
					".":
						bonus_draws += 1
					"*":
						bonus_draws += 2

			for i in range(bonus_draws):
				draw_tile(current_player)

			selected_tile = null
			show_player_hand()

			if not has_plus:
				end_turn()




func _on_tile_selected(tile_id: int):
	var tile_data = player_hands[current_player].filter(func(d): return d.id == tile_id)[0]
	player_hands[current_player].erase(tile_data)

	if selected_tile:
		selected_tile.queue_free()

	selected_tile = TILE_SCENE.instantiate()
	selected_tile.set_tile_data(tile_data)
	add_child(selected_tile)

	show_player_hand()
	
# Recalcula el origen si la ventana cambia de tamaño
func _on_viewport_resize():
	calculate_origin()
	queue_redraw()
	
# Mueve la ficha en mano con el mouse y evalúa validez de colocación
func _process(_delta):
	if selected_tile:
		var cell = to_grid_pos(get_global_mouse_position())
		selected_tile.position = to_screen_pos(cell)

		var col = cell.x
		var row = cell.y
		var valid_cell := true  # ahora sin límite de columnas o filas
		var empty := not board.has(cell)
		var has_neighbor := has_orthogonal_neighbor(cell) or board.is_empty()

		if valid_cell and empty and has_neighbor and is_valid_placement(selected_tile, cell):
			selected_tile.modulate = Color(1, 1, 1, 0.8)
		else:
			selected_tile.modulate = Color(1, 0.3, 0.3, 0.8)
	
func _ready():
	calculate_origin()
	setup_game()  # 👈 ¡esto debe estar!
	queue_redraw()
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_resize"))
	$HandUI.anchor_top = 1.0
	$HandUI.anchor_bottom = 1.0
	$HandUI.anchor_left = 0.0
	$HandUI.anchor_right = 1.0
	$HandUI.custom_minimum_size = Vector2(0, 150)
	$HandUI.position = Vector2(0, get_viewport().get_visible_rect().size.y - 150)
	
# Centra el tablero en la pantalla
func calculate_origin():
	var screen_size = get_viewport().get_visible_rect().size
	var tile_count = board.size()

	if tile_count == 0:
		origin = screen_size / 2
		return

	var all_positions = board.keys()
	var min_x = all_positions.map(func(p): return p.x).min()
	var max_x = all_positions.map(func(p): return p.x).max()
	var min_y = all_positions.map(func(p): return p.y).min()
	var max_y = all_positions.map(func(p): return p.y).max()

	var grid_width = max_x - min_x + 1
	var grid_height = max_y - min_y + 1
	var grid_px = Vector2(grid_width, grid_height) * GRID_SIZE

	origin = (screen_size - grid_px) / 2 - Vector2(min_x, min_y) * GRID_SIZE


func draw_tile(player_id: int) -> Dictionary:
	if deck.is_empty():
		print("🛑 No hay más losetas en el mazo.")
		return {}

	var tile_data = deck.pop_back()
	player_hands[player_id].append(tile_data)
	print("🎴 Jugador %d roba tile %d" % [player_id, tile_data.id])
	return tile_data
	
	
func draw_next_tile():
	if selected_tile:
		selected_tile.queue_free()

	var tile_data = player_hands[current_player].pop_front()
	selected_tile = TILE_SCENE.instantiate()
	selected_tile.set_tile_data(tile_data)
	add_child(selected_tile)
	
func end_turn():
	if selected_tile:
		selected_tile.queue_free()
		selected_tile = null

	current_player = 2 if current_player == 1 else 1

	show_player_hand()
	show_opponent_hand()
	
	
	
	
# Valida si se puede colocar la ficha en la celda dada
func is_valid_placement(tile, grid_pos: Vector2i) -> bool:
	if board.is_empty():
		return true

	var neighbor_dirs := {
		Vector2i.UP: [[Vector2i(0, 1), Vector2i(0, 0)], [Vector2i(1, 1), Vector2i(1, 0)]],
		Vector2i.DOWN: [[Vector2i(0, 0), Vector2i(0, 1)], [Vector2i(1, 0), Vector2i(1, 1)]],
		Vector2i.LEFT: [[Vector2i(1, 0), Vector2i(0, 0)], [Vector2i(1, 1), Vector2i(0, 1)]],
		Vector2i.RIGHT: [[Vector2i(0, 0), Vector2i(1, 0)], [Vector2i(0, 1), Vector2i(1, 1)]]
	}

	for dir in neighbor_dirs:
		var neighbor_pos = grid_pos + dir
		if board.has(neighbor_pos):
			var neighbor_tile = board[neighbor_pos]
			for pair in neighbor_dirs[dir]:
				var a_pos = pair[0]
				var b_pos = pair[1]
				if neighbor_tile.micropuls.has(a_pos) and tile.micropuls.has(b_pos):
					var a_color = neighbor_tile.micropuls[a_pos]
					var b_color = tile.micropuls[b_pos]
					if a_color != b_color:
						if DEBUG_COMPARISON:
							print("❌ FALLIDA: Tile ", neighbor_tile.tile_id, " [", a_pos, " = ", a_color, "] vs Tile ", tile.tile_id, " [", b_pos, " = ", b_color, "] dir ", dir)
						return false
					elif DEBUG_COMPARISON:
						print("✔️ VÁLIDA: Tile ", neighbor_tile.tile_id, " [", a_pos, " = ", a_color, "] vs Tile ", tile.tile_id, " [", b_pos, " = ", b_color, "] dir ", dir)
				else:
					if DEBUG_COMPARISON:
						print("🔍 CONEXIÓN NULA: ", a_pos, " o ", b_pos, " no presentes")
	return true
	
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
	
	
func show_player_hand():
	var hand_ui = $HandUI  # Asegurate que tu nodo HBoxContainer se llame así
	for child in hand_ui.get_children():
		child.queue_free()

	for tile_data in player_hands[current_player]:
		var preview = preload("res://TilePreview.tscn").instantiate()
		preview.set_tile_data(tile_data)
		preview.connect("tile_selected", Callable(self, "_on_tile_selected"))
		hand_ui.add_child(preview)
		


	
func setup_game():
	# 1. Crear y barajar el mazo
	deck = TileLibrary.TILE_DATA.duplicate(true)
	deck.shuffle()

	# 2. Separar y colocar la loseta "big" en el centro
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
	var center_pos = Vector2i(0, 0)
	board[center_pos] = center_tile
	add_child(center_tile)

	# 🔄 IMPORTANTE: recalcular origen tras colocar primera loseta
	calculate_origin()
	center_tile.position = to_screen_pos(center_pos)
	queue_redraw()

	# 3. Repartir 6 losetas a cada jugador
	for i in range(6):
		draw_tile(1)
		draw_tile(2)

	# 4. Mostrar la mano del jugador actual (sin loseta seleccionada)
	selected_tile = null
	show_player_hand()
	show_opponent_hand()

	# 5. Mostrar el mazo
	show_deck_visual()

	# 6. Estado inicial
	state = "playing"
	current_player = 1
	
	
func show_deck_visual():
	var deck_visual = $DeckVisual

	var offset_x := 100  # 👉 más separación del tablero
	var deck_pos := origin + Vector2(COLUMNS * GRID_SIZE + offset_x, (ROWS * GRID_SIZE) / 2)

	deck_visual.position = deck_pos
	deck_visual.texture = load("res://tiles/tile_back.png")
	deck_visual.visible = true

	if deck_visual.has_node("DeckCount"):
		deck_visual.get_node("DeckCount").text = str(deck.size())



func show_opponent_hand():
	var opponent_ui = $OpponentHandUI
	for child in opponent_ui.get_children():
		child.queue_free()
	print("👉 Oponente tiene ", player_hands[2].size(), " cartas")
	print("🧱 UI width: ", $OpponentHandUI.size.x)
	for _i in player_hands[2].size():
		var back = preload("res://TileBackPreview.tscn").instantiate()
		opponent_ui.add_child(back)
		
		
		
func to_grid_pos(screen_pos: Vector2) -> Vector2i:
	var local = screen_pos - origin
	var col = int(floor(local.x / GRID_SIZE))
	var row = int(floor(local.y / GRID_SIZE))
	return Vector2i(col, row)

	
func to_screen_pos(grid_pos: Vector2i) -> Vector2:
	return origin + Vector2(grid_pos) * GRID_SIZE + Vector2(GRID_SIZE / 2, GRID_SIZE / 2)
