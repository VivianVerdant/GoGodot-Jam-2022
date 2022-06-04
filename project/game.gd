extends Node2D

var game_world = preload("res://world.tscn")

onready var menu = $menu
onready var background = $menu/sprites

var world_instance


func _ready():
	EventManager.connect("player_death", self, "player_died")
	EventManager.connect("room_entered", self, "set_target_room")
	
	
	
func set_target_room(room):
	menu.position = room.position

func player_died():
	print("foo")
	menu.visible = true
	background.visible = true


func _on_new_game_button_pressed():
	if world_instance:
		world_instance.free()
	
	world_instance = game_world.instance()
	add_child(world_instance)
	move_child(world_instance, 0)
	
	menu.visible = false
	
	background.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("menu") and EventManager.can_pause and world_instance:
		menu.visible = !menu.visible
		EventManager.paused = menu.visible


func _on_quit_button_pressed():
	get_tree().quit()


func _on_viv_pressed():
	OS.shell_open("https://twitter.com/VivianVerdant")


func _on_may_pressed():
	OS.shell_open("https://twitter.com/prierchan")
