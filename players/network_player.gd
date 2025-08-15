# network_player.gd - VERSÃO FINAL COM INTERPOLAÇÃO

extends CharacterBody2D

# Onde queremos chegar (recebido da rede)
var target_position: Vector2

# Quão rápido vamos nos mover em direção ao alvo.
# Experimente valores entre 5 e 20.
@export var interpolation_speed: float = 15.0

@onready var network_player: CharacterBody2D = $"."


func _ready():
	# Quando o jogador de rede é criado, sua posição inicial é o alvo.
	target_position = position

# Esta função será chamada pelo GameManager para ATUALIZAR O ALVO.
func set_target_position(new_position: Vector2):
	target_position = new_position

# O _physics_process agora será usado para o movimento suave.
func _physics_process(delta: float):
	# A função lerp (Linear Interpolation) faz a mágica.
	# Ela calcula um ponto entre a posição atual e o alvo.
	# A cada frame, nos movemos uma fração do caminho (definida pelo interpolation_speed).
	position = position.lerp(target_position, delta * interpolation_speed)

# A função de pulo continua a mesma
func jump():
	var tween = create_tween()
	tween.tween_property(network_player, "position:y", -30, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(network_player, "position:y", 0, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
