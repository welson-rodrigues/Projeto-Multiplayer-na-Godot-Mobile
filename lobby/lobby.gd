# lobby.gd
extends Control

@onready var create_button = $CreateButton
@onready var join_button = $JoinButton
@onready var code_input = $CodeInput
@onready var info_label = $InfoLabel

func _ready() -> void:
	# Conecta aos sinais do Client para atualizar a UI
	Client.connect("room_created", Callable(self, "_on_room_created"))
	Client.connect("server_error", Callable(self, "_on_server_error"))
	
	# Conecta ao servidor assim que o lobby aparece
	Client.connect_to_server()
	info_label.text = "Conectando ao servidor..."
	# Você pode adicionar um sinal no Client para "connection_successful"
	# para mudar este texto para "Conectado!" e habilitar os botões.

func _on_CreateButton_pressed() -> void:
	info_label.text = "Criando sala..."
	Client.send("create_room", {})

func _on_JoinButton_pressed() -> void:
	var code = code_input.text
	if code.is_empty():
		info_label.text = "Por favor, digite um código."
		return
	info_label.text = "Entrando na sala %s..." % code
	Client.send("join_room", { "code": code })

func _on_room_created(content: Dictionary) -> void:
	create_button.disabled = true
	join_button.disabled = true
	code_input.editable = false
	info_label.text = "Sala criada! Código: %s\nAguardando seu amigo..." % content.code

func _on_server_error(content: Dictionary) -> void:
	info_label.text = "Erro: %s" % content.msg


func _on_create_button_pressed() -> void:
	info_label.text = "Criando sala..."
	Client.send("create_room", {})


func _on_join_button_pressed() -> void:
	var code = code_input.text
	if code.is_empty():
		info_label.text = "Por favor, digite um código."
		return
	info_label.text = "Entrando na sala %s..." % code
	Client.send("join_room", { "code": code })
