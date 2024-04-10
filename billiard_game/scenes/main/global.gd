extends Node

var current_level
var level_list = []
var attempts
var score

func next_level():
	var current_index = level_list.find(current_level,0)
	var next_level_path = level_list[current_index+1]
	get_tree().change_scene_to_file(next_level_path)

