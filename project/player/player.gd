tool
class_name Player
extends KinematicBody2D

const MAX_SPEED = 100.0
const ACCELERATION = 15.0
const AIR_CONTROL = 0.5
const FRICTION = 0.90
const GRAVITY = 8.0
const JUMP_FORCE = 150.0

onready var bullet_timer = $bullet_timer
onready var bullet = preload("res://entities/bullet.tscn")
var can_shoot = false

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

export var bullet_settings = Array()

onready var body = $flip/body
onready var flip = $flip


func _ready():
	can_shoot = true

func set_state():
	
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
			state = "jumping"

func set_animation():
	if sign(PlayerInput.x_axis) != 0:
		flip.scale.x = sign(PlayerInput.x_axis)	
	return
	match state:
		"standing":
			body.animation = "stand"
			body.playing = false
			body.frame = 0
		"jumping":
			body.animation = "jump"
			body.playing = false
			body.frame = 0
		"falling":
			body.animation = "jump"
			body.playing = false
			body.frame = 1
		"running", "sliding":
			body.animation = "run"
			body.playing = true
			body.speed_scale = abs(dx) / MAX_SPEED
	
func _physics_process(delta):
	if Engine.editor_hint:
		return
	
	if not busy:
		set_state()
		set_animation()
	
	if PlayerInput.dir != Vector2.ZERO:
		facing = PlayerInput.dir
	
	if is_on_floor():
		dx += PlayerInput.x_axis * ACCELERATION
	else:
		dx += PlayerInput.x_axis * ACCELERATION * AIR_CONTROL
	
	if abs(dx) > MAX_SPEED:
		dx = PlayerInput.x_axis * MAX_SPEED
		
	if state == "sliding":
		dx *= FRICTION
		
	if PlayerInput.jump and can_jump:
		if not PlayerInput.down:
			jump_timer.start()
			dy -= JUMP_FORCE
			can_jump = false
		else:
			drop()
	
	if is_on_ceiling():
		print("bonk")
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
	
	if PlayerInput.fire and bullet_timer.is_stopped():
		bullet_timer.start()
		fire()


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
