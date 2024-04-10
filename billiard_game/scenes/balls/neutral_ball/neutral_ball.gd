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
@export var explode_scene: PackedScene = preload("res://scenes/balls/neutral_ball/Explosion.tscn")
@export var smash_scene: PackedScene = preload("res://scenes/balls/neutral_ball/Smash.tscn")
@export var score_reward: int = 5

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
	if body is RigidBody2D:
		#region Balls collision circumstances (need high speed)
		# 1. by cue_ball: neutral -> fire
		# 2. by other ball:
		# 2.1.	neutral enters neutral -> fire both
		# 2.2.	fire/ice enters fire/ice -> both smash
		if body.is_cue_ball() and body.is_high_speed(body.linear_velocity):
			if state == BallState.NEUTRAL:
				set_ball_state(BallState.FIRE)
			if state == BallState.ICE: smash()
		if not body.is_cue_ball():
			if body.is_neutral() and is_neutral() and body.is_high_speed(body.linear_velocity):
				body.set_ball_state(BallState.FIRE)
				$".".set_ball_state(BallState.FIRE)
			elif body.is_on_fire() and is_on_fire():
				explode()
			elif body.is_on_ice() and is_on_ice():
				smash()

	if body is StaticBody2D:
		if body.collision_layer == 8: # tree
			if state == BallState.FIRE:
				set_ball_state(BallState.NEUTRAL)
			else:
				set_ball_state(BallState.ICE)
		elif body.collision_layer == 32: # mud
			pass

func explode():
	var explosion = explode_scene.instantiate()
	explosion.set_position(self.get_position())
	get_parent().add_child(explosion)
	Global.score+=score_reward
	queue_free()

func smash():
	var smash = smash_scene.instantiate()
	smash.set_position(self.get_position())
	get_parent().add_child(smash)
	Global.score+=score_reward
	queue_free()
