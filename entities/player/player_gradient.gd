extends Sprite2D

@onready var player: Player = $"../../"

const ROT = 0.2 # Rate of change
const S = 0.8
const L = 0.8
const FILL_RADIUS = 0.3

var hue = 0.0
var from_angle = 0.0
var to_angle = PI


func _process(delta: float) -> void:
	var rot := 0.5 if player.is_dashing else ROT
	var saturation := 0.95 if player.is_dashing else S
	var lightness := 0.5 if player.is_dashing else L

	texture = texture as GradientTexture2D
	hue += delta * rot
	from_angle += delta
	to_angle += delta


	for point in range(2):
		texture.gradient.set_color(point, Color.from_ok_hsl(hue + (float(point) / 2), saturation, lightness))
	
	texture.fill_from = Vector2.from_angle(from_angle) * FILL_RADIUS + Vector2.ONE / 2
	texture.fill_to = Vector2.from_angle(to_angle) * FILL_RADIUS + Vector2.ONE / 2
