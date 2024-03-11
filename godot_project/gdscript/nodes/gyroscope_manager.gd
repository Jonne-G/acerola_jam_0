extends Node3D
class_name GyroscopeManager

enum AXIS { X, Y, Z }

@export var translate_step_size: = 0.1 * 0.0625
@export var rotate_step_size: = 10.0

var rotate_step_limit: int = int(360.0 / rotate_step_size)

var current_axis: = AXIS.X

var rotate_direction: = 0
var translate_direction: = 0

var current_translate: Node3D = null
var current_rotate: Node3D = null

@onready var press_hold_rotate: Timer = get_node("press_hold-rotate")
@onready var press_hold_translate: Timer = get_node("press_hold-translate")

@onready var node_translate_x: Node3D = get_node("XTranslate")
@onready var node_rotate_x: Node3D = get_node("XTranslate/XRotate")
@onready var node_mesh_x: MeshInstance3D = get_node("XTranslate/XRotate/XMesh")
var translate_steps_x: = -1
var rotate_steps_x: = 0
var current_rotate_steps_x: = 0.0
var target_pos_x: float = 0.0

@onready var node_translate_y: Node3D = get_node("YTranslate")
@onready var node_rotate_y: Node3D = get_node("YTranslate/YRotate")
@onready var node_mesh_y: MeshInstance3D = get_node("YTranslate/YRotate/YMesh")
var translate_steps_y: = -1
var rotate_steps_y: = 0
var current_rotate_steps_y: = 0.0
var target_pos_y: float = 0.0

@onready var node_translate_z: Node3D = get_node("ZTranslate")
@onready var node_rotate_z: Node3D = get_node("ZTranslate/ZRotate")
@onready var node_mesh_z: MeshInstance3D = get_node("ZTranslate/ZRotate/ZMesh")
var translate_steps_z: = -1
var rotate_steps_z: = 0
var current_rotate_steps_z: = 0.0
var target_pos_z: float = 0.0

func _ready():
	press_hold_rotate.timeout.connect(hold_rotate_callback)
	press_hold_translate.timeout.connect(hold_translate_callback)
	
	var downscale = Vector3.ONE / 16.0 # ☺ Crime against humanity, I have to scale everything down, whoops
	node_mesh_x.scale = downscale
	node_mesh_y.scale = downscale
	node_mesh_z.scale = downscale
	
	current_translate = node_translate_x
	current_rotate    = node_rotate_x
	
	apply_transform()
	
	GlobalFunctions.manager = self
	GlobalUIManager.gyro_manager = self
	
	var material_x: = ShaderMaterial.new()
	var material_y: = ShaderMaterial.new()
	var material_z: = ShaderMaterial.new()
	
	material_x.shader = load("res://materials/shaders/flat_colour.gdshader")
	material_y.shader = load("res://materials/shaders/flat_colour.gdshader")
	material_z.shader = load("res://materials/shaders/flat_colour.gdshader")
	
	material_x.set_shader_parameter("colour", Vector3(1.0, 0.0, 0.0))
	material_y.set_shader_parameter("colour", Vector3(0.0, 1.0, 0.0))
	material_z.set_shader_parameter("colour", Vector3(0.0, 0.0, 1.0))
	
	node_mesh_x.set_surface_override_material(0, material_x)
	node_mesh_y.set_surface_override_material(0, material_y)
	node_mesh_z.set_surface_override_material(0, material_z)

func _process(delta: float):
	node_translate_x.global_position.z = lerp(node_translate_x.global_position.z, target_pos_x, delta * 5.0)
	node_translate_y.global_position.x = lerp(node_translate_y.global_position.x, target_pos_y, delta * 5.0)
	node_translate_z.global_position.y = lerp(node_translate_z.global_position.y, target_pos_z, delta * 5.0)
	
	current_rotate_steps_x = lerp(current_rotate_steps_x, float(rotate_steps_x), delta * 5.0);
	current_rotate_steps_y = lerp(current_rotate_steps_y, float(rotate_steps_y), delta * 5.0);
	current_rotate_steps_z = lerp(current_rotate_steps_z, float(rotate_steps_z), delta * 5.0);
	
	node_rotate_x.global_rotation_degrees.x = current_rotate_steps_x * rotate_step_size
	node_rotate_y.global_rotation_degrees.y = current_rotate_steps_y * rotate_step_size
	node_rotate_z.global_rotation_degrees.z = current_rotate_steps_z * rotate_step_size

