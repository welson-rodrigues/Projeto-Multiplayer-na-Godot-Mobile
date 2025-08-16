# alavanca.gd
extends Area2D

# Carrega as texturas que vamos usar
@export var textura_ligada: Texture2D
@export var textura_desligada: Texture2D

@onready var sprite = $Sprite2D

# Variáveis para controlar o estado
var jogador_na_area: CharacterBody2D = null
var ja_foi_ativada: bool = false

func _ready() -> void:
	# Configura a imagem inicial
	sprite.texture = textura_desligada
	
	# Conecta os sinais da própria Area2D
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node) -> void:
	# Verifica se quem entrou é o jogador local
	# Usamos o nome do nó, que é o UUID do jogador
	if body.name == Client.uuid:
		print("Jogador entrou na área da alavanca")
		jogador_na_area = body

func _on_body_exited(body: Node) -> void:
	# Verifica se quem saiu é o jogador que estava na área
	if body == jogador_na_area:
		print("Jogador saiu da área da alavanca")
		jogador_na_area = null

# Esta função verifica o input do jogador a cada frame
func _process(_delta: float) -> void:
	# Se a alavanca ainda não foi ativada, E
	# se o jogador local está na área, E
	# se ele apertou o botão de ação...
	if not ja_foi_ativada and jogador_na_area and Input.is_action_just_pressed("ui_accept"):
		ativar_alavanca()

func ativar_alavanca() -> void:
	print("Alavanca ativada!")
	ja_foi_ativada = true
	sprite.texture = textura_ligada # Muda a imagem
	
	# Envia a mensagem para o servidor que vai libertar o prisioneiro
	Client.send("action", {"name": "free_prisoner"})
