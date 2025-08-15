extends CharacterBody2D

const MAX_SPEED: float = 200.0
const ACCELERATION: float = 500.0
const FRICTION: float = 1000.0 
const JUMP_VELOCITY: float = -400.0 # Pulo: Velocidade para cima (Y é negativo)

# Pega a gravidade das configurações do projeto para ser consistente
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	# Adiciona a gravidade
	# Só aplica gravidade se o personagem não estiver no chão
	if not is_on_floor():
		velocity.y += gravity * delta

	# Lógica do pulo
	# Verifica se a ação "jump" foi pressionada E se o personagem está no chão
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Pega a direção do input horizontal (-1 para esquerda, 1 para direita)
	var input_axis = Input.get_axis("left", "right")
	
	# Movimentação Horizontal
	if input_axis != 0:
		# Acelera na direção do input até a velocidade máxima
		velocity.x = move_toward(velocity.x, input_axis * MAX_SPEED, ACCELERATION * delta)
		if is_on_floor():
			# Envia a posição para o servidor apenas quando estiver se movendo no chão
			Client.send("position", { "x": position.x, "y": position.y })
	else:
		# Desacelera (aplica atrito) quando não há input
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	move_and_slide()
