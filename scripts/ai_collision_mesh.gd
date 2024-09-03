class_name AICollisionMesh extends Area2D

@onready var cshape = $CollisionShape2D

var color = Color(1.0, 0.0, 0.0, 0.5)
var collision_rect2d

func update_mesh(texture_width, speed, mesh_rotation):
	#print("texture_width = ", texture_width)
	cshape.position = Vector2(-texture_width/2,0)
	cshape.shape = RectangleShape2D.new()
	cshape.shape.size = Vector2(texture_width, -speed)	
	
	collision_rect2d = Rect2(Vector2(-texture_width/2,0),Vector2(texture_width, -speed*2))

func _draw(): 	
	draw_rect(collision_rect2d, color) 

func _on_body_entered(body):
	print("hello")
	if body is AI:
		var ai = body
		ai.avoid_asteroid(cshape)
