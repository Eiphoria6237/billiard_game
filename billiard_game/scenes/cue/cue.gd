extends Sprite2D

signal shoot

const SPEED_MODIFIER: float = 100

@onready var power_bar = get_node("ProgressBar")
var power: float = 0.0
var increasing: bool = true


func _process(delta):
	# use mouse to rotate the cue
	var mouse_pos = get_viewport().get_mouse_position()
	look_at(mouse_pos)

	# check if mouse clicks
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
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
		if power > 0:
			var direction = (position - mouse_pos).normalized()
			shoot.emit(power * direction)
			# reset for next time
			power = 0
			increasing = true

