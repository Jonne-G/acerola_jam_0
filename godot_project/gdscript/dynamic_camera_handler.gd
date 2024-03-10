@tool
extends Node3D

@export_category("Camera Position")
@export_range(-180.0, 180.0) var horizontal_angle: = 45.0
@export_range(-80.0, 80.0) var vertical_angle: = -45.0
@export var camera_distance: = 10.0 / 16.0

@export_category("Camera Movement")
# Expressed as degrees-per-viewport_width
@export var horizontal_speed: = 5.0
@export var vertical_speed: = 2.5
@export var scroll_speed: = 1.0

@onready var speed: = Vector2(horizontal_speed, vertical_speed)
@onready var camera: Camera3D = get_child(0)

var is_held: = false

@onready var default_values: = Vector3(horizontal_angle, vertical_angle, camera_distance)

func _ready():
	GlobalUIManager.dynamic_camera_handler = self
	GlobalUIManager.play_camera = camera
	
	camera.position.z = camera_distance
	rotation_degrees = Vector3(vertical_angle, horizontal_angle, 0.0)

func _input(event: InputEvent):	
	if !GlobalUIManager.in_game_menu.visible:
		return
	
	if event.is_action_pressed("mouse_left"):
		is_held = true
	elif event.is_action_released("mouse_left"):
		is_held = false
	if event.is_action_pressed("scroll_up"):
		camera_distance -= scroll_speed
		camera.position.z = camera_distance
	elif event.is_action_pressed("scroll_down"):
		camera_distance += scroll_speed
		camera.position.z = camera_distance
	if event.is_action_pressed("focus"):
		var tween: = create_tween()
		tween.tween_property(
			self, "rotation_degrees",
			Vector3(vertical_angle, horizontal_angle, 0.0),
			0.2
		)
		tween.play()
	if is_held && event is InputEventMouseMotion:
		var screen_size: Vector2 = get_viewport().get_size()
	
		var motion: = event as InputEventMouseMotion
		
		var velocity: = motion.velocity / screen_size * speed
		
		rotation_degrees = Vector3(
			clamp(rotation_degrees.x - velocity.y, -80.0, 80.0),
			fmod(rotation_degrees.y - velocity.x, 360.0),
			0.0
		)

func reset_camera():
	horizontal_angle = default_values.x
	vertical_angle   = default_values.y
	camera_distance  = default_values.z
