extends Node

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc_menu"):
		get_tree().quit()
