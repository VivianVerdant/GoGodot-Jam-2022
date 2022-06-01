tool
extends Area2D

export var size = Vector2(16,16) setget set_size

func _ready():
	if not Engine.editor_hint:
		$sprite.free()

func _notification(what):
	if not Engine.editor_hint:
		return
	
	match what:
		2000:
			move_snap()
		_:
			pass

func set_size(value):
	size = value
	$collision_shape_2d.shape.extents = value

func move_snap():
	global_position.x = floor(global_position.x / 8) * 8
	global_position.y = floor(global_position.y / 8) * 8


func _on_up_assist_body_entered(body):
	if body is Player and body.dy < 0:
		body.no_grav = true


func _on_up_assist_body_exited(body):
	if body is Player:
		body.no_grav = false
