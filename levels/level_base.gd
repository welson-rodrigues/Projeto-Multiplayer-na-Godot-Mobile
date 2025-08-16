# level_base.gd
extends Node2D

signal change_level_requested(level_path)

# Adicionamos uma propriedade para marcar se o nível é um tutorial
@export var is_tutorial: bool = false
