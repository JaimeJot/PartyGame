extends Control

const MEDALS = ["1°", "2°", "3°", "4°"]
const COLORS = [
	Color(1.0, 0.84, 0.0),
	Color(0.75, 0.75, 0.75),
	Color(0.8, 0.5, 0.2),
	Color(0.6, 0.2, 0.2),
]

@onready var rows_container: VBoxContainer = $VBoxContainer
var font: FontFile

func _ready():
	font = load("res://fuentes/ZenDots-Regular.ttf")
	for child in rows_container.get_children():
		child.queue_free()
	await get_tree().process_frame
	if GameState.last_results.size() > 0:
		set_results(GameState.last_results)
	else:
		_add_fallback_label("No hay resultados")

func _get_character_name(player_key: String) -> String:
	var player_num = int(player_key.replace("Player", ""))
	var char_id = GameState.player_characters.get(player_num, "")
	var names := {
		"sonic": "Sonic",
		"tails": "Tails",
		"knuckles": "Knuckles",
		"jet": "Jet",
	}
	return names.get(char_id, player_key)

func set_results(results: Array):
	for r in results:
		var pos = r["position"]
		var idx = pos - 1
		var display_name = _get_character_name(r["player"])

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 30)
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var medal_lbl := Label.new()
		medal_lbl.text = MEDALS[idx] if idx < MEDALS.size() else "?"
		medal_lbl.add_theme_font_size_override("font_size", 60)
		medal_lbl.add_theme_color_override("font_color", COLORS[idx] if idx < COLORS.size() else Color.WHITE)
		medal_lbl.custom_minimum_size = Vector2(120, 0)
		medal_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		medal_lbl.add_theme_font_override("font", font)

		var name_lbl := Label.new()
		name_lbl.text = display_name
		name_lbl.add_theme_font_size_override("font_size", 60)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_override("font", font)

		hbox.add_child(medal_lbl)
		hbox.add_child(name_lbl)
		rows_container.add_child(hbox)

	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file("res://menus/MinigameSelect/MinigameSelect.tscn")

func _add_fallback_label(msg: String):
	var lbl := Label.new()
	lbl.text = msg
	lbl.add_theme_font_size_override("font_size", 60)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_override("font", font)
	rows_container.add_child(lbl)
