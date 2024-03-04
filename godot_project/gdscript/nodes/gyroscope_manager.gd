extends Node3D
class_name GyroscopeManager

enum AXIS { X, Y, Z }

@export var translate_step_size: = 0.1
@export var rotate_step_size: = 10.0

var current_axis: = AXIS.X

var current_translate: Node3D = null
var current_rotate: Node3D = null

@onready var node_translate_x: Node3D = self.find_child("XTranslate")
@onready var node_rotate_x: Node3D = self.find_child("XRotate")
@onready var node_mesh_x: MeshInstance3D = self.find_child("XMesh")
var translate_steps_x: = -1
var rotate_steps_x: = 0
var target_pos_x: float = 0.0
var target_rot_x: float = 0.0

@onready var node_translate_y: Node3D = self.find_child("YTranslate")
@onready var node_rotate_y: Node3D = self.find_child("YRotate")
@onready var node_mesh_y: MeshInstance3D = self.find_child("YMesh")
var translate_steps_y: = -1
var rotate_steps_y: = 0
var target_pos_y: float = 0.0
var target_rot_y: float = 0.0

@onready var node_translate_z: Node3D = self.find_child("ZTranslate")
@onready var node_rotate_z: Node3D = self.find_child("ZRotate")
@onready var node_mesh_z: MeshInstance3D = self.find_child("ZMesh")
var translate_steps_z: = -1
var rotate_steps_z: = 0
var target_pos_z: float = 0.0
var target_rot_z: float = 0.0

func _ready():
	current_translate = node_translate_x
	current_rotate    = node_rotate_x
	
	apply_transform()
	
	GlobalFunctions.manager = self
	
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
	
	node_rotate_x.global_rotation_degrees.x = lerp(node_rotate_x.global_rotation_degrees.x, target_rot_x, delta * 5.0)
	node_rotate_y.global_rotation_degrees.y = lerp(node_rotate_y.global_rotation_degrees.y, target_rot_y, delta * 5.0)
	node_rotate_z.global_rotation_degrees.z = lerp(node_rotate_z.global_rotation_degrees.z, target_rot_z, delta * 5.0)

func _input(event):
	if event.is_action_pressed("rotate_+", false, true):
		update_rotate(1)
		check_victory()
	elif event.is_action_pressed("rotate_-", false, true):
		update_rotate(-1)
		check_victory()
	elif event.is_action_pressed("translate_+", false, true):
		update_translate(1)
		check_victory()
	elif event.is_action_pressed("translate_-", false, true):
		update_translate(-1)
		check_victory()
	elif event.is_action_pressed("axis_x", false, true):
		current_axis      = AXIS.X
		check_victory()
	elif event.is_action_pressed("axis_y", false, true):
		current_axis      = AXIS.Y
		check_victory()
	elif event.is_action_pressed("axis_z", false, true):
		current_axis      = AXIS.Z
		check_victory()
	elif event.is_action_pressed("solve", false, true):
		translate_steps_x = 0
		translate_steps_y = 0
		translate_steps_z = 0
		
		rotate_steps_x = 0
		rotate_steps_y = 0
		rotate_steps_z = 0
		
		target_pos_x = 0.0
		target_pos_y = 0.0
		target_pos_z = 0.0
		
		target_rot_x = 0.0
		target_rot_y = 0.0
		target_rot_z = 0.0
	elif event.is_action_pressed("reset", false, true):
		GlobalFunctions._load_index = GlobalFunctions._current_level
		GlobalFunctions.load_level()

func check_victory():
	if (rotate_steps_x == 0 && rotate_steps_y == 0 && rotate_steps_z == 0 &&
		translate_steps_x == 0 && translate_steps_y == 0 && translate_steps_z == 0):
		var particles: GPUParticles2D = %victory_particles
		particles.restart()

func update_rotate(amount: int):
	match current_axis:
		AXIS.X:
			rotate_steps_x += amount
			target_rot_x = rotate_steps_x * rotate_step_size
		AXIS.Y:
			rotate_steps_y += amount
			target_rot_y = rotate_steps_y * rotate_step_size
		AXIS.Z:
			rotate_steps_z += amount
			target_rot_z = rotate_steps_z * rotate_step_size

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
		
		target_rot_x = rotate_steps_x * rotate_step_size
		target_rot_y = rotate_steps_y * rotate_step_size
		target_rot_z = rotate_steps_z * rotate_step_size
