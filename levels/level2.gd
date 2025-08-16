extends "res://levels/level_base.gd" 

#signal change_level_requested(level_path)


func _on_touch_screen_button_pressed() -> void:
	# Quando o botão for pressionado, emita o sinal com o caminho do próximo nível
	Client.send("request_level_change", { "level_path": "res://levels/level_03.tscn" })
