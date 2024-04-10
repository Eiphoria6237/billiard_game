extends CanvasLayer

@onready var popup = get_node("Popup")
@onready var popup_elements = popup.get_node("PopupElements")
@onready var label = popup.get_node("PopupElements/LabelMargin/LabelVBox/Text")
@onready var subtext = popup.get_node("PopupElements/LabelMargin/LabelVBox/Subtext")
@onready var popup_menu = popup.get_node("PopupElements/MenuButtons")
@onready var attempts_value = get_node("HUD/Stats/AttemptValue")
@onready var score_value = get_node("HUD/Stats/ScoreValue")


func _ready():
	_close_popup()
	Global.attempts = 0
	Global.score = 0

func _process(delta):
	attempts_value.set_text(str(Global.attempts))
	score_value.set_text(str(Global.score))

func _unhandled_input(event):
	# Open pause menu
	if (
			event is InputEventKey
			and event.is_pressed()
			and event.keycode == KEY_ESCAPE
	):
		_on_menu_button_pressed()

## Hide popup
func _close_popup():
	# Unpause if game is paused
	get_tree().paused = false
	subtext.hide()
	popup_menu.hide()
	popup.hide()

## Show popup with given title
func _open_popup(title):
	label.set_text(title)
	popup.show()


func _on_menu_button_pressed():
	if !get_tree().is_paused():
		subtext.hide()
		popup_menu.show()
		get_tree().paused = true
		_open_popup("Pause")
	else:
		_close_popup()


func _on_continue_btn_pressed():
	_on_menu_button_pressed()


func _on_restart_btn_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_back_to_menu_btn_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/levels/main/level_select.tscn")

