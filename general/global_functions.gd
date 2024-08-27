extends Node

## returns a vector array without duplicates
func vector_array_unique(array: Array[Vector2]) -> Array[Vector2]:
	var unique: Array[Vector2] = []

	for item in array:
		var is_unique: bool = true
		for u: Vector2 in unique:
			if item.is_equal_approx(u):
				is_unique = false
				break;
		if is_unique:
			unique.append(item)
	
	return unique

func f_within_error(a: float, b: float, error: float) -> bool:
	return abs(a - b) < error
