# game_manager.gd - VERSÃO SIMPLIFICADA

extends Node

var local_player = load("res://players/player.tscn")
var network_player = load("res://players/network_player.tscn")

# Esta variável vai guardar uma referência DIRETA para a lista de jogadores
var player_list_node: Node2D

# Esta função será chamada pelo Main para nos dizer onde está a lista
func set_player_list(p_list: Node2D):
	player_list_node = p_list

func _ready():
	# Os connects de sempre
	Client.connect("spawn_local_player", Callable(self, "_on_spawn_local_player"))
	Client.connect("spawn_new_player", Callable(self, "_on_spawn_new_player"))
	Client.connect("spawn_network_players", Callable(self, "_on_spawn_network_players"))
	Client.connect("update_position", Callable(self, "_on_update_position"))
	Client.connect("player_disconnected", Callable(self, "_on_player_disconnected"))
	Client.connect("update_action", Callable(self, "_on_update_action"))
	
func _on_update_action(content: Dictionary):
	# Se a ação não for "jump", ignore por enquanto
	if content.name != "jump":
		return

	# Encontra o nó do jogador que enviou a ação
	var player_node = player_list_node.find_child(content.uuid)
	
	# Se o jogador existir, chama a função jump() que criamos nele
	if player_node:
		player_node.jump()

func _on_spawn_local_player(player: Dictionary) -> void:
	var lp: CharacterBody2D = local_player.instantiate()
	lp.set_name(player.uuid)
	lp.position = Vector2(player.x, player.y)
	player_list_node.add_child(lp) # Usa a referência direta!

func _spawn_network_player(player: Dictionary) -> void:
	var np: CharacterBody2D = network_player.instantiate()
	np.set_name(player.uuid)
	np.position = Vector2(player.x, player.y)
	player_list_node.add_child(np) # Usa a referência direta!

func _on_update_position(content: Dictionary) -> void:
	for player_node in player_list_node.get_children():
		if player_node.name == content.uuid:
			player_node.position = Vector2(content.x, content.y)

func _on_player_disconnected(content: Dictionary) -> void:
	for player_node in player_list_node.get_children():
		if player_node.name == content.uuid:
			player_node.queue_free()
			print("👋 Jogador saiu:", content.uuid)
			
# Funções _on_spawn_new_player e _on_spawn_network_players continuam iguais
func _on_spawn_new_player(player: Dictionary) -> void:
	_spawn_network_player(player)
	
func _on_spawn_network_players(players: Array) -> void:
	for player in players:
		if player.uuid != Client.uuid:
			_spawn_network_player(player)
