class_name NGramCreationUI
extends Control

signal create_button_pressed(point_num: int, radius: float)
signal generate_intersection_points
signal clear_all_points
signal fragment_lines_button_pressed
signal count_polygons_button_pressed

@export var gram_points_field: LineEdit
@export var gram_radius_field: LineEdit
@export var create_gram_button: Button
@export var generate_i_p_button: Button
@export var clear_all_points_button: Button
@export var count_polygons_button: Button
@export var fragment_lines_button: Button


func clear_text_fields() -> void:
	gram_points_field.text = ""
	gram_points_field.release_focus()
	gram_radius_field.text = ""
	gram_radius_field.release_focus()

func _on_create_n_gram_button_pressed():
	var point_num: int = int(gram_points_field.text)
	var radius: float = float(gram_radius_field.text)
	clear_text_fields()
	create_button_pressed.emit(point_num, radius)
	create_gram_button.release_focus()

func _on_clear_all_points_button_pressed():
	clear_text_fields()
	clear_all_points.emit()
	clear_all_points_button.release_focus()


func _on_generate_intersection_points_pressed():
	generate_intersection_points.emit()
	generate_i_p_button.release_focus()


func _on_fragment_lines_button_pressed() -> void:
	fragment_lines_button_pressed.emit()
	fragment_lines_button.release_focus()


func _on_count_polygons_button_pressed() -> void:
	count_polygons_button_pressed.emit()
	count_polygons_button.release_focus()
