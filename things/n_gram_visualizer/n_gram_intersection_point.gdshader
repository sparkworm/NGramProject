shader_type canvas_item;

uniform float min_size = 1.0;
uniform float max_size = 3.0;

uniform float grow_speed = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
	//VERTEX *= grow_amount * (sin(TIME * grow_speed) + 2.0) / 3.0;
	VERTEX *= max_size * (sin(TIME * grow_speed) + 1.0 + min_size) / (2.0 + min_size);
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
