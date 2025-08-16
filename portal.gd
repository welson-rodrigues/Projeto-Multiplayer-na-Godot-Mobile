# portal.gd
extends Area2D

# EXPORTAMOS uma variável para que possamos definir o próximo nível
# diretamente no editor do Godot para cada portal!
@export var proximo_nivel_path: String = ""

func _ready() -> void:
	# Conecta os sinais da própria Area2D
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node) -> void:
	# Se for o jogador local que entrou...
	if body.name == Client.uuid:
		print("Jogador local entrou no portal.")
		# ...avise o servidor, e diga qual é o próximo nível.
		Client.send("enter_portal", {"next_level": proximo_nivel_path})

func _on_body_exited(body: Node) -> void:
	# Se for o jogador local que saiu...
	if body.name == Client.uuid:
		print("Jogador local saiu do portal.")
		# ...avise o servidor.
		Client.send("leave_portal", {})
