extends "res://assets/ball_collision_script.gd"

# Ball state
enum BallState {
	NEUTRAL,
	FIRE,
	ICE
}

var neutral_ball = preload("res://assets/ball_state/neutral_ball.png")
var fire_ball = preload("res://assets/ball_state/fire_ball_big.png")
var ice_ball = preload("res://assets/ball_state/ice_ball_big.png")

var ball_texture = {
	BallState.NEUTRAL: neutral_ball,
	BallState.FIRE: fire_ball,
	BallState.ICE: ice_ball
}

var state = BallState.NEUTRAL
var prev_near = BallState.NEUTRAL	# detect ball infection

func _ready():
	super._ready()
	# Set initial state and appearance
	set_ball_state(BallState.NEUTRAL)
	# Report the first collision
	max_contacts_reported = 1

func _process(delta):
	pass

func set_ball_state(new_state):
	state = new_state
	$State.texture = ball_texture[state]

func set_default_prev_near():
	prev_near = BallState.NEUTRAL

func is_on_fire():
	return state == BallState.FIRE
	
func is_on_ice():
	return state == BallState.ICE

func _on_body_entered(body):
	if body is Area2D:
		#region Enter water area
		# 1. water state:
		# 1.1. fireball eliminated
		# 1.2. iceball: water -> ice
		# 2. ice state: linear_damp = ice_damp
		# 2.1. fireball -> neutralball
		#endregion
		if body.is_water():
			if $".".is_on_fire():
				$".".queue_free()
			elif $".".is_on_ice():
				body.freeze()
				linear_damp = ice_damping
		else:
			linear_damp = ice_damping
			if $".".is_on_fire():
				$".".set_ball_state(BallState.NEUTRAL)
	if body is RigidBody2D and super.is_high_speed(body.linear_velocity):
		#region Balls collision circumstances (need high speed)
		# 1. by cue_ball: neutral -> fire
		# 2. by other ball:
		# 2.1.	neutral enters neutral -> fire both
		# 2.2.	fire/ice enters fire/ice -> both smash
		# 2.3.	neutral enters fire/ice -> 
		# 			fire/ice smash, neutral...
		# 2.4.	fire/ice enters neutral ->  fire/ice smash, neutral get a lower acceleration
		#endregion 
		if body.is_cue_ball():
			if state == BallState.NEUTRAL: set_ball_state(BallState.FIRE)
		else:
			if body.is_neutral() and super.is_neutral():
				body.set_ball_state(BallState.FIRE)
				$".".set_ball_state(BallState.FIRE)
			elif not (body.is_neutral() and super.is_neutral()):
				body.queue_free()
				$".".queue_free()
			elif body.is_neutral():
				$".".queue_free()
				# [FIXME]: neutral ball's behavior
			elif $".".is_neutral():
				# [TODO] 2.4.
				pass
	elif body is StaticBody2D:
		if body.collision_layer == 8: # tree
			if state == BallState.FIRE:
				set_ball_state(BallState.NEUTRAL)
			else:
				set_ball_state(BallState.ICE)
		elif body.collision_layer == 32: # mud
			pass
