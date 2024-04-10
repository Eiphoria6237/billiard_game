extends Node

enum CueBallStates {
	SHOOTABLE,
	AIMING,
	MOVING
}
signal isAiming

var cue_ball_state
var cue_ball_position


## Add functionality for playable cue ball
func set_cue_ball_state(state: CueBallData.CueBallStates):
	CueBallData.cue_ball_state = state
	if state == CueBallData.CueBallStates.AIMING:
		isAiming.emit()
