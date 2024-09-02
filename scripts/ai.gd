class_name AI extends CharacterBody2D

signal laser_shot(laser)
signal died

@export var acceleration := 10.0
@export var max_speed := 150.0
@export var rotation_speed := 250.0

@onready var muzzle = $Muzzle
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

var laser_scene = preload("res://scenes/laser_ai.tscn")

var rate_of_fire := 0.15
var shoot_cd := false
var alive : = true

var asteroids

func set_asteroids(the_asteroids):
	asteroids = the_asteroids
	
func avoid_asteroids():
	for asteroid in asteroids.get_children():
		match asteroid.size:
			Asteroid.AsteroidSize.LARGE:
				print(asteroid.position.x, " : ", asteroid.position.y)
			Asteroid.AsteroidSize.MEDIUM:
				print(asteroid.position.x, " : ", asteroid.position.y)
			Asteroid.AsteroidSize.SMALL:
				print(asteroid.position.x, " : ", asteroid.position.y)

func _process(delta):
	if !alive: return
	
	if Input.is_action_pressed("shoot"):
		if !shoot_cd:
			shoot_cd = true
			shoot_laser()
			await get_tree().create_timer(rate_of_fire).timeout
			shoot_cd = false

func _physics_process(delta):
	if !alive: return
	
	avoid_asteroids()
	
	var input_vector := Vector2(0, Input.get_axis("enemy_move_forward", "enemy_move_backward"))
	
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	
	if Input.is_action_pressed("enemy_rotate_right"):
		rotate(deg_to_rad(rotation_speed * delta))
	if Input.is_action_pressed("enemy_rotate_left"):
		rotate(deg_to_rad(-rotation_speed * delta))
		
	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 3)
	
	move_and_slide()
	
	var screen_size = get_viewport_rect().size
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
		
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0

func shoot_laser():
	var l = laser_scene.instantiate()
	l.global_position = muzzle.global_position
	l.rotation = rotation
	emit_signal("laser_shot", l)

func die():
	if alive==true:
		alive = false
		sprite.visible = false
		cshape.set_deferred("disabled", true)
		emit_signal("died")
		
func respawn(pos):
	if alive==false:
		alive = true
		global_position = pos
		velocity = Vector2.ZERO
		sprite.visible = true
		cshape.set_deferred("disabled", false)
