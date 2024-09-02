extends Node2D

@onready var lasers = $Lasers

@onready var player = $Player
@onready var ai = $AI
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var game_over_screen = $UI/GameOverScreen
@onready var player_spawn_pos = $PlayerSpawnPos
@onready var player_spawn_area = $PlayerSpawnPos/PlayerSpawnArea
@onready var ai_spawn_pos = $AISpawnPos
@onready var ai_spawn_area = $AISpawnPos/AISpawnArea

var asteroid_scene = preload("res://scenes/asteroid.tscn")

var score := 0:
	set(value):
		score = value
		hud.score = score

var lives_player: int:
	set(value):
		lives_player = value
		hud.update_player_lives(lives_player)

var lives_ai: int:
	set(value):
		lives_ai = value
		hud.update_ai_lives(lives_ai)

func _ready():
	game_over_screen.visible = false
	score = 0
	lives_player = 3
	lives_ai = 3
	player.connect("laser_shot", _on_laser_shot)
	player.connect("died", _on_player_died)

	ai.connect("laser_shot", _on_laser_shot)
	ai.connect("died", _on_ai_died)	
	
	ai.set_asteroids(asteroids)
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)

func _process(delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _on_laser_shot(laser):
	$LaserSound.play()
	lasers.add_child(laser)

func _on_asteroid_exploded(pos, size, points):
	$AsteroidHitSound.play()
	score += points
	for i in range(2):
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass

func spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)

func _on_player_died():
	$PlayerDieSound.play()
	lives_player -= 1
	player.global_position = player_spawn_pos.global_position
	if lives_player <= 0:
		await get_tree().create_timer(2).timeout
		game_over_screen.visible = true
	else:
		await get_tree().create_timer(1).timeout
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout
		player.respawn(player_spawn_pos.global_position)

func _on_ai_died():
	$PlayerDieSound.play()
	lives_ai -= 1
	ai.global_position = ai_spawn_pos.global_position
	if lives_ai <= 0:
		await get_tree().create_timer(2).timeout
		#game_over_screen.visible = true
	else:
		await get_tree().create_timer(1).timeout
		while !ai_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout
		ai.respawn(ai_spawn_pos.global_position)
