extends Control

func _on_button_pressed():
	get_tree().change_scene_to_file("res://menus/SeleccionarModo/SeleccionarModo.tscn")

func _ready():
	$AnimationPlayer.play("intro")
	$MovimientoBoton/PrimerBoton.grab_focus()
	_set_random_photo($ColorRect/Zona1/Foto, zona1_fotos)
	_set_random_photo($ColorRect/Zona2/Foto, zona2_fotos)
	_set_random_photo($ColorRect/Zona3/Foto, zona3_fotos)
	_set_random_photo($ColorRect/Zona4/Foto, zona4_fotos)
	_set_random_photo($ColorRect/Zona5/Foto, zona5_fotos)
	_set_random_photo($ColorRect/Zona6/Foto, zona6_fotos)
	_set_random_photo($ColorRect/Zona7/Foto, zona7_fotos)
@export var zona1_fotos: Array[Texture2D]
@export var zona2_fotos: Array[Texture2D]
@export var zona3_fotos: Array[Texture2D]
@export var zona4_fotos: Array[Texture2D]
@export var zona5_fotos: Array[Texture2D]
@export var zona6_fotos: Array[Texture2D]
@export var zona7_fotos: Array[Texture2D]

func _set_random_photo(texture_rect: TextureRect, photos: Array):
	if photos.is_empty():
		return
	texture_rect.texture = photos.pick_random()
