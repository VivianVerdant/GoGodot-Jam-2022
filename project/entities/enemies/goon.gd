extends KinematicBody2D

var dxdy = Vector2.ZERO
var sleeping = true
var target = position
export var target_offset: Vector2
export var speed = 25

export var melee_damage: int

export var initial_health: int
var health

var initial_pos

var layer
var mask

onready var effects_player = $effects_player

func _ready():
	layer = collision_layer
	mask = collision_mask
	health = initial_health
	initial_pos = position
	if get_tree().get_nodes_in_group("player").size() > 0:
		target = get_tree().get_nodes_in_group("player")[0]

func _physics_process(_delta):
	if sleeping or effects_player.is_playing():
		return
	
	dxdy = global_position.direction_to(target.global_position+target_offset) * speed 
	move_and_slide(dxdy)

func reset():
	sleeping = true
	visible = true
	collision_layer = layer
	collision_mask = mask
	health = initial_health
	position = initial_pos

func hit(damage, owner):
	health -= damage
	if health < 0:
		die()
	effects_player.play("hit flash")
	
func die():
	sleeping = true
	visible = false
	collision_layer = 0
	collision_mask = 0


func _on_hitbox_body_entered(body):
	if sleeping:
		return
	if body.has_method("hit"):
		body.hit(melee_damage, self)
