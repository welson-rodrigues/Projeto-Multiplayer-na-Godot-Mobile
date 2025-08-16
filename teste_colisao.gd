# Script para a cena teste_colisao.tscn
extends Node2D

@onready var player: CharacterBody2D = $Player
		
@onready var network_player: CharacterBody2D = $NetworkPlayer

const VELOCIDADE = 200.0

func _process(delta: float) -> void:
	# Controla o 'Player' com as setas
	var p_direcao = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	player.position += p_direcao * VELOCIDADE * delta
	
	# Controla o 'NetworkPlayer' com W, A, S, D
	var np_direcao = Vector2.ZERO
	if Input.is_key_pressed(KEY_A): np_direcao.x = -1
	if Input.is_key_pressed(KEY_D): np_direcao.x = 1
	if Input.is_key_pressed(KEY_W): np_direcao.y = -1
	if Input.is_key_pressed(KEY_S): np_direcao.y = 1
	network_player.position += np_direcao.normalized() * VELOCIDADE * delta
