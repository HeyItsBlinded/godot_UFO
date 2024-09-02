extends Control

@onready var score = $Score:
	set(value):
		score.text = "SCORE: " + str(value)

var player_life_scene = preload("res://scenes/life_player.tscn")
var ai_life_scene = preload("res://scenes/life_ai.tscn")

@onready var player_lives = $PlayerLives
@onready var ai_lives = $AILives

func update_player_lives(amount):
	for ul in player_lives.get_children():
		ul.queue_free()
	for i in amount:
		var life = player_life_scene.instantiate()
		player_lives.add_child(life)


func update_ai_lives(amount):
	for ul in ai_lives.get_children():
		ul.queue_free()
	for i in amount:
		var life = ai_life_scene.instantiate()
		ai_lives.add_child(life)
