# main.gd (VERSÃO CORRIGIDA)
extends Node

@export var game_manager_scene: PackedScene
@export var first_level_scene: PackedScene

@onready var lobby = $Lobby
@onready var transition = $Transition
@onready var game_manager_container = $GameManagerContainer
@onready var level_container = $LevelContainer
@onready var player_list = $PlayerList

var current_level_node = null
var game_manager = null

func _ready() -> void:
	Client.connect("level_change_commanded", Callable(self, "change_level"))
	Client.connect("game_started", Callable(self, "_on_game_started"))
	Client.connect("partner_disconnected", Callable(self, "_on_partner_disconnected"))

func _on_game_started(content: Dictionary) -> void:
	lobby.hide()

	if not is_instance_valid(game_manager):
		game_manager = game_manager_scene.instantiate()
		game_manager_container.add_child(game_manager)
		game_manager.set_player_list(player_list)

	# Carrega o primeiro nível e chama a inicialização completa
	change_level(first_level_scene)
	game_manager.initialize_game(content, current_level_node)
	
	transition.get_node("AnimationPlayer").play("transit")
	
func _on_partner_disconnected(content: Dictionary) -> void:
	print("Seu parceiro desconectou. UUID: %s" % content.uuid)
	get_tree().reload_current_scene()

func change_level(level_to_load) -> void:
	if current_level_node:
		current_level_node.queue_free()

	var level_scene: PackedScene
	if level_to_load is String:
		level_scene = load(level_to_load)
	elif level_to_load is PackedScene:
		level_scene = level_to_load
	else:
		push_error("Tipo de nível inválido para carregar.")
		return

	current_level_node = level_scene.instantiate()
	level_container.add_child(current_level_node)
	
	# ADIÇÃO IMPORTANTE AQUI:
	# Se o GameManager já existe, significa que não é o primeiro nível.
	# Então, chamamos a função para reposicionar os jogadores.
	if is_instance_valid(game_manager):
		game_manager.reposition_players_for_level(current_level_node)
