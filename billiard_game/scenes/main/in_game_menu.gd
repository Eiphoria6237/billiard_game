extends CanvasLayer

@onready var popup = %Popup
@onready var popup_elements = %PopupElements
@onready var label = popup_elements.get_node("LabelVBox/Text")
@onready var subtext = popup_elements.get_node("LabelVBox/Subtext")
@onready var popup_menu = popup_elements.get_node("MenuButtons")
@onready var attempts_value = get_node("HUD/Stats/AttemptValue")
@onready var score_value = get_node("HUD/Stats/ScoreValue")
@onready var level_notice_container = $LevelNoticeContainer
@onready var level_notice_label = %LevelNoticeLabel
@onready var sure_button = %SureButton
@onready var level_pass_container = $LevelPassContainer
@onready var star_label = %StarLabel

func _ready():
	_close_popup()
	Global.attempts = 0
	Global.score = 0
	sure_button.connect("pressed", Callable(self, "_on_sure_btn_clicked"))
	if level_notice_label.text != '':
		level_notice_container.show()
		

func _process(_delta):
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

func _on_sure_btn_clicked():
	level_notice_container.hide()


func _on_back_btn_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/levels/main/level_select.tscn")


func _on_next_level_btn_pressed():
	Global.next_level()


func _on_main_level_pass(ball_count):
	var star = "[img=64x64]res://assets/pngs/star.png[/img]"
	var empty_star = "[img=64x64]res://assets/pngs/star_outline.png[/img]"
	star_label.text = '[center]'
	if Global.attempts/ball_count <= 2:
		star_label.text += star + star + star
	elif Global.attempts/ball_count <= 3:
		star_label.text += star + star + empty_star
	else:
		star_label.text += star + empty_star + empty_star
	star_label.text += '[/center]'
	level_pass_container.show()
