# game_manager.gd (Versão com atualização de papéis)
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

func initialize_game(game_data: Dictionary, initial_level_node: Node) -> void:
	self.local_player_data = game_data.your_data
	self.network_player_data = game_data.other_player_data

	for child in player_list_node.get_children():
		child.queue_free()
	
	var lp: CharacterBody2D = local_player_scene.instantiate()
	lp.name = local_player_data.uuid
	lp.set_meta("role", local_player_data.role)
	player_list_node.add_child(lp)
	
	var np: CharacterBody2D = network_player_scene.instantiate()
	np.name = network_player_data.uuid
	np.set_meta("role", network_player_data.role)
	player_list_node.add_child(np)
	
	reposition_players_for_level(initial_level_node)

# NOVA FUNÇÃO para atualizar os papéis a cada nível
func update_roles(new_roles: Dictionary) -> void:
	if not local_player_data or not network_player_data:
		return

	var local_uuid = local_player_data.uuid
	var network_uuid = network_player_data.uuid

	if new_roles.has(local_uuid) and new_roles.has(network_uuid):
		local_player_data.role = new_roles[local_uuid]
		network_player_data.role = new_roles[network_uuid]
		# Atualiza também o meta do nó do jogador, pode ser útil
		var lp = player_list_node.get_node_or_null(local_uuid)
		if is_instance_valid(lp):
			lp.set_meta("role", local_player_data.role)
		
		print("--- Papéis Re-sorteados! Agora eu sou: %s ---" % local_player_data.role)
	else:
		push_error("Dados de novos papéis inválidos recebidos.")

func reposition_players_for_level(level_node: Node) -> void:
	if not local_player_data or not network_player_data:
		return

	var prisoner_marker = level_node.find_child("PosicaoPrisioneiro", true, false)
	var helper_marker = level_node.find_child("PosicaoAjudante", true, false)

	if not prisoner_marker or not helper_marker:
		return

	var prisoner_pos = prisoner_marker.global_position
	var helper_pos = helper_marker.global_position

	var lp: Node2D = player_list_node.get_node_or_null(local_player_data.uuid)
	var np: Node2D = player_list_node.get_node_or_null(network_player_data.uuid)

	if not lp or not np:
		return

	if local_player_data.role == "prisioneiro":
		lp.global_position = prisoner_pos
	else:
		lp.global_position = helper_pos

	if network_player_data.role == "prisioneiro":
		np.global_position = prisoner_pos
	else:
		np.global_position = helper_pos
		
	# A lógica da prisão física continua a mesma, baseada nos novos papéis
	lp.set_physics_process(true)
	if level_node.is_tutorial:
		print("Nível tutorial carregado! Todos se movem.")
	else:
		if local_player_data.role == "prisioneiro":
			print("Nível normal carregado! Prisioneiro está preso pelas paredes.")
		else:
			print("Nível normal carregado! Ajudante está livre.")

func _on_update_position(content: Dictionary) -> void:
	var player_node = player_list_node.get_node_or_null(content.uuid)
	if is_instance_valid(player_node):
		player_node.position = Vector2(content.x, content.y)

func _on_update_action(content: Dictionary) -> void:
	if content.name == "free_prisoner":
		if local_player_data.role == "prisioneiro":
			get_tree().call_group("ParedesDaPrisao", "queue_free")
