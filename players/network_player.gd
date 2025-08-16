# network_player.gd - VERSÃO ATUALIZADA

extends CharacterBody2D

# Certifique-se de que seu nó de imagem se chama "Sprite2D"
# ou mude o nome aqui para corresponder.
@onready var network_player: CharacterBody2D = $"."


# Esta é a função que o GameManager vai chamar
#func jump():
	## Um tween é uma ferramenta para animar propriedades de forma simples
	#var tween = create_tween()
	## Anima a posição Y do sprite para cima (-30 pixels) em 0.2 segundos
	#tween.tween_property(network_player, "position:y", -30, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	## Em seguida, anima a posição Y de volta para 0 em 0.3 segundos (a "queda")
	#tween.tween_property(network_player, "position:y", 0, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
