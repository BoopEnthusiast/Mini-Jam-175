class_name Camera
extends Camera2D
## Screenshake from https://gist.github.com/Alkaliii/3d6d920ec3302c0ce26b5ab89b417a4a
## and https://www.reddit.com/r/godot/comments/17e8s6f/screencamera_shake_2dgodot_4/

@export var noise: FastNoiseLite # The source of random values.
var decay := 0.95 # How quickly shaking will stop [0,1].
var max_offset := Vector2(100, 75) # Maximum displacement in pixels.
var max_roll := 0.1 # Maximum rotation in radians (use sparingly).

var noise_y = 0 # Value used to move through the noise

var trauma := 0.0 # Current shake strength
var trauma_pwr := 2.5 # Trauma exponent. Use [2,3]

func _ready():
	Singleton.camera = self
	randomize()
	noise.seed = randi()

func add_trauma(amount: float):
	trauma = min(trauma + amount, 1.0)

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	#optional
	elif offset.x != 0 or offset.y != 0 or rotation != 0:
		lerp(offset.x, 0.0, 1)
		lerp(offset.y, 0.0, 1)
		lerp(rotation, 0.0, 1)

func shake():
	var amt = pow(trauma, trauma_pwr)
	noise_y += 1
	rotation = max_roll * amt * noise.get_noise_2d(noise.seed % 2000, noise_y)
	offset.x = max_offset.x * amt * noise.get_noise_2d(noise.seed % 4000 + 3000, noise_y)
	offset.y = max_offset.y * amt * noise.get_noise_2d(noise.seed % 6000 + 5000, noise_y)
