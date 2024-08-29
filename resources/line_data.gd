class_name LineData
extends Resource

var point0_pos: Vector2
var point1_pos: Vector2

func _init(pos1: Vector2, pos2: Vector2) -> void:
	point0_pos = pos1
	point1_pos = pos2

func has_point_within_error(point: Vector2, float_error: float) -> bool:
	return (point0_pos - point).length() < float_error or \
			(point1_pos - point).length() < float_error

## returns the value of the point that is NOT the point provided
func other_point(point: Vector2, float_error: float) -> Vector2:
	if (point0_pos - point).length() < float_error:
		return point1_pos
	elif (point1_pos - point).length() < float_error:
		return point0_pos
	print("ERROR: NEITHER POINT MATCHES SPECIFIED POINT")
	return Vector2.INF

func _to_string() -> String:
	return str(point0_pos, "---", point1_pos)
