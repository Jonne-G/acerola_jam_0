@tool
extends Button

@export var level_index: = 0

func _ready():
	set_text(str(level_index))
	
	if !FileAccess.file_exists("res://levels/level_%d.res" % [level_index]):
		modulate = Color.DIM_GRAY
	#elif level_index == 0: # Level not loaded by default
		#modulate = Color.SEA_GREEN
	else:
		modulate = Color.WHITE

func _input(event):
	if event is InputEventKey && event.is_pressed():
		var number: int = event.physical_keycode - 48
		
		if number < 0 || number > 9:
			return
		elif number == level_index:
			modulate = Color.SEA_GREEN
		else:
			modulate = Color.WHITE

func _pressed():
	GlobalFunctions._load_index = level_index
	GlobalFunctions.load_level()
