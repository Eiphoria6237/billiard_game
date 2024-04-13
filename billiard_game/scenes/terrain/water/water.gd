extends Area2D

enum WaterState {
	WATER,
	ICE
}
var water = preload("res://assets/terrain/water.png")
var ice = preload("res://assets/terrain/ice.png")

var state = WaterState.WATER
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", Callable(self, "_on_water_body_entered"))
	connect("body_exited", Callable(self, "_on_water_body_exited"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_water_state(new_state):
	state = new_state
	if new_state == WaterState.WATER:
		$State.texture = water
	else:
		$State.texture = ice

func freeze():
	$PlayFreeze.play()
	set_water_state(WaterState.ICE)

func melt():
	$PlayFreeze.play()
	set_water_state(WaterState.WATER)

func is_water():
	return state == WaterState.WATER

func is_ice():
	return not is_water()

func _on_water_body_entered(body):
	#region Enter water area
	# 1. water state:
	# 1.1. fireball eliminated
	# 1.2. iceball: water -> ice
	# 2. ice state: linear_damp = ice_damp
	# 2.1. fireball -> neutralball
	#endregion
	if body.is_cue_ball():
		return
	if is_water():
		# handle different ball entering water
		if body.is_on_fire():
			body.explode()
		elif body.is_on_ice():
			freeze()
			body.linear_damp = body.ice_damping
	else:
		body.linear_damp = body.ice_damping
		if body.is_on_fire():
			body.set_neutral()
			melt()
		elif body.is_neutral():
			body.set_freeze()


func _on_water_body_exited(body):
	body.linear_damp = body.initial_damping
	pass # Replace with function body.