func _input(event):
	if !GlobalUIManager.in_game_menu.visible || GlobalUIManager.game_is_paused:
		return
	
	# ^ rotate +, v rotate -, > translate +, < translate -
	var rotate_up: bool = event.is_action_pressed("^")
	var rotate_down: bool = event.is_action_pressed("v")
	
	var translate_up: bool = event.is_action_pressed(">")
	var translate_down: bool = event.is_action_pressed("<")
	
	if rotate_up || rotate_down:
		rotate_direction = int(rotate_up) - int(rotate_down)
		if rotate_direction != 0:
			press_hold_rotate.start()
			update_rotate(rotate_direction)
			check_victory()
	
	if translate_up || translate_down:
		translate_direction = int(translate_up) - int(translate_down)
		if translate_direction != 0:
			press_hold_translate.start()
			update_translate(translate_direction)
			check_victory()
	
	if event.is_action_released("^") || event.is_action_released("v"):
		rotate_direction = 0
		press_hold_rotate.stop()
		check_victory()
	if event.is_action_released(">") || event.is_action_released("<"):
		translate_direction = 0
		press_hold_translate.stop()
		check_victory()
	
	
	
	if event.is_action_pressed("axis_x", false, true):
		current_axis = AXIS.X
	elif event.is_action_pressed("axis_y", false, true):
		current_axis = AXIS.Y
	elif event.is_action_pressed("axis_z", false, true):
		current_axis = AXIS.Z
	
	
	
	if event.is_action_pressed("solve", false, true):
		translate_steps_x = 0
		translate_steps_y = 0
		translate_steps_z = 0
		
		rotate_steps_x = 0
		rotate_steps_y = 0
		rotate_steps_z = 0
		
		target_pos_x = 0.0
		target_pos_y = 0.0
		target_pos_z = 0.0
	elif event.is_action_pressed("reset", false, true):
		GlobalFunctions._load_index = GlobalFunctions._current_level
		GlobalFunctions.load_level()

func hold_rotate_callback():
	update_rotate(rotate_direction)

func hold_translate_callback():
	update_translate(translate_direction)

func check_victory():
	var fixed_rotate_x: int = posmod(rotate_steps_x, rotate_step_limit)
	var fixed_rotate_y: int = posmod(rotate_steps_y, rotate_step_limit)
	var fixed_rotate_z: int = posmod(rotate_steps_z, rotate_step_limit)
	
	if (fixed_rotate_x == 0 && fixed_rotate_y == 0 && fixed_rotate_z == 0 &&
		translate_steps_x == 0 && translate_steps_y == 0 && translate_steps_z == 0):
		var particles: GPUParticles2D = %victory_particles
		particles.restart()

func update_rotate(amount: int):
	match current_axis:
		AXIS.X:
			rotate_steps_x = (rotate_steps_x + amount)
			#target_rot_x = rotate_steps_x * rotate_step_size
		AXIS.Y:
			rotate_steps_y = (rotate_steps_y + amount)
			#target_rot_y = rotate_steps_y * rotate_step_size
		AXIS.Z:
			rotate_steps_z = (rotate_steps_z + amount)
			#target_rot_z = rotate_steps_z * rotate_step_size

func update_translate(amount: int):
	match current_axis:
		AXIS.X:
			translate_steps_x += amount
			target_pos_x = translate_steps_x * translate_step_size
		AXIS.Y:
			translate_steps_y += amount
			target_pos_y = translate_steps_y * translate_step_size
		AXIS.Z:
			translate_steps_z += amount
			target_pos_z = translate_steps_z * translate_step_size

func apply_transform():
		node_translate_x.global_position.z = translate_steps_x * translate_step_size
		node_translate_y.global_position.x = translate_steps_y * translate_step_size
		node_translate_z.global_position.y = translate_steps_z * translate_step_size
		
		target_pos_x = translate_steps_x * translate_step_size
		target_pos_y = translate_steps_y * translate_step_size
		target_pos_z = translate_steps_z * translate_step_size
		
		node_rotate_x.global_rotation_degrees.x = rotate_steps_x * rotate_step_size
		node_rotate_y.global_rotation_degrees.y = rotate_steps_y * rotate_step_size
		node_rotate_z.global_rotation_degrees.z = rotate_steps_z * rotate_step_size
		
		current_rotate_steps_x = rotate_steps_x
		current_rotate_steps_y = rotate_steps_y
		current_rotate_steps_z = rotate_steps_z
