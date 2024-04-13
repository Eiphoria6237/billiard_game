# for all balls, slow down upon collision
extends RigidBody2D

const initial_damping = 1.0
const collision_damping = 2.0
const ice_damping = 0.5
var has_collided = false
const speed_threshold: float = 2000

func _ready():
	linear_damp = initial_damping
	contact_monitor = true
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(_body):
	if not has_collided:
		linear_damp = collision_damping
		has_collided = true

func is_stopped_or_still():
	return linear_velocity.distance_squared_to(Vector2.ZERO) <= 10

func is_on_fire():
	return false

func is_on_ice():
	return false

func is_neutral():
	return not (is_on_fire() or is_on_ice())

func is_cue_ball():
	return false

func is_high_speed(o_lv: Vector2):
	# try using relative velocity
	#print(o_lv.length(), " : ",speed_threshold)
	return o_lv.length() >= speed_threshold
