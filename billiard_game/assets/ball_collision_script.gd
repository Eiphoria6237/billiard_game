# for all balls, slow down upon collision
extends RigidBody2D

var initial_damping = 0.0
var collision_damping = 4.0
var has_collided = false

func _ready():
	linear_damp = initial_damping
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if not has_collided:
		linear_damp = collision_damping
		has_collided = true
