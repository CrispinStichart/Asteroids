extends Node2D

var asteroid: Asteroid

var asteroid_scene = preload("res://asteroid.tscn")

@onready var noise = FastNoiseLite.new() 

func _ready():
	randomize()
	generate_asteroid_from_ui(null)
	
	
var points:Array[Vector2] = []


# Note that I'm using multiple for loops, which can probably be optimized into 
# one, and that instead of iterating over the list directly, I'm using the index
# and copying into a new list. This is because Vectors are passed by value into
# the iterator.
func generate_asteroid(segments: int, radius:float, offset_percentage: float) -> Array[Vector2]:
	if segments < 1: 
		return []
	var points: Array[Vector2] = []
	var x_placement = 0
	
	while len(points) < segments:
		var height_variation = clamp(randfn(0.0, 0.5), -1, 1)
		var step_variation = clamp(randfn(0.0, 0.5), -1, 1)
		x_placement += 2 + step_variation
		points.append(Vector2(x_placement, height_variation))
		
	# Normalize x position to be between zero and 2PI.
	var max_x:float = points[-1].x
	for i in range(len(points)):
		var p = points[i]
		p.x = (p.x/max_x) * 2.0 * PI
		points[i] = p

	# Now we map those points onto a circle.
	for i in range(len(points)):
		var p = points[i]
		var normalized_x = p.x
		var offset = p.y * radius * offset_percentage
		p.x = (radius+offset) * cos(normalized_x)
		p.y = (radius+offset) * sin(normalized_x)
		points[i] = p

#
#	print()
#	print("ORIGINAL POINTS")
#	for p in points: 
#		print(p)
#	print()
	return points

# good ranges:
# Segments: 6-16	
# Offset percentage: .20 to .40
# Radius: 100 is nice and big

func generate_asteroid_from_ui(_value):
	var segments = $VBox/segments.value
	var radius = $VBox/radius.value
	var variation = $VBox/variation.value
	points = generate_asteroid(segments, radius, variation)
	
	print(" ".join([segments, radius, variation]))
	
	queue_redraw()
	
	
	
func _draw():
	if len(points) < 2:
		return
		
	var spawn = $spawn.global_position
	draw_circle(spawn, 4, Color.RED)
#	print()
#	print("SPAWN POINTS")
	for i in range(len(points)-1):
#		print(points[i])
		draw_line(spawn+points[i], spawn+points[i+1], Color.WHITE)
	draw_line(spawn+points[0], spawn+points[len(points)-1], Color.WHITE)
	
	var split_one = points[0]
	var split_two = points[len(points) * (1.0/3.0)]
	var split_three = points[len(points) * (2.0/3.0	)]
	
	draw_line(spawn+split_one, spawn, Color.BLUE)
	draw_line(spawn+split_two, spawn, Color.BLUE)
	draw_line(spawn+split_three, spawn, Color.BLUE)
	
#	print()
