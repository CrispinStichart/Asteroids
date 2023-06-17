extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var asteroid = Asteroid.from_points($asteroid.points)
	asteroid.global_position = Vector2(600, 400)
	add_child(asteroid)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
