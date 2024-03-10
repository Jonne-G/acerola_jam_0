extends Node

var menu_transition: float = 1.0

var main_menu: Control
var select_menu: Control
var in_game_menu: Control
var pause_menu: Control

var current_menu: Control

var gyro_manager: Node3D
var dynamic_camera_handler: Node3D

var start_camera: Camera3D
var select_camera: Camera3D
var play_camera: Camera3D

var active_camera: Camera3D # used for animation
var current_camera: Camera3D

func pause_game():
	pause_menu.visible = true
	get_tree().paused = true

func continue_game():
	pause_menu.visible = false
	get_tree().paused = false

func exit_game():
	get_tree().quit()
	
func navigate_to_main():
	switch_ui_from_to(current_menu, main_menu, current_camera, start_camera)
	current_menu = main_menu
	current_camera = start_camera

func navigate_to_select():
	switch_ui_from_to(current_menu, select_menu, current_camera, select_camera)
	current_menu = select_menu
	current_camera = select_camera

func navigate_to_play():
	dynamic_camera_handler.reset_camera()
	switch_ui_from_to(current_menu, in_game_menu, current_camera, play_camera)
	current_menu = in_game_menu
	current_camera = play_camera

func switch_ui_from_to(from: Control, to: Control, source: Camera3D, target: Camera3D):
	var screen_size: = get_window().size
	
	var tween: Tween = create_tween()
	
	from.visible = true
	to.visible = true
	
	var left: = Vector2(-screen_size.x, 0.0)
	var mid: = Vector2(0.0, 0.0)
	var right: = Vector2(screen_size.x, 0.0)
	
	from.position = mid
	to.position = left

	tween.tween_property(from, "position", right, menu_transition)
	tween.parallel().tween_property(to, "position", mid, menu_transition)
	
	source.current = false
	
	active_camera.global_transform = source.global_transform
	active_camera.current = true
	
	tween.parallel().tween_property(active_camera, "global_transform", target.global_transform, menu_transition)
	
	tween.tween_callback(func(): from.visible = false)
	tween.tween_callback(
		func():
			active_camera.current = false
			target.current = true
	)

func hide_menus():
	main_menu.visible = false
	select_menu.visible = false
	in_game_menu.visible = false
	pause_menu.visible = false
