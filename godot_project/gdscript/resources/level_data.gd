@tool
extends Resource
class_name LevelData

@export var mesh_x: = load("res://geometry/gizmo.obj")
@export var mesh_y: = load("res://geometry/gizmo.obj")
@export var mesh_z: = load("res://geometry/gizmo.obj")

@export var uses_vertexcolour: = false

@export var translate_steps: Vector3i
@export var rotate_steps: Vector3i

func _init(tx: int = 0, ty: int = 0, tz: int = 0, rx: int = 0, ry: int = 0, rz: int = 0):
	translate_steps = Vector3i(tx, ty, tz)
	rotate_steps = Vector3i(rx, ry, rz)

func set_meshes(x, y, z):
	mesh_x = x
	mesh_y = y
	mesh_z = z
