extends Node

const MAX_POWER = 40.0
const DAMP = 4.0

@export var ball_scene: PackedScene
@export var cue_scene: PackedScene
@onready var cue_ball = $CueBall
var cue_instance: Node = null

func _ready():
	new_game()

func _process(delta):
	# Check if the cue ball has stopped and there is no cue instance currently
	if cue_ball.linear_velocity.length() <= 1:
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

func _on_cue_shoot(power):
	cue_ball.apply_central_impulse(power)
	cue_ball.linear_damp = DAMP
	# Hide cue after shooting
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(cue_instance):
		cue_instance.queue_free()
		cue_instance = null

