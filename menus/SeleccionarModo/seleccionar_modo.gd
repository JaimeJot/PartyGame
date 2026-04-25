extends Control

func _on_tableros_pressed():
	get_tree().change_scene_to_file("res://menus/Tableros/Tableros.tscn")

func _on_minijuegos_pressed():
	get_tree().change_scene_to_file("res://menus/MinigameSelect/MinigameSelect.tscn")

func _on_volver_pressed():
	get_tree().change_scene_to_file("res://menus/MainMenu/MainMenu.tscn")

func _ready():
	$VBoxContainer/Tableros.grab_focus()
