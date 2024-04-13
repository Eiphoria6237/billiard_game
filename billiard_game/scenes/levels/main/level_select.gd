extends Control


const LEVEL_BTN = preload("res://scenes/levels/main/level_button.tscn")
const INDEX_SCENE = preload("res://scenes/main/Index.tscn")
@export_dir var dir_path

@onready var grid = $MarginContainer/VBoxContainer/GridContainer

func _ready() -> void:
	get_levels(dir_path)

func get_levels(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name != "main.tscn":
				create_level_btn('%s/%s' % [dir.get_current_dir(), file_name], file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")


func create_level_btn(lvl_path, lvl_name):
	var btn = LEVEL_BTN.instantiate()
	btn.text = lvl_name.trim_suffix('.tscn').replace("_", " ")
	btn.level_path = lvl_path
	Global.level_list.push_back(lvl_path)
	grid.add_child(btn)

func _on_back_button_pressed():
	Music.get_node("Click").play()
	INDEX_SCENE.instantiate()
	get_tree().change_scene_to_packed(INDEX_SCENE)
