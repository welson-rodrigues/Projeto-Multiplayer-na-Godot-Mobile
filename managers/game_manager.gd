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

# Esta função agora só cria os jogadores, UMA VEZ.
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
	
	# Agora, ela chama a função de reposicionamento para o primeiro nível
	reposition_players_for_level(initial_level_node)

# NOVA FUNÇÃO! Esta será chamada para CADA nível.
func reposition_players_for_level(level_node: Node) -> void:
	# --- INÍCIO DA ALTERAÇÃO ---
	# LINHA DE SEGURANÇA: Se os dados dos jogadores ainda não foram definidos,
	# simplesmente pare a execução desta função para evitar erros.
	if not local_player_data or not network_player_data:
		return
	# --- FIM DA ALTERAÇÃO ---

	var prisoner_marker = level_node.find_child("PosicaoPrisioneiro", true, false)
	var helper_marker = level_node.find_child("PosicaoAjudante", true, false)

	if not prisoner_marker or not helper_marker:
		push_error("ERRO: Não encontrou marcadores de posição no nível: " + level_node.scene_file_path)
		return

	var prisoner_pos = prisoner_marker.global_position
	var helper_pos = helper_marker.global_position

	# Encontra os nós dos jogadores que já existem
	var lp: Node2D = player_list_node.get_node_or_null(local_player_data.uuid)
	var np: Node2D = player_list_node.get_node_or_null(network_player_data.uuid)

	if not lp or not np:
		push_error("ERRO: Jogadores não encontrados para reposicionar!")
		return

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
		
	# Aplica a regra do tutorial/prisão para o nível atual
	if level_node.is_tutorial:
		lp.set_physics_process(true)
		print("Nível tutorial carregado! Todos se movem.")
	else:
		lp.set_physics_process(true)
		if local_player_data.role == "prisioneiro":
			#lp.set_physics_process(false)
			print("Nível normal carregado! Prisioneiro está preso.")
		else:
			#lp.set_physics_process(true)
			print("Nível normal carregado! Ajudante está livre.")

func _on_update_position(content: Dictionary) -> void:
	var player_node = player_list_node.get_node_or_null(content.uuid)
	if is_instance_valid(player_node):
		player_node.position = Vector2(content.x, content.y)

func _on_update_action(content: Dictionary) -> void:
	# O 'content' vem do outro jogador.
	# Não precisamos da variável 'player_node' aqui, pois a ação afeta o nível.
	
	# Verifica se a ação é para libertar o prisioneiro
	if content.name == "free_prisoner":
		# Apenas o prisioneiro deve reagir a este comando para apagar as paredes.
		# Isso evita que o ajudante apague as paredes do seu próprio jogo sem querer.
		if local_player_data.role == "prisioneiro":
			print("Recebido comando para libertar! Apagando as paredes da prisão.")
			# Este comando encontra todos os nós no grupo e os apaga!
			get_tree().call_group("ParedesDaPrisao", "queue_free")
