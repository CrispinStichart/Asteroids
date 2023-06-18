extends RigidBody2D
class_name Asteroid

const asteroid_scene = preload("res://asteroid.tscn")

var color := Color.WHITE
var points: Array[Vector2] = []
var radius:float = 100

# Used when splitting asteroids. Each new asteroid gets their points translated
# so the center is at (0,0), but then we need to know how far to translate
# the asteroid itself so the newly split chunk stays in the same position.
var offset_from_parent: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	if len(points) == 0:
		print("Setting points")
		set_random_points()
	
	$collision.polygon = points


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _draw():
	# Hacky way to get the default font.
	var font = Label.new().get_theme_default_font()
	
	for i in range(len(points)-1):
		draw_line(points[i], points[i+1], color)
		draw_char(font, points[i], str(i), 16, Color.RED)
	# Connect the last to the first to finish the circle.
	draw_line(points[0], points[len(points)-1], color)
	draw_char(font, points[len(points)-1], str(len(points)-1), 16, Color.RED)
	
	draw_circle(Vector2.ZERO, 5, Color.DEEP_PINK)


func set_points(points: Array[Vector2]) -> void:
	# Find the center:
	var center := Vector2.ZERO
	for p in points:
		center.y += p.y
		center.x += p.x
	center.x /= len(points)
	center.y /= len(points)
	
	offset_from_parent = center
	
	# Translate the points so the center is at (0, 0):
	self.points = []
	for p in points:
		p = p - center
		self.points.append(p) 
	
	# Now find the radius of the enclosing circle:
	self.radius = 0
	# Remember that we need to use self.points, since for loops pass vectors by
	# value, so the translation step didn't affect the points parameter.
	for p in self.points:
		self.radius = max(self.radius, p.distance_to(center))
		

func set_random_points():
	# These values were determined by doing a bunch of testing and 
	# picking what looked good.
	var segments: int = clamp(randfn(11, 1), 6, 16)
	var radius: float = clamp(randfn(90, 5), 20, 150)
	var offset_percentage: float = clamp(randfn(.30, .3), .20, .40) 
	self.points = Asteroid.generate_asteroid_points(segments, radius, offset_percentage)


func explode():
	if radius > 50 and len(points) >= 6:
		# Calculate the indexes for the slices.
		var splits = Asteroid.calculate_splits(points)
		
		var asteroid_one = Asteroid.from_points(splits[0])
		var asteroid_two = Asteroid.from_points(splits[1])
		var asteroid_three = Asteroid.from_points(splits[2])
		
		# When the Asteroid is created, the center is set to its natural position.
		# We need to move them back to their appropriate places so they're not
		# overlapping.
		asteroid_one.global_position = global_position + asteroid_one.offset_from_parent
		asteroid_two.global_position = global_position + asteroid_two.offset_from_parent
		asteroid_three.global_position = global_position + asteroid_three.offset_from_parent
		
		# Give them a nudge outward from the center of the exploded asteroid.
		# For some reason, the impulse doesn't seem to be originating in the center.
		var impulse_one = Vector2.from_angle(global_position.angle_to_point(asteroid_one.global_position)) * 10
		var impulse_two = Vector2.from_angle(global_position.angle_to_point(asteroid_two.global_position)) * 10
		var impulse_three = Vector2.from_angle(global_position.angle_to_point(asteroid_three.global_position)) * 10
#		print("test: ", Vector2())
		print(global_position)
		print(impulse_one)
		print(global_position.angle_to(asteroid_one.global_position))
		print(impulse_two)
		print(global_position.angle_to(asteroid_two.global_position))
		print(impulse_three)
		print(global_position.angle_to(asteroid_three.global_position))
		asteroid_one.apply_impulse(impulse_one)
		asteroid_two.apply_impulse(impulse_two)
		asteroid_three.apply_impulse(impulse_three)
		
		add_sibling(asteroid_one)
		add_sibling(asteroid_two)
		add_sibling(asteroid_three)
		
	queue_free()
	
	
static func calculate_splits(points: Array[Vector2]) -> Array:	
	var split_one:int = 0
	var split_two:int = len(points) * (1.0/3.0)
	var split_three:int = len(points) * (2.0/3.0)

	
	# Slice the points, using deep=true to make copies of the Vectors.
	var asteroid_one_points = points.slice(split_one, split_two, 1, true)
	var asteroid_two_points = points.slice(split_two-1, split_three, 1, true)
	var asteroid_three_points = points.slice(split_three-1, len(points), 1, true)
	# The third asteroid chunk needs to include the starting point.
	asteroid_three_points.append(points[0])

	# Add the center of the original asteroid as a point.
	asteroid_one_points.append(Vector2.ZERO)
	asteroid_two_points.append(Vector2.ZERO)
	asteroid_three_points.append(Vector2.ZERO)
	
	return [asteroid_one_points, asteroid_two_points, asteroid_three_points]
	
	
static func from_points(points: Array[Vector2]) -> Asteroid:
	var asteroid = asteroid_scene.instantiate()
	asteroid.set_points(points)
	return asteroid
	

static func new_random() -> Asteroid:
	var asteroid = asteroid_scene.instantiate()
	asteroid.set_random_points()
	return asteroid


# Note that I'm using multiple for loops, which can probably be optimized into 
# one, and that instead of iterating over the list directly, I'm using the index
# and copying into a new list. This is because Vectors are passed by value into
# the iterator.
static func generate_asteroid_points(segments: int, radius:float, offset_percentage: float) -> Array[Vector2]:
	if segments < 1: 
		return []
	var points: Array[Vector2] = []
	var x_placement = 0
	

	while len(points) < segments:
		# The normal distribution was found through trial and error. 
		# This looks right.
		var height_variation = clamp(randfn(0.0, 0.5), -1, 1)
		var step_variation = clamp(randfn(0.0, 0.5), -1, 1)
		# We vary the step so the asteroid is more lumpy.
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
		# If the offset percentage is 1.0, then potentially a divot in the
		# asteroid will reach the exact center. 
		var offset = p.y * radius * offset_percentage
		p.x = (radius+offset) * cos(normalized_x)
		p.y = (radius+offset) * sin(normalized_x)
		points[i] = p
		
	return points
	

		
		

