extends Node

## returns a vector array without duplicates
func vector_array_unique(array: Array[Vector2], float_error: float) \
		-> Array[Vector2]:
	var unique: Array[Vector2] = []

	for item in array:
		var is_unique: bool = true
		for u: Vector2 in unique:
			if (item - u).length() < float_error:
				is_unique = false
				break;
		if is_unique:
			unique.append(item)
	
	return unique

func vector_array_has(array: Array[Vector2], value: Vector2, float_error: float) -> bool:
	for vec in array:
		if (vec-value).length() < float_error:
			return true
	return false

func f_within_error(a: float, b: float, error: float) -> bool:
	return abs(a - b) < error

## returns whether the first vector is "greater" than the second vector by
## first checking x and then y
func custom_sort_vec2(a: Vector2, b: Vector2, float_error: float) -> bool:
	if abs(a.x - b.x) < float_error:
		return a.y > b.y
	return a.x > b.x

func vectors_approx_equal(a: Vector2, b: Vector2, float_error: float) -> bool:
	return (a - b).length() < float_error
