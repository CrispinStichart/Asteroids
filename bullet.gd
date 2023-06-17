extends CharacterBody2D
class_name Bullet


var speed:float = 6
var heading: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func init(position, rotation):
	self.rotation = rotation
	self.global_position = position	
	heading = Vector2.from_angle(rotation)
	return self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
#	velocity = heading * speed
	var collision = move_and_collide(heading * speed)
	if collision is KinematicCollision2D:
		var asteroid: Asteroid = collision.get_collider()
		asteroid.explode()
		queue_free()


func _draw():
	draw_rect($CollisionShape2D.shape.get_rect(), Color.WHITE)
