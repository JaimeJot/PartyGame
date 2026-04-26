extends Node

@export var turn_label_path: NodePath
@export var result_label_path: NodePath

enum SelectionMode { KEY, DOOR }

const PLAYER_COUNT := 4
const KEY_COUNT := 5
const DOOR_COUNT := 3

var ACTIONS := {
	0: { "confirm": "p1_accept", "cancel": "p1_cancel", "left": "p1_left", "right": "p1_right" },
	1: { "confirm": "p2_accept", "cancel": "p2_cancel", "left": "p2_left", "right": "p2_right" },
	2: { "confirm": "p3_accept", "cancel": "p3_cancel", "left": "p3_left", "right": "p3_right" },
	3: { "confirm": "p4_accept", "cancel": "p4_cancel", "left": "p4_left", "right": "p4_right" }
}

var turn_label: Label
var result_label: Label

var selection_mode := SelectionMode.KEY
var selection_index := 0
var selected_key := -1

var key_used := []
var door_opened := []
var key_to_door := {}

var turn_order := []
var current_turn := 0
var rankings := []

func _ready():
	turn_label = get_node(turn_label_path)
	result_label = get_node(result_label_path)

	disable_focus($CanvasLayer/BotonJuego/KeysContainer)
	disable_focus($CanvasLayer/BotonJuego/DoorsContainer)

	start_game()

# ---------------- GAME SETUP ----------------

func start_game():
	key_used = []
	door_opened = []
	rankings.clear()

	for i in KEY_COUNT: key_used.append(false)
	for i in DOOR_COUNT: door_opened.append(false)

	turn_order = []
	for i in PLAYER_COUNT: turn_order.append(i)
	turn_order.shuffle()

	current_turn = 0
	assign_keys()

	selection_mode = SelectionMode.KEY
	selection_index = first_valid(key_used)

	update_ui()
	update_visual()

func assign_keys():
	key_to_door.clear()
	var keys := []
	for i in KEY_COUNT: keys.append(i)
	keys.shuffle()

	for d in DOOR_COUNT:
		key_to_door[keys[d]] = d

# ---------------- INPUT ----------------

func _process(_delta):
	# 🎮 CONTROLES DEBUG (todos usan Player1)
	if Input.is_action_just_pressed("p1_confirm"):
		confirm()

	if Input.is_action_just_pressed("p1_back"):
		selection_mode = SelectionMode.KEY

	if Input.is_action_just_pressed("p1_left"):
		move(-1)

	if Input.is_action_just_pressed("p1_right"):
		move(1)

func confirm():
	if selection_mode == SelectionMode.KEY:
		if key_used[selection_index]: return
		selected_key = selection_index
		selection_mode = SelectionMode.DOOR
		selection_index = first_valid(door_opened)
	else:
		if door_opened[selection_index]: return
		try_open(selected_key, selection_index)

	update_visual()

func move(dir: int):
	var list := key_used if selection_mode == SelectionMode.KEY else door_opened
	var size := list.size()

	for i in size:
		selection_index = wrapi(selection_index + dir, 0, size)
		if not list[selection_index]:
			update_visual()
			return

# ---------------- GAME LOGIC ----------------

func try_open(key: int, door: int):
	if key_to_door.get(key, -1) == door:
		result_label.text = "¡Jugador %d abre!" % (turn_order[current_turn] + 1)
		key_used[key] = true
		door_opened[door] = true
		rankings.append(turn_order[current_turn])
		_disable_key(key)
		_disable_door(door)
	else:
		result_label.text = "Jugador %d falla" % (turn_order[current_turn] + 1)

	next_turn()

func next_turn():
	if rankings.size() == DOOR_COUNT:
		# Añadir el último jugador que falta
		for p in turn_order:
			if not rankings.has(p):
				rankings.append(p)

		# 🔥 CONVERTIR A FORMATO CORRECTO
		var ordered_results = []
		var pos = 1
		
		for p in rankings:
			ordered_results.append({
				"player": "Player" + str(p + 1),
				"position": pos
			})
			pos += 1

		# 💾 GUARDAR BIEN
		GameState.rankings["doors"] = ordered_results
		GameState.last_results = ordered_results

		# 👉 IR A RESULTADOS
		get_tree().change_scene_to_file("res://results/ResultsScreen.tscn")
		queue_free()
		return

	# 👉 SIGUIENTE TURNO NORMAL
	current_turn = (current_turn + 1) % turn_order.size()
	selection_mode = SelectionMode.KEY
	selection_index = first_valid(key_used)

	update_ui()
	update_visual()

# ---------------- UI ----------------

func update_ui():
	var p = turn_order[current_turn] + 1
	turn_label.text = "Turno del Jugador " + str(p)
func update_visual():
	clear_visuals()

	var container = (
	$CanvasLayer/BotonJuego/KeysContainer
	if selection_mode == SelectionMode.KEY
	else $CanvasLayer/BotonJuego/DoorsContainer
)

	var btn := container.get_child(selection_index)
	btn.scale = Vector2(1.2, 1.2)
	btn.modulate = Color(1, 1, 0.6)

func clear_visuals():
	for c in $CanvasLayer/BotonJuego/KeysContainer.get_children():
		reset_btn(c)
	for c in $CanvasLayer/BotonJuego/DoorsContainer.get_children():
		reset_btn(c)

func reset_btn(btn):
	btn.scale = Vector2.ONE
	btn.modulate = Color.WHITE

# ---------------- HELPERS ----------------

func first_valid(arr: Array) -> int:
	for i in arr.size():
		if not arr[i]:
			return i
	return 0

func disable_focus(container):
	for c in container.get_children():
		if c is Control:
			c.focus_mode = Control.FOCUS_NONE

func _disable_key(i): $CanvasLayer/BotonJuego/KeysContainer.get_child(i).disabled = true
func _disable_door(i): $CanvasLayer/BotonJuego/DoorsContainer.get_child(i).disabled = true
