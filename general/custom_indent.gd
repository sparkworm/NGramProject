extends Node

var indent_count: int = 0

func increase_indent(amnt:=1) -> void:
	indent_count += amnt

func decrease_indent(amnt:=1) -> void:
	indent_count -= amnt
	if indent_count < 0:
		print_rich("[color=red][b]INDENT COUNT LESS THAN 0![/b][/color]")

func set_indent(amnt) -> void:
	indent_count = amnt
	if indent_count < 0:
		print_rich("[color=red][b]INDENT COUNT LESS THAN 0![/b][/color]")

func _to_string() -> String:
	var s: String = ""
	for i in range(1,indent_count):
		s += "\t"
	return s
