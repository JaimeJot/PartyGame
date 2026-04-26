extends Control

var finished_players = []
var final_positions = {}
var game_finished = false

var arrow_textures = {
	"up": preload("res://assets/arrows/arrow_up.png"),
	"down": preload("res://assets/arrows/arrow_down.png"),
	"left": preload("res://assets/arrows/arrow_left.png"),
	"right": preload("res://assets/arrows/arrow_right.png")
}

var visible_arrows = 4
var spacing = 180
var base_y = 500

var sequence = []
var sequence_length = 5

var player_progress = {
	"Player1": 0,
	"Player2": 0,
	"Player3": 0,
	"Player4": 0
}

var players_arrows = {}
var player_locked = {}
var game_started = false

func _ready():
	generate_sequence()
	setup_players()

	for p in player_progress.keys():
		player_locked[p] = false

	await get_tree().process_frame
	spawn_initial_arrows()
	start_countdown()

func start_countdown():
	var label := Label.new()
	label.text = "3"
	label.scale = Vector2(3, 3)
	label.position = get_viewport_rect().size / 2 - Vector2(50, 50)
	add_child(label)

	await get_tree().create_timer(1.0).timeout
	label.text = "2"
	await get_tree().create_timer(1.0).timeout
	label.text = "1"
	await get_tree().create_timer(1.0).timeout
	label.text = "GO!"
	await get_tree().create_timer(0.5).timeout

	label.queue_free()
	game_started = true

func generate_sequence():
	var inputs = ["up", "down", "left", "right"]
	sequence.clear()
	for i in range(sequence_length):
		sequence.append(inputs.pick_random())

func setup_players():
	players_arrows["Player1"] = $HBoxContainer/Player1/Arrows
	players_arrows["Player2"] = $HBoxContainer/Player2/Arrows
	players_arrows["Player3"] = $HBoxContainer/Player3/Arrows
	players_arrows["Player4"] = $HBoxContainer/Player4/Arrows

func spawn_initial_arrows():
	for player in players_arrows.keys():
		for i in range(visible_arrows):
			spawn_arrow(player, i)

func spawn_arrow(player, index):
	var container = players_arrows[player]
	var panel = container.get_parent()
	var panel_width = panel.size.x

	if panel_width <= 0.0:
		panel_width = get_viewport_rect().size.x / 4.0

	var seq_index = player_progress[player] + index
	if seq_index >= sequence.size():
		return

	var dir = sequence[seq_index]

	var arrow = Sprite2D.new()
	arrow.texture = arrow_textures[dir]
	arrow.centered = true
	arrow.scale = Vector2(0.3, 0.3)

	arrow.position = Vector2(
		panel_width / 2.0,
		base_y - index * spacing
	)

	container.add_child(arrow)

func _input(event):
	if !game_started:
		return

	handle_input(event, "Player1", "p1")
	handle_input(event, "Player2", "p2")
	handle_input(event, "Player3", "p3")
	handle_input(event, "Player4", "p4")

func handle_input(event, player, prefix):
	if player_locked[player]:
		return

	if event.is_action_pressed(prefix + "_up"):
		check(player, "up")
	if event.is_action_pressed(prefix + "_down"):
		check(player, "down")
	if event.is_action_pressed(prefix + "_left"):
		check(player, "left")
	if event.is_action_pressed(prefix + "_right"):
		check(player, "right")

func check(player, input_action):
	if game_finished:
		return

	var index = player_progress[player]

	if index >= sequence.size():
		return

	if sequence[index] != input_action:
		fail_feedback(player)
		return

	player_progress[player] += 1
	
	remove_first(player)
	move_down(player)
	spawn_next(player)

	# 🏁 SI TERMINA
	if player_progress[player] >= sequence.size():
		player_finished(player)

func player_finished(player):
	if player in finished_players:
		return

	finished_players.append(player)

	var position = finished_players.size()
	final_positions[player] = position

	print(player, "ha quedado", str(position) + "º")

	# 🚨 Si ya hay 3, el último es automático
	if finished_players.size() == 3:
		for p in player_progress.keys():
			if !(p in finished_players):
				final_positions[p] = 4
				print(p, "ha quedado 4º")

		end_game()

func end_game():
	if game_finished:
		return

	game_finished = true

	print("RESULTADOS:", final_positions)

	# 🧠 convertir a lista ordenada
	var ordered_results = []

	for player in final_positions.keys():
		ordered_results.append({
			"player": player,
			"position": final_positions[player]
		})

	ordered_results.sort_custom(func(a, b): return a.position < b.position)
	# 💾 GUARDAR EN GAMESTATE
	GameState.save_results("arrows", ordered_results)

	# ⏳ pequeña pausa
	await get_tree().create_timer(2).timeout

	# 👉 ir a results
	get_tree().change_scene_to_file("res://results/ResultsScreen.tscn")


func fail_feedback(player):
	player_locked[player] = true

	var container = players_arrows[player]
	if container.get_child_count() == 0:
		player_locked[player] = false
		return

	var arrow = container.get_child(0)
	var original_scale = arrow.scale

	arrow.scale = Vector2(0.45, 0.45)

	await get_tree().create_timer(0.5).timeout

	if is_instance_valid(arrow):
		arrow.scale = original_scale

	player_locked[player] = false

func remove_first(player):
	var container = players_arrows[player]
	if container.get_child_count() > 0:
		container.get_child(0).queue_free()

func move_down(player):
	var container = players_arrows[player]
	for arrow in container.get_children():
		arrow.position.y += spacing

func spawn_next(player):
	spawn_arrow(player, visible_arrows - 1)
