extends Node

var _load_index: = 0
var _current_level: = 0
var _base_path: = "res://levels/"

var manager: GyroscopeManager # Must be registered by the manager itself

func get_filecount() -> int:
	var directory: = DirAccess.open(_base_path)
	directory.include_hidden = false
		
	return directory.get_files().size()

func path_at_index(index: int) -> String:
	return _base_path + "level_%d.res" % [index]

func fix_font(labels: Array[Label], pixels: float):
	var window: = get_window()
	var font_size: int = int(float(window.size.x) / 1280.0 * pixels)
	
	for label in labels:
		label.add_theme_font_size_override("font_size", font_size)

func save_level():
	var current_level: LevelData = LevelData.new(
		manager.translate_steps_x, manager.translate_steps_y, manager.translate_steps_z,
		manager.rotate_steps_x, manager.rotate_steps_y, manager.rotate_steps_z
	)
	
	current_level.set_meshes(
		manager.node_mesh_x.mesh, 
		manager.node_mesh_y.mesh,
		manager.node_mesh_z.mesh
	)
	
	var level_count: = get_filecount()
	
	ResourceSaver.save(
		current_level,
		path_at_index(level_count),
		ResourceSaver.FLAG_COMPRESS
	)

func load_level():
	if _load_index >= get_filecount():
		return
	
	var level = load(path_at_index(_load_index)) as LevelData
	
	if level == null:
		return
	
	manager.node_mesh_x.mesh = level.mesh_x
	manager.node_mesh_y.mesh = level.mesh_y
	manager.node_mesh_z.mesh = level.mesh_z
	
	var downscale = Vector3.ONE / 16.0 # Crime against humanity, I have to scale everything down, whoops
	
	manager.node_mesh_x.scale = downscale
	manager.node_mesh_y.scale = downscale
	manager.node_mesh_z.scale = downscale
	
	var material_x: = ShaderMaterial.new()
	var material_y: = ShaderMaterial.new()
	var material_z: = ShaderMaterial.new()
	
	material_x.shader = load("res://materials/shaders/flat_colour.gdshader")
	material_y.shader = load("res://materials/shaders/flat_colour.gdshader")
	material_z.shader = load("res://materials/shaders/flat_colour.gdshader")
	
	if level.uses_vertexcolour:
		material_x.set_shader_parameter("use_vertex_colour", true)
		material_y.set_shader_parameter("use_vertex_colour", true)
		material_z.set_shader_parameter("use_vertex_colour", true)
	else:
		material_x.set_shader_parameter("colour", Vector3(1.0, 0.0, 0.0))
		material_y.set_shader_parameter("colour", Vector3(0.0, 1.0, 0.0))
		material_z.set_shader_parameter("colour", Vector3(0.0, 0.0, 1.0))
	
	manager.node_mesh_x.set_surface_override_material(0, material_x)
	manager.node_mesh_y.set_surface_override_material(0, material_y)
	manager.node_mesh_z.set_surface_override_material(0, material_z)
	
	manager.translate_steps_x = level.translate_steps.x
	manager.translate_steps_y = level.translate_steps.y
	manager.translate_steps_z = level.translate_steps.z
	
	manager.rotate_steps_x = level.rotate_steps.x
	manager.rotate_steps_y = level.rotate_steps.y
	manager.rotate_steps_z = level.rotate_steps.z
	
	manager.apply_transform()
	
	_current_level = _load_index
	
func _input(event: InputEvent):
	if event.is_action_pressed("save", false, true):
		save_level()
	elif event.is_action_pressed("load", false, true):
		load_level()
	elif event is InputEventKey && event.is_pressed():
		var number: int = event.physical_keycode - 48
		
		if number >= 0 && number < 10:
			_load_index = number
