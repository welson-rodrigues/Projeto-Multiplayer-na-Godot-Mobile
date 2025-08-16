extends "res://levels/level_base.gd" 

#signal change_level_requested(level_path)


func _on_touch_screen_button_pressed() -> void:
	Client.send("request_level_change", { "level_path": "res://levels/level_02.tscn" })
