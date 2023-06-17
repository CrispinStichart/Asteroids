extends RigidBody2D

var turn_speed: float = 400
var acceleration: float = 200


var bullet_scene = preload("res://bullet.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("fire"):
		print("firing mah laser")
		fire()


func _physics_process(delta):
	if Input.is_action_pressed("turn_left"):
		apply_torque(-turn_speed)
	if Input.is_action_pressed("turn_right"):
		apply_torque(turn_speed)
	if Input.is_action_pressed("forward"):
		apply_central_force(Vector2.from_angle(rotation)*acceleration)
	if Input.is_action_pressed("backward"):
		apply_central_force(Vector2.from_angle(rotation)*-acceleration)


func fire():
	var bullet:Bullet = bullet_scene.instantiate().init($bullet_spawner.global_position, rotation)
	add_sibling(bullet)
	
		
# Perhaps I'll come back to this. Need to implement a more sophisticated drawing
# method. I can't rely on setting the with of the line, because then I'll
# see the square ends of the line. Need to have two shapes and fill them or 
# something.
#
#var top = Vector2(2, 0)
#var bottom_left = Vector2(0, 5)
#var bottom = Vector2(2, 4)
#var bottom_right = Vector2(4, 5)
#
#var color = Color.WHITE
#var width = 1
#
#
#func _draw():
#	draw_line(top, bottom_left, color, width)
#	draw_line(bottom_left, bottom, color, width)
#	draw_line(bottom, bottom_right, color, width)
#	draw_line(bottom_right, top, color, width)
	
