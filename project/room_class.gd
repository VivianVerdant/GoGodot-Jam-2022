tool
class_name GameRoom
extends Area2D

var area

var explored = false
var paused = true

onready var actors = $actors

func _ready():
	connect("body_entered", self, "on_body_entered")

	area = CollisionShape2D.new()
	add_child(area)
	var shape = RectangleShape2D.new()
	area.shape = shape
	shape.extents = Vector2(240, 160)
	area.position = Vector2(240, 160)
	move_child(area, 0)
	
	
#	if Engine.editor_hint:
#		area.set_owner(get_tree().edited_scene_root)

func entered():
	#print("entered")
	for node in actors.get_children():
		node.sleeping = false
	
func exited():
	#print("exited")
	for node in actors.get_children():
		if node.has_method("reset"):
			node.reset()


func on_body_entered(node):
	if node is Player:
		EventManager.emit_signal("room_entered", self)
		explored = true

func _notification(what):
	match what:
		2000:
			snap()
		_:
			pass

func snap():
	global_position.x = floor(global_position.x / 480) * 480
	global_position.y = floor(global_position.y / 320) * 320

