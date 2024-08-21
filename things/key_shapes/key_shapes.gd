extends Node2D

@export var key_spacing: int = 30
@export var line_spacing: int = 100
@export var key_scene: PackedScene
@export var line_scene: PackedScene
@export var starting_color: Color = Color(1, 1, 1)

var key_dict: Dictionary

var supported_keys: Array[String] = [
	"1234567890",
	"qwertyuiop[]",
	"asdfghjkl;'",
	"zxcvbnm,./",
	]

var currently_animated_line: WordLine = null

@onready var keys_parent = $Keys
@onready var lines_parent = $Lines
@onready var text_edit = $CanvasLayer/TextEdit

func _ready() -> void:
	create_keys()
	initialize_key_dict()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("enter"):
		draw()
		move_lines()

#region layout

func move_lines() -> void:
	var num_lines: int = lines_parent.get_child_count()
	
	var num_columns: int = sqrt(num_lines) + 0.5
	
	for row: int in range(0, ceil(float(num_lines) / num_columns)):
		#print("rows: ", row)
		for col: int in range(0, num_columns):
			#print("\tcols: ", col)
			var line_idx: int = row * num_columns + col
			if line_idx >= num_lines:
				return
			var new_position: Vector2 = line_spacing * Vector2(col, row)
			var tweener: Tween = create_tween()
			tweener.tween_property(lines_parent.get_child(line_idx), \
					"position", new_position, 1.0)
	

#endregion

#region initialization

func create_keys() -> void:
	var x_pos: int = 0
	var y_pos: int = 0
	for key_string: String in supported_keys:
		x_pos = 0
		for c: String in key_string:
			var new_key: KeyPos = key_scene.instantiate()
			new_key.character = c
			new_key.position = Vector2(x_pos, y_pos)
			keys_parent.add_child(new_key)
			x_pos += key_spacing
		y_pos += key_spacing
		

func initialize_key_dict() -> void:
	var keys: Array = keys_parent.get_children()
	for key: KeyPos in keys:
		key_dict[key.character.to_lower()] = key.position

#endregion

#region drawing

func draw() -> void:
	# clear previous lines
	for child in lines_parent.get_children():
		lines_parent.remove_child(child)
	
	var words_array: Array[String] = []
	words_array.assign(text_edit.text.split(" "))
	text_edit.clear()
	
	var color: Color = starting_color
	
	for word: String in words_array:
		draw_word(word, color)
		color.h = wrap(color.h + 0.2, 0, 1)

func draw_word(word: String, color: Color = Color(0,0,0)) -> void:
	var position_array: Array[Vector2] = word_to_position_array(word)
	var new_line: WordLine = line_scene.instantiate()
	new_line.modulate = color
	lines_parent.add_child(new_line)
	new_line.draw_word(position_array)
	#new_line.points = position_array
	#start_animate_line(new_line, position_array)

#endregion

#region word processing

## converts a string into a collection of vectors representing the location on 
## a keyboard that they would occupy
func word_to_position_array(word: String) -> Array[Vector2]:
	var position_array: Array[Vector2] = []
	for c:String in word:
		if key_dict.has(c.to_lower()):
			position_array.append(key_dict[c.to_lower()])
		else:
			#print("CAUTION: character ", c.to_lower(), " not a key in key_dict")
			pass
	return position_array

#endregion
