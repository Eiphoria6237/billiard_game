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
	pass # Replace with function body.

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
	set_water_state(WaterState.ICE)

func melt():
	set_water_state(WaterState.WATER)

func is_water():
	return state == WaterState.WATER

func is_ice():
	return not is_water()
