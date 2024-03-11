extends Node

var menu_transition: float = 1.0

var main_menu: Control
var select_menu: Control
var in_game_menu: Control
var pause_menu: Control
var settings_menu: Control

var current_menu: Control

var gyro_manager: Node3D
var dynamic_camera_handler: Node3D

var start_camera: Camera3D
var select_camera: Camera3D
var play_camera: Camera3D

var active_camera: Camera3D # used for animation
var current_camera: Camera3D

var game_is_paused: = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("escape"):
		if pause_menu.visible:
			continue_game()
		elif in_game_menu.visible:
			pause_game()

func pause_game():
	pause_menu.visible = true
	get_tree().paused = true
	game_is_paused = true

func continue_game():
	pause_menu.visible = false
	get_tree().paused = false
	game_is_paused = false

func exit_game():
	get_tree().quit()
	
func navigate_to_main():
	switch_ui_from_to(main_menu, start_camera)
	current_menu = main_menu
	current_camera = start_camera

func navigate_to_select():
	switch_ui_from_to(select_menu, select_camera)
	current_menu = select_menu
	current_camera = select_camera

func navigate_to_play():
	dynamic_camera_handler.reset_camera()
	switch_ui_from_to(in_game_menu, play_camera)
	current_menu = in_game_menu
	current_camera = play_camera

func open_settings():
	if game_is_paused:
		settings_menu.show_panel()
		scroll_menu(pause_menu, settings_menu)
	else:
		settings_menu.hide_panel()
		scroll_menu(current_menu, settings_menu)

func close_settings():
	if game_is_paused:
		scroll_menu(settings_menu, pause_menu)
	else:
		scroll_menu(settings_menu, current_menu)

func scroll_menu(start_menu: Control, target_menu: Control):
	var screen_size: = get_window().size
	
	var top: = Vector2(0.0, -screen_size.y)
	var mid: = Vector2(0.0, 0.0)
	var bot: = Vector2(0.0, screen_size.y)
	
	start_menu.visible = true
	target_menu.visible = true
	
	start_menu.position = mid
	target_menu.position = bot
	
	var tween: Tween = create_tween()
	
	tween.tween_property(start_menu, "position", top, menu_transition)
	tween.parallel().tween_property(target_menu, "position", mid, menu_transition)
	
	tween.tween_callback(func(): start_menu.visible = false)
	
	tween.play()

func switch_ui_from_to(target_menu: Control, target_camera: Camera3D):
	var screen_size: = get_window().size
	
	var tween: Tween = create_tween()
	
	current_menu.visible = true
	target_menu.visible = true
	
	var left: = Vector2(-screen_size.x, 0.0)
	var mid: = Vector2(0.0, 0.0)
	var right: = Vector2(screen_size.x, 0.0)
	
	current_menu.position = mid
	target_menu.position = left

	tween.tween_property(current_menu, "position", right, menu_transition)
	tween.parallel().tween_property(target_menu, "position", mid, menu_transition)
	
	current_camera.current = false
	
	active_camera.global_transform = current_camera.global_transform
	active_camera.current = true
	
	tween.parallel().tween_property(active_camera, "global_transform", target_camera.global_transform, menu_transition)
	
	# By the time this tween ends, the "current_menu has been updated, so the callback breaks
	var temp_from_menu: = current_menu
	
	tween.tween_callback(func(): temp_from_menu.visible = false)
	tween.tween_callback(
		func():
			active_camera.current = false
			target_camera.current = true
	)

func hide_menus():
	main_menu.visible = false
	select_menu.visible = false
	in_game_menu.visible = false
	pause_menu.visible = false
