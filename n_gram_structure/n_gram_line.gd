## A node representing a line connecting two points on an n-gram
## [br][br]
## should update its endpoint positions when the points move
class_name NGramLine
extends Line2D

var point0: NGramPoint
var point1: NGramPoint

func init(p0: NGramPoint, p1: NGramPoint) -> void:
	point0 = p0
	point1 = p1
	
	move_point(point0.global_position, 0)
	move_point(point1.global_position, 1)
	
	var p0_move_callable: = Callable(self, "move_point").bind(0)
	var p1_move_callable: = Callable(self, "move_point").bind(1)
	
	point0.moved.connect(p0_move_callable)
	point1.moved.connect(p1_move_callable)

func move_point(pos: Vector2, idx: int) -> void:
	points[idx] = pos

func has_point(point: NGramPoint) -> bool:
	return point0 == point or point1 == point

func get_slope() -> float:
	return point0.position.angle_to_point(point1.position)

func get_point_of_intersection(other: NGramLine) -> Vector2:
	# find slopes of the two lines
	var m_a: float = tan(get_slope())
	var m_b: float = tan(other.get_slope())
	# if the slope is the same, stop calculation
	if is_equal_approx(m_a, m_b):
		return Vector2.INF
	var x_a: float = point0.position.x
	var x_b: float = other.point0.position.x
	var y_a: float = point0.position.y
	var y_b: float = other.point0.position.y
	
	var x: float = (m_a * x_a - m_b * x_b - y_a + y_b) / (m_a - m_b)
	var y: float = (m_b * y_a - m_a * y_b + (m_a * m_b) * (x_b - x_a)) / (m_b - m_a)
	
	return Vector2(x, y)

func is_point_on_line(pos: Vector2, float_error: float) -> bool:
	var lesser_x: float = min(point0.position.x, point1.position.x)
	var greater_x: float = max(point0.position.x, point1.position.x)
	if not abs(lesser_x - greater_x) < float_error:
		return ((lesser_x < pos.x) or (abs(lesser_x - pos.x) < float_error)) \
				and ((pos.x < greater_x) or (abs(greater_x - pos.x) < float_error))
	
	var lesser_y: float = min(point0.position.y, point1.position.y)
	var greater_y: float = max(point0.position.y, point1.position.y)
	return ((lesser_y < pos.y) or (abs(lesser_y - pos.y) < float_error)) \
				and ((pos.y < greater_y) or (abs(greater_y - pos.y)))
