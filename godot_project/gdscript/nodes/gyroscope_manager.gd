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
var translate_steps_x: = 0
var rotate_steps_x: = 0

@onready var node_translate_y: Node3D = self.find_child("YTranslate")
@onready var node_rotate_y: Node3D = self.find_child("YRotate")
@onready var node_mesh_y: MeshInstance3D = self.find_child("YMesh")
var translate_steps_y: = 0
var rotate_steps_y: = 0

@onready var node_translate_z: Node3D = self.find_child("ZTranslate")
@onready var node_rotate_z: Node3D = self.find_child("ZRotate")
@onready var node_mesh_z: MeshInstance3D = self.find_child("ZMesh")
var translate_steps_z: = 0
var rotate_steps_z: = 0

var _load_index: = 0
var _base_path: = "res://levels/"

func _ready():
	current_translate = node_translate_x
	current_rotate    = node_rotate_x

func _input(event):
	if event.is_action_pressed("rotate_+", false, true):
		update_rotate(1)
	elif event.is_action_pressed("rotate_-", false, true):
		update_rotate(-1)
	elif event.is_action_pressed("translate_+", false, true):
		update_translate(1)
	elif event.is_action_pressed("translate_-", false, true):
		update_translate(-1)
	elif event.is_action_pressed("axis_x", false, true):
		current_axis      = AXIS.X
	elif event.is_action_pressed("axis_y", false, true):
		current_axis      = AXIS.Y
	elif event.is_action_pressed("axis_z", false, true):
		current_axis      = AXIS.Z
	elif event.is_action_pressed("save", false, true):
		var current_level: LevelData = LevelData.new(
			translate_steps_x, translate_steps_y, translate_steps_z,
			rotate_steps_x, rotate_steps_y, rotate_steps_z
		)
		
		var level_count: = get_filecount()
		
		ResourceSaver.save(
			current_level,
			_base_path + "level_%d.res" % [level_count],
			ResourceSaver.FLAG_COMPRESS
		)
	elif event.is_action_pressed("load", false, true):
		if _load_index >= get_filecount():
			return
		
		var level = load("%slevel_%d.res" % [_base_path, _load_index]) as LevelData
		
		if level == null:
			return
		
		node_mesh_x.mesh = level.mesh_x
		node_mesh_y.mesh = level.mesh_y
		node_mesh_z.mesh = level.mesh_z
		
		translate_steps_x = level.translate_steps.x
		translate_steps_y = level.translate_steps.y
		translate_steps_z = level.translate_steps.z
		
		node_translate_x.global_position.z = translate_steps_x * translate_step_size
		node_translate_y.global_position.x = translate_steps_y * translate_step_size
		node_translate_z.global_position.y = translate_steps_z * translate_step_size
		
		rotate_steps_x = level.rotate_steps.x
		rotate_steps_y = level.rotate_steps.y
		rotate_steps_z = level.rotate_steps.z
		
		node_rotate_x.global_rotation_degrees.x = rotate_steps_x * rotate_step_size
		node_rotate_y.global_rotation_degrees.y = rotate_steps_y * rotate_step_size
		node_rotate_z.global_rotation_degrees.z = rotate_steps_z * rotate_step_size
	elif event is InputEventKey && event.is_pressed():
		var number: int = event.physical_keycode - 48
		
		if number >= 0 && number < 10:
			_load_index = number
	
	#if !(event is InputEventMouse):
		#print("axis: %d | t: {x %d, y %d, z %d} | r: {x %d, y %d, z %d}" % [current_axis, rotate_steps_x, rotate_steps_y, rotate_steps_z, translate_steps_x, translate_steps_y, translate_steps_z])

func update_rotate(amount: int):
	match current_axis:
		AXIS.X:
			rotate_steps_x += amount
			node_rotate_x.global_rotation_degrees.x = rotate_steps_x * rotate_step_size
		AXIS.Y:
			rotate_steps_y += amount
			node_rotate_y.global_rotation_degrees.y = rotate_steps_y * rotate_step_size
		AXIS.Z:
			rotate_steps_z += amount
			node_rotate_z.global_rotation_degrees.z = rotate_steps_z * rotate_step_size

func update_translate(amount: int):
	match current_axis:
		AXIS.X:
			translate_steps_x += amount
			node_translate_x.global_position.z = translate_steps_x * translate_step_size
		AXIS.Y:
			translate_steps_y += amount
			node_translate_y.global_position.x = translate_steps_y * translate_step_size
		AXIS.Z:
			translate_steps_z += amount
			node_translate_z.global_position.y = translate_steps_z * translate_step_size

func get_filecount() -> int:
	var directory: = DirAccess.open(_base_path)
	directory.include_hidden = false
		
	return directory.get_files().size()
