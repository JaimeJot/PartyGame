extends Control

@export var ranking_label_path: NodePath
var ranking_label: Label


func _ready():
	ranking_label = get_node(ranking_label_path)
	ranking_label.text = ""

	if GameState.rankings.size() > 0:
		set_results(GameState.rankings)


func set_results(rankings: Array):
	var text := ""
	for i in range(rankings.size()):
		text += "%dº → Jugador %d\n" % [i + 1, rankings[i] + 1]
	
	ranking_label.text = text

	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file("res://menus/MainMenu.tscn")

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://menus/MainMenu.tscn")
