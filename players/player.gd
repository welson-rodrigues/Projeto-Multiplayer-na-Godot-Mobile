# player.gd - Controlado pelo jogador local. Lê o teclado e envia dados.

extends CharacterBody2D

const MAX_SPEED: float = 200.0
const ACCELERATION: float = 500.0
const FRICTION: float = 1000.0
const JUMP_VELOCITY: float = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Esta função é chamada 10x por segundo pelo Timer para enviar a posição
func _on_timer_timeout():
	Client.send("position", { "x": position.x, "y": position.y })

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		# Avisa ao servidor que pulamos
		Client.send("action", { "name": "jump" })

	var input_axis = Input.get_axis("left", "right")
	
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, input_axis * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	move_and_slide()
