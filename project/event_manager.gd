extends Node

var paused
var can_pause = true

func _ready():
	pass

signal room_entered(value)

signal player_death
