extends Control

const CHARACTERS = [
	{ "name": "Sonic", "id": "sonic", "color": Color(0.1, 0.4, 1.0) },
	{ "name": "Tails", "id": "tails", "color": Color(1.0, 0.7, 0.1) },
	{ "name": "Knuckles", "id": "knuckles", "color": Color(0.9, 0.1, 0.1) },
	{ "name": "Jet", "id": "jet", "color": Color(0.1, 0.8, 0.2) },
]

const PLAYER_COLORS = [
	Color(0.3, 0.6, 1.0),  # Jugador 1 - azul
	Color(1.0, 0.3, 0.3),  # Jugador 2 - rojo
	Color(1.0, 0.9, 0.2),  # Jugador 3 - amarillo
	Color(0.3, 1.0, 0.3),  # Jugador 4 - verde
]

var selections := { 1: -1, 2: -1, 3: -1, 4: -1 }
var current_player := 1
var cursor_index := 0
var font: FontFile
var card_nodes := []
var taken_labels := []

@onready var title_label: Label = $TitleLabel
@onready var cards_container: HBoxContainer = $CardsContainer
@onready var confirm_button: Button = $ConfirmButton

func _ready():
	font = load("res://fuentes/ZenDots-Regular.ttf")
	_build_ui()
	await get_tree().process_frame
	_update_ui()

func _build_ui():
	title_label.add_theme_font_override("font", font)
	title_label.add_theme_font_size_override("font_size", 52)
	title_label.add_theme_color_override("font_color", Color.WHITE)

	confirm_button.add_theme_font_override("font", font)
	confirm_button.add_theme_font_size_override("font_size", 36)
	confirm_button.text = "CONFIRMAR"
	confirm_button.disabled = true
	confirm_button.pressed.connect(_on_confirm_pressed)

	for i in CHARACTERS.size():
		var char_data = CHARACTERS[i]

		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(200, 300)

		var vbox := VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 10)

		var sprite := TextureRect.new()
		sprite.texture = load("res://assets/images/Personajes/" + char_data["id"] + ".png")
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sprite.custom_minimum_size = Vector2(220, 220)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

		var name_lbl := Label.new()
		name_lbl.text = char_data["name"].to_upper()
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_override("font", font)
		name_lbl.add_theme_font_size_override("font_size", 28)
		name_lbl.add_theme_color_override("font_color", char_data["color"])

		var taken_lbl := Label.new()
		taken_lbl.text = ""
		taken_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		taken_lbl.add_theme_font_override("font", font)
		taken_lbl.add_theme_font_size_override("font_size", 22)
		taken_lbl.add_theme_color_override("font_color", Color.WHITE)

		vbox.add_child(sprite)
		vbox.add_child(name_lbl)
		vbox.add_child(taken_lbl)
		card.add_child(vbox)
		cards_container.add_child(card)

		card_nodes.append(card)
		taken_labels.append(taken_lbl)

func _is_taken_by_other(char_idx: int) -> bool:
	for p in selections:
		if selections[p] == char_idx and p != current_player:
			return true
	return false

func _next_valid_cursor(from: int, dir: int) -> int:
	var idx = from
	for i in CHARACTERS.size():
		idx = wrapi(idx + dir, 0, CHARACTERS.size())
		if not _is_taken_by_other(idx):
			return idx
	return from  # si todos están cogidos no se mueve

func _input(_event):
	var all_selected = true
	for p in selections:
		if selections[p] == -1:
			all_selected = false

	if Input.is_action_just_pressed("p1_left"):
		cursor_index = _next_valid_cursor(cursor_index, -1)
		_update_ui()
	elif Input.is_action_just_pressed("p1_right"):
		cursor_index = _next_valid_cursor(cursor_index, 1)
		_update_ui()
	elif Input.is_action_just_pressed("p1_confirm"):
		if all_selected:
			_on_confirm_pressed()
		else:
			_select_character(cursor_index)
	elif Input.is_action_just_pressed("p1_back"):
		_reset_selections()

func _select_character(char_idx: int):
	if _is_taken_by_other(char_idx):
		return
	selections[current_player] = char_idx
	_advance_player()
	_update_ui()

func _advance_player():
	for i in range(1, 5):
		var next = ((current_player - 1 + i) % 4) + 1
		if selections[next] == -1:
			current_player = next
			# mover cursor al primer personaje libre
			for j in CHARACTERS.size():
				if not _is_taken_by_other(j):
					cursor_index = j
					return
			return

func _reset_selections():
	for p in selections:
		selections[p] = -1
	current_player = 1
	cursor_index = 0
	_update_ui()

func _update_ui():
	var all_selected = true
	for p in selections:
		if selections[p] == -1:
			all_selected = false

	title_label.text = "JUGADOR %d ELIGE" % current_player if not all_selected else "¡LISTOS!"
	confirm_button.disabled = not all_selected

	var cursor_color = PLAYER_COLORS[current_player - 1]

	for i in card_nodes.size():
		var card = card_nodes[i]
		var taken_lbl = taken_labels[i]
		var owner_player = -1

		for p in selections:
			if selections[p] == i:
				owner_player = p
				break

		if owner_player != -1:
			# Personaje ya seleccionado — color fijo del jugador dueño
			taken_lbl.text = "J%d" % owner_player
			taken_lbl.add_theme_color_override("font_color", PLAYER_COLORS[owner_player - 1])
			card.scale = Vector2.ONE
			card.self_modulate = PLAYER_COLORS[owner_player - 1]
		elif i == cursor_index:
			# Cursor encima — color del jugador actual
			taken_lbl.text = ""
			card.scale = Vector2(1.1, 1.1)
			card.pivot_offset = Vector2(100, 150)
			card.self_modulate = cursor_color
		else:
			# Libre y sin cursor
			taken_lbl.text = ""
			card.scale = Vector2.ONE
			card.self_modulate = Color.WHITE

func _on_confirm_pressed():
	for p in selections:
		GameState.player_characters[p] = CHARACTERS[selections[p]]["id"]
	get_tree().change_scene_to_file("res://menus/MinigameSelect/MinigameSelect.tscn")
