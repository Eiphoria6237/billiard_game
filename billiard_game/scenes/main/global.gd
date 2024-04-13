extends Node

var current_level
var level_list = []
var attempts
var score
const CLICK_SOUND = preload("res://assets/audios/click1.ogg")

func next_level():
	var current_index = level_list.find(current_level,0)
	if current_index < level_list.size()-1:
		var next_level_path = level_list[current_index+1]
		Global.current_level = next_level_path
		get_tree().change_scene_to_file(next_level_path)
	else:
		pass

