extends Control

# --------------------
# TEXTURAS
# --------------------
var arrow_textures = {
	"up": preload("res://assets/arrows/arrow_up.png"),
	"down": preload("res://assets/arrows/arrow_down.png"),
	"left": preload("res://assets/arrows/arrow_left.png"),
	"right": preload("res://assets/arrows/arrow_right.png")
}

# --------------------
# CONFIG
# --------------------
var sequence = []
var sequence_length = 30

var player_progress = {
	"Player1": 0,
	"Player2": 0,
	"Player3": 0,
	"Player4": 0
}

var containers = {}

# --------------------
# READY
# --------------------
func _ready():
	generate_sequence()
	setup_players()
	create_visuals()
	update_all_visuals()

# --------------------
# SECUENCIA
# --------------------
func generate_sequence():
	var inputs = ["up", "down", "left", "right"]
	sequence.clear()
	
	for i in range(sequence_length):
		sequence.append(inputs.pick_random())

# --------------------
# REFERENCIAS
# --------------------
func setup_players():
	containers["Player1"] = $HBoxContainer/Player1/ScrollContainer/VBoxContainer
	containers["Player2"] = $HBoxContainer/Player2/ScrollContainer/VBoxContainer
	containers["Player3"] = $HBoxContainer/Player3/ScrollContainer/VBoxContainer
	containers["Player4"] = $HBoxContainer/Player4/ScrollContainer/VBoxContainer

# --------------------
# CREAR FLECHAS
# --------------------
func create_visuals():
	for player in containers.keys():
		var container = containers[player]
		
		for child in container.get_children():
			child.queue_free()
		
		# 🔥 ORDEN INVERTIDO (empieza abajo)
		for i in range(sequence.size() - 1, -1, -1):
			var dir = sequence[i]
			
			var arrow = TextureRect.new()
			arrow.texture = arrow_textures[dir]
			
			arrow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			arrow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			
			arrow.custom_minimum_size = Vector2(40, 40)
			
			container.add_child(arrow)

# --------------------
# INPUT (4 jugadores)
# --------------------
func _input(event):

	# PLAYER 1
	if event.is_action_pressed("p1_up"):
		check_input("Player1", "up")
	elif event.is_action_pressed("p1_down"):
		check_input("Player1", "down")
	elif event.is_action_pressed("p1_left"):
		check_input("Player1", "left")
	elif event.is_action_pressed("p1_right"):
		check_input("Player1", "right")

	# PLAYER 2
	if event.is_action_pressed("p2_up"):
		check_input("Player2", "up")
	elif event.is_action_pressed("p2_down"):
		check_input("Player2", "down")
	elif event.is_action_pressed("p2_left"):
		check_input("Player2", "left")
	elif event.is_action_pressed("p2_right"):
		check_input("Player2", "right")

	# PLAYER 3
	if event.is_action_pressed("p3_up"):
		check_input("Player3", "up")
	elif event.is_action_pressed("p3_down"):
		check_input("Player3", "down")
	elif event.is_action_pressed("p3_left"):
		check_input("Player3", "left")
	elif event.is_action_pressed("p3_right"):
		check_input("Player3", "right")

	# PLAYER 4
	if event.is_action_pressed("p4_up"):
		check_input("Player4", "up")
	elif event.is_action_pressed("p4_down"):
		check_input("Player4", "down")
	elif event.is_action_pressed("p4_left"):
		check_input("Player4", "left")
	elif event.is_action_pressed("p4_right"):
		check_input("Player4", "right")

# --------------------
# CHECK INPUT
# --------------------
func check_input(player, input_action):
	var index = player_progress[player]
	
	if index >= sequence.size():
		return
	
	if sequence[index] == input_action:
		player_progress[player] += 1
		
		update_scroll(player)
		update_visual(player)
		
		print(player, "→", player_progress[player])
	else:
		print(player, "fallo")

# --------------------
# SCROLL
# --------------------
func update_scroll(player):
	var scroll = get_node("HBoxContainer/%s/ScrollContainer" % player)
	var container = containers[player]
	var progress = player_progress[player]
	
	var arrow_height = 50
	var visible_area = scroll.size.y
	
	# 🔥 queremos que la flecha actual esté en una zona fija (ej: 70% de pantalla)
	var target_position = visible_area * 0.7
	
	var scroll_target = (progress * arrow_height) - target_position
	
	scroll.scroll_vertical = max(scroll_target, 0)

# --------------------
# VISUAL
# --------------------
func update_visual(player):
	var container = containers[player]
	var progress = player_progress[player]
	var total = container.get_child_count()
	
	for i in range(total):
		var arrow = container.get_child(i)
		var visual_index = total - 1 - i
		
		if visual_index < progress:
			arrow.modulate = Color(0.2, 0.2, 0.2, 0.3)
			arrow.scale = Vector2(0.8, 0.8)
			
		elif visual_index == progress:
			arrow.modulate = Color(1, 1, 1)
			arrow.scale = Vector2(1.4, 1.4)
			
		else:
			arrow.modulate = Color(0.5, 0.5, 0.5)
			arrow.scale = Vector2(1, 1)

func update_all_visuals():
	for player in containers.keys():
		update_visual(player)
