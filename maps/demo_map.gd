extends Node2D
# Map should probably not contain network spawn code, but this is a prototype

var local_player = load("res://players/player.tscn")
var network_player = load("res://players/network_player.tscn")

@onready var player_list = $PlayerList


# Called when the node enters the scene tree for the first time.
func _ready():
	Client.connect("spawn_local_player", Callable(self, "_on_spawn_local_player"))
	Client.connect("spawn_new_player", Callable(self, "_on_spawn_new_player"))
	Client.connect("spawn_network_players", Callable(self, "_on_spawn_network_players"))
	Client.connect("update_position", Callable(self, "_on_update_position"))
	Client.connect("player_disconnected", Callable(self, "_on_player_disconnected"))

	
	
func _on_spawn_local_player(player: Dictionary) -> void:
	var lp: CharacterBody2D = local_player.instantiate()
	lp.set_name(player.uuid)
	lp.position = Vector2(player.x, player.y)
	player_list.add_child(lp)
	
	
func _on_spawn_new_player(player: Dictionary) -> void:
	_spawn_network_player(player)
	
	
func _on_spawn_network_players(players: Array) -> void:
	for player in players:
		if player.uuid != Client.uuid:
			_spawn_network_player(player)


func _spawn_network_player(player: Dictionary) -> void:
	var np: CharacterBody2D = network_player.instantiate()
	np.set_name(player.uuid)
	np.position = Vector2(player.x, player.y)
	player_list.add_child(np)


func _on_update_position(content: Dictionary) -> void:
	for player in player_list.get_children():
		if player.name == content.uuid:
			player.position.x = content.x
			player.position.y = content.y


func _on_player_disconnected(content: Dictionary) -> void:
	for player in player_list.get_children():
		if player.name == content.uuid:
			player.queue_free()
			print("👋 Jogador saiu:", content.uuid)
