extends Node

var rankings := {}
var last_results := []
var player_characters := {}  # 👈 ej: { 1: "sonic", 2: "tails", 3: "knuckles", 4: "jet" }

func save_results(minigame_name, results):
	rankings[minigame_name] = results
	last_results = results
