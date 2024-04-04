extends Node

const MAX_POWER = 40.0
const DAMP = 4.0

@export var ball_scene: PackedScene = preload("res://scenes/balls/neutral_ball/neutral_ball.tscn")
@export var cue_scene: PackedScene = preload("res://scenes/cue/cue.tscn")
@onready var cue_ball = $CueBall
var cue_instance: Node = null
var objectballs = []

func _ready():
	new_game()

func _process(delta):
	# Check if the cue ball has stopped and there is no cue instance currently
	if cue_ball.is_stopped_or_still():
		if not is_instance_valid(cue_instance):
			show_cue()

func new_game():
	generate_balls()

func show_cue():
	if not is_instance_valid(cue_instance):
		cue_instance = cue_scene.instantiate()
		add_child(cue_instance)
		cue_instance.position = cue_ball.position
		cue_instance.connect("shoot", Callable(self, "_on_cue_shoot"))

func generate_balls():
	for i in range(3,7):
		var new_ball = ball_scene.instantiate() as RigidBody2D
		new_ball.linear_damp = DAMP
		var pos = Vector2(randf_range(50,1200), randf_range(50,1200))
		add_child(new_ball)
		new_ball.position = pos
		objectballs.append(new_ball)

func _on_cue_shoot(power):
	cue_ball.apply_central_impulse(power)
	cue_ball.linear_damp = DAMP
	cue_ball.shot = true
	# Hide cue after shooting
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(cue_instance):
		cue_instance.queue_free()
		cue_instance = null


func _on_cue_ball_one_shot_finished():
	# neutral balls are affected by the surrouding fire/ice balls
	const region = Vector2(50, 50)
	
	var alive_objectballs = []
	for objectball in objectballs:
		if is_instance_valid(objectball):
			alive_objectballs.append(objectball)
	
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
	
	# change state
	for idx in ballIdx2changeState.keys():
		alive_objectballs[idx].set_ball_state(ballIdx2changeState.get(idx))
			


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
