extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_exit_btn_pressed():
	Music.get_node("Click").play()
	get_tree().quit()


func _on_level_btn_pressed():
	Music.get_node("Click").play()


func _on_play_btn_pressed():
	Music.get_node("Click").play()
	get_tree().change_scene_to_file("res://scenes/levels/main/level_select.tscn")
	#get_tree().change_scene_to_file("res://scenes/levels/level_scenes/level1.tscn")
