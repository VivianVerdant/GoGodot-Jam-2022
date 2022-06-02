tool
extends Path2D

export var children: Array
onready var follow = $path_follow
onready var animation_player = $animation_player

export var speed = 1.0 setget setspeed
export var preview = true setget playback



func _ready():
	preview = true
	animation_player.play("loop")

func add_child(node, def=false):
	follow.add_child(node)
	follow.move_child(node,0)
	children.append(node)

func setspeed(value):
	speed = value
	animation_player.playback_speed = speed

func playback(value):
	preview = value
	if value:
		animation_player.play("loop")
	else:
		animation_player.stop()
