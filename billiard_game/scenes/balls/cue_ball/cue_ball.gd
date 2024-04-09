extends "res://assets/ball_collision_script.gd"

var shot: bool = false	# true:moving, false:still
signal one_shot_finished



# manually test the max speed, for debug only
var DEBUG: bool = false
var max_speed: float = 0.0

func _ready():
	CueBallData.cue_ball_position = global_position
	CueBallData.cue_ball_state = CueBallData.CueBallStates.SHOOTABLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if DEBUG: max_speed = max(max_speed, linear_velocity.length_squared())

	# Check if the cue ball has stopped
	if super.is_stopped_or_still():
		CueBallData.cue_ball_position = global_position
		if shot:
			shot = false
			# signal to change ball state, see function check_state_change in neutral_ball
			one_shot_finished.emit()
			CueBallData.set_cue_ball_state(CueBallData.CueBallStates.SHOOTABLE)

			if DEBUG: print(max_speed);	max_speed = 0.0

func is_cue_ball():
	return true



