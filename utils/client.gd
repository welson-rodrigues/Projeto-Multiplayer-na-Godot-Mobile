# client.gd
extends Node

# Sinais de Jogo
signal game_started(content)
signal update_position
signal update_action
signal new_chat_message
signal partner_disconnected(content)
signal level_change_commanded(level_path)

# Sinais de Lobby
signal room_created(content)
signal server_error(content)

var uuid: String = ""
var _peer := WebSocketPeer.new()
var _connected := false

func _process(_delta: float) -> void:
	if _connected:
		_peer.poll()
		while _peer.get_available_packet_count() > 0:
			var data = _peer.get_packet().get_string_from_utf8()
			var parsed_data = JSON.parse_string(data)
			if typeof(parsed_data) == TYPE_DICTIONARY:
				_handle_incoming_data(parsed_data)

func connect_to_server() -> void:
	print("Tentando conectar...")
	var url = "wss://servidor-multiplayer-websocket.onrender.com"
	var err = _peer.connect_to_url(url)
	if err != OK:
		push_error("Erro ao conectar: %s" % err)
	else:
		_connected = true
		print("Conectando...")

func send(cmd: String, content: Dictionary) -> void:
	if not _connected or _peer.get_ready_state() != WebSocketPeer.STATE_OPEN:
		print("Não conectado, não foi possível enviar a mensagem.")
		return
	var json = JSON.stringify({ "cmd": cmd, "content": content })
	_peer.send_text(json)

func _handle_incoming_data(data: Dictionary) -> void:
	match data.cmd:
		# Comandos de Lobby
		"room_created":
			uuid = data.content.uuid
			emit_signal("room_created", data.content)
		"error":
			emit_signal("server_error", data.content)
		
		# Comandos de Jogo
		"game_started":
			uuid = data.content.your_data.uuid
			emit_signal("game_started", data.content)
		"partner_disconnected":
			emit_signal("partner_disconnected", data.content)
		"update_position":
			emit_signal("update_position", data.content)
		"update_action":
			emit_signal("update_action", data.content)
		"change_level":
			emit_signal("level_change_commanded", data.content.level_path)
		"new_chat_message":
			emit_signal("new_chat_message", data.content)
		_:
			push_error("Comando não reconhecido: %s" % data.cmd)
