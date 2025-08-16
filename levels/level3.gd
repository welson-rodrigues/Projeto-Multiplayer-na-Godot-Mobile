extends "res://levels/level_base.gd" 

#signal change_level_requested(level_path)


func _on_touch_screen_button_pressed() -> void:
	# Quando o botão for pressionado, emita o sinal com o caminho do próximo nível
	emit_signal("change_level_requested", "res://levels/level_02.tscn")
