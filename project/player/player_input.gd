extends Node

var left = false
var right = false
var up = false
var down = false

var x_axis = 0
var y_axis = 0

var dir = Vector2.ZERO

var jump = false
var fire = false

var menu = false


func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#OS.current_screen = 1
	OS.center_window()
	#OS.window_maximized = true

func _input(event):

	menu = Input.is_action_pressed("menu")
	
	left = Input.is_action_pressed("left")
	right = Input.is_action_pressed("right")
	x_axis = int(right) - int(left)
	
	up = Input.is_action_pressed("up")
	down = Input.is_action_pressed("down")
	y_axis = int(up) - int(down)
	
	fire = Input.is_action_pressed("fire")
	
	jump = Input.is_action_pressed("jump")

	dir = Vector2(x_axis,y_axis)

