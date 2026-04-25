extends Control

func _on_minigame_1_pressed():
	get_tree().change_scene_to_file("res://minigames/MinijuegoLlaves/MinigameDoors.tscn")

func _on_minigame_2_pressed():
	get_tree().change_scene_to_file("res://minigames/MinijuegoFlechas/Minigame_arrows.tscn")

func _on_volver_pressed():
	get_tree().change_scene_to_file("res://menus/MainMenu/MainMenu.tscn")

func _ready():
	$VBoxContainer/PrimerBoton.grab_focus()
