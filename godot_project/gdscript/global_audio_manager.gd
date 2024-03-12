extends Node

var music_level: = 0.0
var fx_level: = 0.0

signal music_level_update
signal fx_level_update

signal button_pressed

signal puzzle_solved

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func emit_button_press():
	button_pressed.emit()
