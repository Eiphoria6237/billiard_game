extends Sprite2D

signal shoot

const SPEED_MODIFIER: float = 100

@onready var power_bar = get_node("ProgressBar")

var power: float = 0.0
var increasing: bool = true
var isAiming: bool = false
var mouse_pos

var resultPos
var canDraw: bool = false

var original_window_size = Vector2i(
			ProjectSettings.get("display/window/size/viewport_width"),
			ProjectSettings.get("display/window/size/viewport_height"))
const AIM_LINE_COLLISION_MASK = 0b00000000_00000000_00000000_00000111

@export var ball_scene: PackedScene = preload("res://scenes/balls/neutral_ball/neutral_ball.tscn")

func _ready():
	CueBallData.connect(
			"isAiming", Callable(self, "_on_aiming"))

func _process(delta):
	queue_redraw()
	# use mouse to rotate the cue
	mouse_pos = get_viewport().get_mouse_position()
	look_at(mouse_pos)
	if CueBallData.cue_ball_state == CueBallData.CueBallStates.AIMING && isAiming:
		aiming(delta)

	# check if mouse clicks
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if CueBallData.cue_ball_state == CueBallData.CueBallStates.SHOOTABLE:
			CueBallData.set_cue_ball_state(CueBallData.CueBallStates.AIMING)
		# check if space key is pressed
		if Input.is_key_pressed(KEY_SPACE):
			if increasing:
				power += SPEED_MODIFIER
				if power >= get_parent().MAX_POWER:
					power = get_parent().MAX_POWER
					increasing = false
		else:
			increasing = true
			power -= 0.5 * SPEED_MODIFIER
			if power <= 0:
				power = 0
		# Update the progress bar value
		power_bar.value = power / (get_parent().MAX_POWER)
		#print(power)
	else:
		canDraw = false
		if power > 0:
			var direction = (position - mouse_pos).normalized()
			shoot.emit(power * direction)
			CueBallData.set_cue_ball_state(CueBallData.CueBallStates.MOVING)
			Global.attempts+=1
			# reset for next time
			power = 0
			power_bar.value = 0
			increasing = true

func aiming(_delta):
	var direction = (position - mouse_pos).normalized()
	# Returns the state of the space of the current World_2D, to make an
	# intersection query for the prediction
	var space_state = get_world_2d().direct_space_state
	# Convert to local coordinate system without ball rotation
	var hit_direction_without_rotation = to_global(direction) - CueBallData.cue_ball_position
	# Vector that is longer than the table diagonally
	var very_long_vector = original_window_size.x + original_window_size.y
	# Defined als the hit direction scaled with the long vector
	var target = CueBallData.cue_ball_position + (
			direction * very_long_vector)
	var intersect_ray_params = PhysicsRayQueryParameters2D.create(
			CueBallData.cue_ball_position, target)
	intersect_ray_params.set_collide_with_areas(false)
	intersect_ray_params.set_collision_mask(AIM_LINE_COLLISION_MASK)
	var result = space_state.intersect_ray(intersect_ray_params)
	# Should always have some result
	if result:
		var local_target_position = to_local(result.position)
		resultPos = local_target_position
		canDraw = true

func _on_aiming():
	isAiming = true

func _draw():
	if canDraw:
		draw_dashed_line(to_local(CueBallData.cue_ball_position), resultPos, Color.GREEN, 1.0)
