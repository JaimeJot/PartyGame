extends Node

var rankings := {}   # 👈 mejor diccionario por minijuego
var last_results := []  # 👈 últimos resultados (los que se muestran)

func save_results(minigame_name, results):
	rankings[minigame_name] = results
	last_results = results
