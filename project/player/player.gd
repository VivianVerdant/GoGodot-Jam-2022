extends KinematicBody2D

const MAX_SPEED = 180.0
const ACCELERATION = 5.0
const AIR_CONTROL = 0.5
const FRICTION = 0.85
const GRAVITY = 8.0
const JUMP_FORCE = 150.0
const JUMP_TIME = 0.3


var dx = 0
var dy = 0
var motion = Vector2.ZERO
var jumpTimer = Timer.new()
var can_jump = false
var snap = Vector2.ZERO

var state = ""
var busy = false

onready var body = $flip/body
onready var flip = $flip


func _ready():
	jumpTimer.set_one_shot(true)
	jumpTimer.set_wait_time(JUMP_TIME)
	add_child(jumpTimer)
	

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
	
	if not busy:
		set_state()
		set_animation()
	
	if is_on_floor():
		dx += PlayerInput.x_axis * ACCELERATION
	else:
		dx += PlayerInput.x_axis * ACCELERATION * AIR_CONTROL
	
	if abs(dx) > MAX_SPEED:
		dx = PlayerInput.x_axis * MAX_SPEED
		
	if state == "sliding":
		dx *= FRICTION
		
	if PlayerInput.jump and can_jump:
			jumpTimer.start()
			dy -= JUMP_FORCE
			can_jump = false
	
	if is_on_ceiling():
		print("bonk")
		dy = max(dy,0)
		jumpTimer.stop()

	if not jumpTimer.is_stopped() and PlayerInput.jump:
		pass
		snap = Vector2.ZERO
	else:
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
