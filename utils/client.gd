extends Node

signal joined_server
signal spawn_local_player
signal spawn_new_player
signal spawn_network_players
signal update_position
signal new_chat_message
signal player_disconnected  #sinal
signal update_action

var uuid: String = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
var _peer := WebSocketPeer.new()
var _connected := false

func _process(_delta):
	if _connected:
		_peer.poll()

		while _peer.get_available_packet_count() > 0:
			var data = _peer.get_packet().get_string_from_utf8()
			var parsed_data = JSON.parse_string(data)
			if typeof(parsed_data) == TYPE_DICTIONARY:
				_handle_incoming_data(parsed_data)

func connect_to_server():
	print("Tentando conectar...")
	var err = _peer.connect_to_url("wss://servidor-multiplayer-websocket.onrender.com")  #URL do seu servidor online.
	if err != OK:
		push_error("Erro ao conectar: %s" % err)
	else:
		_connected = true
		print("Conectando...")

func send(cmd: String, content: Dictionary):
	var json = JSON.stringify({ "cmd": cmd, "content": content })
	_peer.send_text(json)

func _handle_incoming_data(data: Dictionary):
	match data.cmd:
		"joined_server":
			uuid = data.content.uuid
			emit_signal("joined_server")
		"spawn_local_player":
			emit_signal("spawn_local_player", data.content.player)
		"spawn_new_player":
			emit_signal("spawn_new_player", data.content.player)
		"spawn_network_players":
			emit_signal("spawn_network_players", data.content.players)
		"update_position":
			emit_signal("update_position", data.content)
		"new_chat_message":
			emit_signal("new_chat_message", data.content)
		"player_disconnected":  #comando recebido
			emit_signal("player_disconnected", data.content)
		"update_action":
			emit_signal("update_action", data.content)
		_:
			push_error("Comando não reconhecido: %s" % data)
