extends Node2D

onready var health = $v_box_container/h_box_container/health
onready var energy = $v_box_container/h_box_container2/energy


func _ready():
	pass

func _on_player_ui_update_health(value):
	health.value = value
	health.update()
