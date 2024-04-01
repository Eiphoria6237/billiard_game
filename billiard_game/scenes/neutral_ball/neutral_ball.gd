extends "res://assets/ball_collision_script.gd"

var collision_count = 0


func _on_body_entered(body):
	collision_count += 1
	if collision_count == 1:
		# Apply an impulse with the strength equal to the other body's velocity
		var other_body_velocity = body.linear_velocity if body is RigidBody2D else Vector2()
		var impulse_strength = other_body_velocity.length()
		var impulse_vector = other_body_velocity.normalized() * impulse_strength
		apply_central_impulse(impulse_vector)
	elif collision_count == 2:
		# Slow down the ball on the second collision
		linear_damp = collision_damping


