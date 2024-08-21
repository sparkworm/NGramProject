## A camera that can be controlled by specified keys
class_name ControllableCamera2D
extends Camera2D

@export_category("Controls")
@export var key_up: String = "cam_up"
@export var key_down: String = "cam_down"
@export var key_left: String = "cam_left"
@export var key_right: String = "cam_right"
@export var key_zoom_in: String = "cam_zoom_in"
@export var key_zoom_out: String = "cam_zoom_out"

@export_category("Movement")
## maximum speed in pixels/s
@export var move_max_speed: int = 100
## acceleration in pixels/s^2
@export var move_acceleration: int = 200
## the acceleration at which the camera slows down with no input in pixels/s^2
@export var move_decceleration: int = 100
## The amount the zoom is multiplied by to zoom in / the amount the zoom is
## divided by to zoom out.
## [br] Should be more than one
@export var zoom_amnt: float = 1.1


var velocity: Vector2

func _process(delta: float) -> void:
	var acceleration_vector: Vector2 = move_acceleration * \
			Input.get_vector(key_left, key_right, key_up, key_down)
	
	
	# run if the camera is moving or if there is input
	
	if velocity != Vector2.ZERO or acceleration_vector != Vector2.ZERO:
		
		if acceleration_vector.x == 0:
			velocity.x = _deccelerate(velocity.x, move_decceleration, delta)
		else: 
			velocity.x = _accelerate(velocity.x, acceleration_vector.x, delta)
		if acceleration_vector.y == 0:
			velocity.y = _deccelerate(velocity.y, move_decceleration, delta)
		else: 
			velocity.y = _accelerate(velocity.y, acceleration_vector.y, delta)
	
	position += (velocity / zoom.x) * delta
	
	if Input.is_action_just_pressed("cam_zoom_in"):
		_zoom_in()
	if Input.is_action_just_pressed("cam_zoom_out"):
		_zoom_out()

func _zoom_in() -> void:
	zoom *= zoom_amnt

func _zoom_out() -> void:
	zoom /= zoom_amnt

func _deccelerate(vel: float, amnt: float, delta: float) -> float:
	if vel == 0:
		return 0
	var sign_of_vel: int = vel/abs(vel)
	return max(0, (abs(vel)-amnt*delta)) * sign_of_vel

func _accelerate(vel: float, amnt: float, delta: float) -> float:
	return clamp(vel + amnt * delta, -move_max_speed, move_max_speed)
