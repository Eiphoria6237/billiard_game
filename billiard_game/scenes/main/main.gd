extends Node

const MAX_POWER = 5000
const DAMP = 4.0

@export var ball_scene: PackedScene = preload("res://scenes/balls/neutral_ball/neutral_ball.tscn")
@export var cue_scene: PackedScene = preload("res://scenes/cue/cue.tscn")
@onready var cue_ball = $CueBall
@onready var ball_parent = $Balls
@onready var GUI = $CanvasLayer
var cue_instance: Node = null
var objectballs: Array
var alive_objectballs: Array

func _ready():
	new_game()
	alive_objectballs.append_array(objectballs)

func _process(delta):
	# Check if the cue ball has stopped and there is no cue instance currently
	if cue_ball.is_stopped_or_still():
		update_alive_balls()
		if alive_objectballs.is_empty():
			Global.next_level()
		enable_cue()

func new_game():
	generate_cue()
	objectballs.append_array(ball_parent.get_children(false))
	#generate_balls()

func enable_cue():
	cue_instance.process_mode = 0 # = Mode: Inherit
	cue_instance.position = cue_ball.position
	cue_instance.visible = true

func disable_cue():
	cue_instance.process_mode =4 # = Mode: Disabled
	cue_instance.visible = false

func generate_balls():
	for i in range(3,7):
		var new_ball = ball_scene.instantiate() as RigidBody2D
		new_ball.linear_damp = DAMP
		var pos = Vector2(randf_range(50,1200), randf_range(50,1200))
		add_child(new_ball)
		new_ball.position = pos
		objectballs.append(new_ball)

func generate_cue():
	cue_instance = cue_scene.instantiate()
	add_child(cue_instance)
	cue_instance.position = cue_ball.position
	cue_instance.connect("shoot", Callable(self, "_on_cue_shoot"))

func _on_cue_shoot(power):
	disable_cue()
	cue_ball.apply_central_impulse(power)
	cue_ball.linear_damp = DAMP
	cue_ball.shot = true
	# Hide cue after shooting
	await get_tree().create_timer(0.5).timeout



func _on_cue_ball_one_shot_finished():
	# neutral balls are affected by the surrouding fire/ice balls
	const region = Vector2(100, 100)
	update_alive_balls()

	var ballIdx2changeState = {}
	for i in range(alive_objectballs.size()):
		var target = alive_objectballs[i]
		if not target.is_neutral():	continue
		var min_dis: float = INF

		var infection = null
		for j in range(alive_objectballs.size()):
			var tmp = alive_objectballs[j]
			if i == j or tmp.is_neutral(): continue
			var dis = target.position.distance_squared_to(tmp.position)
			if dis <= min_dis:
				min_dis = dis
				infection = tmp
		if min_dis <= region.length_squared():
			assert(infection != null)
			# cannot change now: avoid transmitting
			ballIdx2changeState[i] = infection.state
		else:
			ballIdx2changeState[i] = target.BallState.NEUTRAL# weird use of BallState qwq

	# change state
	for idx in ballIdx2changeState.keys():
		var target = alive_objectballs[idx]
		var next_state = ballIdx2changeState.get(idx)	# ice or fire or neutral
		if next_state == target.BallState.NEUTRAL:
			target.prev_near = next_state
		else:
			if target.prev_near == next_state:
				# near ice/fire ball at the beginning and ending of one shot, set on ice/fire
				target.set_ball_state(next_state)
				target.set_default_prev_near()	# set default neutral state
			else:
				target.prev_near = next_state



func _on_water_body_entered(body):
	#region Enter water area
	# 1. water state:
	# 1.1. fireball eliminated
	# 1.2. iceball: water -> ice
	# 2. ice state: linear_damp = ice_damp
	# 2.1. fireball -> neutralball
	#endregion
	if $Water.is_water():
		if body.is_on_fire():
			body.queue_free()
		elif body.is_on_ice():
			$Water.freeze()
			body.linear_damp = body.ice_damping
	else:
		body.linear_damp = body.ice_damping
		if body.is_on_fire():
			body.set_ball_state(body.BallState.NEUTRAL)
			$Water.melt()


func _on_water_body_exited(body):
	body.linear_damp = body.initial_damping
	pass # Replace with function body.

func update_alive_balls():
	alive_objectballs = []
	for objectball in objectballs:
		if objectball !=null:
			alive_objectballs.append(objectball)
