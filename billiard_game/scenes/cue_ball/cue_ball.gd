extends "res://assets/ball_collision_script.gd"

func _ready():
	collision_damping = 6.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# check if the cue ball has stopped
	if $".".linear_velocity.length() <= 0.1:
		get_parent().show_cue()
