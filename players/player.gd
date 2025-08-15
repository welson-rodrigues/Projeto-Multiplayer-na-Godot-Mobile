# player.gd - VERSÃO ATUALIZADA

extends CharacterBody2D

const MAX_SPEED: float = 200.0
const ACCELERATION: float = 500.0
const FRICTION: float = 1000.0
const JUMP_VELOCITY: float = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


# Esta nova função é chamada 10x por segundo pelo Timer
func _on_timer_timeout():
	# Enviamos a posição para o servidor em um intervalo fixo para evitar o lag
	Client.send("position", { "x": position.x, "y": position.y })


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		# MUDANÇA 1: Avisa ao servidor que pulamos
		Client.send("action", { "name": "jump" })

	var input_axis = Input.get_axis("left", "right")
	
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, input_axis * MAX_SPEED, ACCELERATION * delta)
		# MUDANÇA 2: A linha de envio de posição foi REMOVIDA daqui!
		# Não enviamos mais a cada frame.
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	move_and_slide()
