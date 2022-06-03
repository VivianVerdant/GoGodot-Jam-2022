tool
class_name Player
extends KinematicBody2D

const MAX_SPEED = 100.0
const ACCELERATION = 15.0
const AIR_CONTROL = 0.5
const FRICTION = 0.90
const GRAVITY = 8.0
const JUMP_FORCE = 150.0

export var bullet_settings = Array()
onready var bullet_timer = $bullet_timer
onready var bullet = preload("res://entities/bullet.tscn")
var can_shoot = false

export var melee_damage = 10

export var max_health: int
var curr_health: int
onready var hit_timer = $hit_timer

var dx = 0
var dy = 0
var motion = Vector2.ZERO
var facing = Vector2.RIGHT
onready var jump_timer = $jump_timer
var can_jump = false
var snap = Vector2.ZERO

var state = ""
var busy = false
var no_grav = false


onready var body = $flip/body
onready var flip = $flip
onready var animation_player = $animation_player

onready var effects_player = $effects_player

func _ready():
	can_shoot = true
	curr_health = max_health

func set_state():
	if state == "melee":
		busy = true
		return
	
	state = "standing"
	
	if is_on_floor():
		if dx != 0 and PlayerInput.x_axis == 0:
			state = "sliding"
		
		if PlayerInput.x_axis != 0:
			state = "running"
		
		if not PlayerInput.jump:
			can_jump = true
		
		dy = min(dy,0)
		
	else:
		if dy > 0:
			state = "falling"
		else:
			if PlayerInput.x_axis != 0:
				state = "jumping"
			else:
				state = "jumping_neutral"

func set_animation():
	if sign(PlayerInput.x_axis) != 0:
		flip.scale.x = sign(PlayerInput.x_axis)

	match state:
		"standing":
			animation_player.play("stand", -1, 0.0)
		"jumping_neutral":
			animation_player.play("jump", -1, 0.0)
			animation_player.seek(0.0, true)
		"jumping":
			animation_player.play("jump", -1, 0.0)
			animation_player.seek(0.0433, true)
		"falling":
			animation_player.play("jump", -1, 0.0)
			animation_player.seek(0.0167, true)
		"running", "sliding":
			animation_player.play("run", -1, abs(dx) / MAX_SPEED)
		"melee":
			if not busy and is_on_floor():
				animation_player.play("melee ground", -1, 1.0)
				return
			elif not busy and not is_on_floor():
				animation_player.play("melee air", -1, 1.0)
				return
			var f = animation_player.current_animation_position
			if f == animation_player.current_animation_length:
				state = null
				busy = false
				return
			if is_on_floor():
				animation_player.play("melee ground", -1, 1.0)
				animation_player.seek(f, true)
			else:
				animation_player.play("melee air", -1, 1.0)
				animation_player.seek(f, true)
	
func _physics_process(delta):
	if Engine.editor_hint:
		return
	
	set_animation()
	if not busy:
		set_state()
	
	if PlayerInput.dir != Vector2.ZERO:
		facing = PlayerInput.dir
	
	if is_on_floor() and not busy:
		dx += PlayerInput.x_axis * ACCELERATION
	elif not busy:
		dx += PlayerInput.x_axis * ACCELERATION * AIR_CONTROL
	
	if abs(dx) > MAX_SPEED:
		dx = PlayerInput.x_axis * MAX_SPEED
		
	if state == "sliding" or busy:
		dx *= FRICTION
		
	if PlayerInput.jump and can_jump:
		if not PlayerInput.down:
			jump_timer.start()
			dy -= JUMP_FORCE
			can_jump = false
		else:
			drop()
	
	if is_on_ceiling():
		#print("bonk")
		dy = max(dy,0)
		jump_timer.stop()

	if not jump_timer.is_stopped() and PlayerInput.jump:
		pass
		snap = Vector2.ZERO
	else:
		if not no_grav:
			dy += GRAVITY
		snap = Vector2(0,4)
	
	if abs(dx) < 1 and PlayerInput.x_axis == 0:
		dx = 0

	#(linear_velocity: Vector2, snap: Vector2, up_direction: Vector2 = Vector2( 0, 0 ), stop_on_slope: bool = false, max_slides: int = 4, floor_max_angle: float = 0.785398, infinite_inertia: bool = true)
	motion = move_and_slide_with_snap(Vector2(dx,dy), snap, Vector2.UP, true)*delta
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if abs(collision.normal.y) <= .1:
			dx = 0
	
	if PlayerInput.fire and not busy:
		#print("paunch")
		state = "melee"


func _on_hitbox_body_entered(body):
	if body.has_method("hit"):
		body.hit(melee_damage, self)

func _on_hitbox_area_entered(area):
	if area.has_method("hit"):
		print(area)
		area.hit(melee_damage, self)
	
func hit(damage, owner):
	if hit_timer.is_stopped():
		#print("ow")
		effects_player.play("hit flash")
		hit_timer.start()
		var knockback = owner.global_position.direction_to(global_position + Vector2(0.0, -32.0)) * damage * 350.0
		dx += knockback.x
		dy += knockback.y
		snap = Vector2.ZERO
		
		curr_health -= damage
		if curr_health < 0:
			die()

func die():
	print("dead")

func fire():
	var b = bullet.instance()
	b.start(global_position, facing, bullet_settings[0])
	get_parent().add_child(b)

func drop():
	var col = move_and_collide(Vector2.DOWN, true, true, true)
	
	if col.collider.collision_layer >> 4:
		print(col.collider.collision_layer >> 4)
		position.y += 1
		can_jump = false
	

func _notification(what):
	if not Engine.editor_hint:
		return
	
	match what:
		2000:
			move_snap()
		_:
			pass

func move_snap():
	global_position.x = floor(global_position.x / 16) * 16
	global_position.y = floor(global_position.y / 16) * 16
