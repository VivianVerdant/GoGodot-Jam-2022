extends Node2D

var dx = 0
var dy = 0
var sleeping = true
export var target_offset: Vector2
export var speed = 25

export var melee_damage: int

export var initial_health: int
var health

var initial_pos

var layer
var mask

onready var effects_player = $effects_player

var waypoints = Array()

func _ready():
	health = initial_health
	initial_pos = position
	for child in get_children():
		if child is Position2D:
			var p = child.global_position
			child.set_as_toplevel(true)
			child.global_position = p
			waypoints.append(child)
	#global_position = waypoints[0].global_position + target_offset
	

func _physics_process(delta):
	if sleeping or effects_player.is_playing():
		return
	
	var pos = waypoints[0].global_position + target_offset
	var target = global_position.direction_to(pos) * speed
	var dist = (pos - global_position)
	if dist.length() < target.length():
		global_position += (dist / 1.0) * delta
	else:
		global_position += target * delta
	

	
	if dist.length() < 8.0:
		var w = waypoints.pop_front()
		waypoints.append(w)

func reset():
	sleeping = true
	visible = true
	health = initial_health
	position = initial_pos

func hit(damage, owner):
	print("bar")
	health -= damage
	if health < 0:
		die()
	effects_player.play("hit flash")
	
func die():
	sleeping = true
	visible = false

func _on_hitbox_body_entered(body):
	if sleeping:
		return
	
	if body.has_method("hit"):
		body.hit(melee_damage, self)
