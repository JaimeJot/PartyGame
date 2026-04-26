extends Control

@export var ranking_label_path: NodePath
var ranking_label: Label

func _ready():
	ranking_label = get_node(ranking_label_path)
	ranking_label.text = ""


	if GameState.last_results.size() > 0:
		set_results(GameState.last_results)
	else:
		ranking_label.text = "No hay resultados"


func set_results(results: Array):
	var text := ""

	for r in results:
		var player = r["player"]
		var pos = r["position"]

		match pos:
			1:
				text += "🥇 " + player + "\n"
			2:
				text += "🥈 " + player + "\n"
			3:
				text += "🥉 " + player + "\n"
			4:
				text += "❌ " + player + "\n"

	ranking_label.text = text

	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file("res://menus/MinigameSelect/MinigameSelect.tscn")
