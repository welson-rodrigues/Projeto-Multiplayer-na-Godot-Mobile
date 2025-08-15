# main.gd - VERSÃO FINAL COM TROCA DE NÍVEL

extends Node

@export var game_manager_scene: PackedScene
@export var first_level_scene: PackedScene

@onready var lobby = $Lobby
@onready var transition = $Transition
@onready var game_manager_container = $GameManagerContainer
@onready var level_container = $LevelContainer
@onready var player_list = $PlayerList # Referência para o novo PlayerList

var current_level_node = null

func _ready():
	Client.connect("joined_server", Callable(self, "_on_joined_server"))

func _on_joined_server() -> void:
	lobby.hide()

	# Instancia o GameManager
	var game_manager = game_manager_scene.instantiate()
	game_manager_container.add_child(game_manager)
	
	# DIZ AO GAMEMANAGER ONDE ESTÁ O PLAYERLIST!
	game_manager.set_player_list(player_list)

	# Carrega o primeiro nível
	change_level(first_level_scene)
	
	# Transição...
	transition.get_node("AnimationPlayer").play("transit")
	# ... (resto do código de transição)

func change_level(level_to_load):
	# 1. Apaga o nível antigo, se existir
	if current_level_node:
		current_level_node.queue_free()

	# 2. Carrega e instancia o novo nível
	var level_scene
	if level_to_load is String:
		level_scene = load(level_to_load)
	else:
		level_scene = level_to_load
	
	current_level_node = level_scene.instantiate()
	
	# 3. Conecta o sinal do novo nível para futuras trocas
	current_level_node.connect("change_level_requested", Callable(self, "change_level"))
	
	# 4. Adiciona o novo nível ao container
	level_container.add_child(current_level_node)
	
	# 5. Reposiciona o jogador (simples por enquanto)
	# (Em um jogo real, você pegaria uma posição de um Marker2D no nível)
	var local_player = player_list.find_child(Client.uuid)
	if local_player:
		local_player.position = Vector2(250, 525) # Posição inicial padrão
