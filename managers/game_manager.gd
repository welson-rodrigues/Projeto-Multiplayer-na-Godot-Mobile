# game_manager.gd (VERSÃO FINAL E COMPLETA)
extends Node

var local_player_scene = load("res://players/player.tscn")
var network_player_scene = load("res://players/network_player.tscn")

var player_list_node: Node2D

var local_player_data: Dictionary
var network_player_data: Dictionary

func set_player_list(p_list: Node2D):
	player_list_node = p_list

func _ready() -> void:
	Client.connect("update_position", Callable(self, "_on_update_position"))
	Client.connect("update_action", Callable(self, "_on_update_action"))

func initialize_game(game_data: Dictionary, level_node: Node) -> void:
	self.local_player_data = game_data.your_data
	self.network_player_data = game_data.other_player_data

	for child in player_list_node.get_children():
		child.queue_free()

	var prisoner_marker = level_node.find_child("PosicaoPrisioneiro")
	var helper_marker = level_node.find_child("PosicaoAjudante")

	if not prisoner_marker or not helper_marker:
		push_error("ERRO: Não foi possível encontrar os marcadores de posição no nível!")
		return

	var prisoner_pos = prisoner_marker.global_position
	var helper_pos = helper_marker.global_position
	
	var lp: CharacterBody2D = local_player_scene.instantiate()
	lp.name = local_player_data.uuid
	lp.set_meta("role", local_player_data.role)
	player_list_node.add_child(lp)
	
	var np: CharacterBody2D = network_player_scene.instantiate()
	np.name = network_player_data.uuid
	np.set_meta("role", network_player_data.role)
	player_list_node.add_child(np)

	# --- INÍCIO DA LÓGICA DE POSICIONAMENTO E TUTORIAL ---

	# Posiciona o jogador local
	if local_player_data.role == "prisioneiro":
		lp.global_position = prisoner_pos
	else:
		lp.global_position = helper_pos

	# Posiciona o jogador de rede
	if network_player_data.role == "prisioneiro":
		np.global_position = prisoner_pos
	else:
		np.global_position = helper_pos
		
	# APLICA A REGRA ESPECIAL DO TUTORIAL
	# (Usando a solução recomendada com a variável 'is_tutorial')
	if level_node.is_tutorial:
		# No tutorial, TODOS se movem, independente do papel.
		lp.set_physics_process(true)
		print("Nível tutorial! Todos os jogadores podem se mover.")
	else:
		# Em outros níveis, a regra normal do prisioneiro se aplica.
		if local_player_data.role == "prisioneiro":
			lp.set_physics_process(false)
			print("Meu papel: Prisioneiro. Estou preso neste nível!")
		else:
			# Garante que o ajudante sempre possa se mover
			lp.set_physics_process(true)
			print("Meu papel: Ajudante. Estou livre neste nível!")
	
	# --- FIM DA LÓGICA DE POSICIONAMENTO E TUTORIAL ---


func _on_update_position(content: Dictionary) -> void:
	var player_node = player_list_node.get_node_or_null(content.uuid)
	if is_instance_valid(player_node):
		player_node.position = Vector2(content.x, content.y)

func _on_update_action(content: Dictionary) -> void:
	var player_node = player_list_node.get_node_or_null(content.uuid)
	if is_instance_valid(player_node) and content.name == "jump":
		pass
