extends CharacterBody2D

const MAX_SPEED: float = 200.0
const GRAVITY: float = 9.8
const ACCELERATION: float = 500.0
const FRICTION: float = 300.0
const MASS: float = 45.0

#var velocity: Vector2 = Vector2.ZERO
var _input_dir: Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
	
func _process(_delta) -> void:
	if _input_dir != Vector2.ZERO:
		Client.send("position", { "x": position.x, "y": position.y })


func _physics_process(_delta) -> void:
	_input_dir.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	
	if _input_dir.length() != 0:
		# Normalize the magnitude of the vector
		_input_dir = _input_dir.normalized()
		# Applies more velocity to the current velocity
		velocity += _input_dir * ACCELERATION
		# Don't allow higher velocity then MAX_SPEED
		velocity = velocity.limit_length(MAX_SPEED)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		
	velocity.y += MASS * GRAVITY
		
	set_velocity(velocity)
	set_up_direction(Vector2.UP)
	move_and_slide()
