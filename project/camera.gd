extends Camera2D

const OFFSET = Vector2(240, 160)

var to
var from
onready var tween = $tween

var first_load = true

var player

func _ready():
	EventManager.connect("room_entered", self, "set_target_room")
	if get_tree().get_nodes_in_group("player").size() > 0:
		player = get_tree().get_nodes_in_group("player")[0]
	EventManager.connect("player_death", self, "player_died")

func player_died():
	position = Vector2.ZERO

func set_target_room(room):
	from = to
	to = room
	
	if not first_load:
		player.busy = true
		first_load = false
	
	tween.interpolate_property(self, "position", 
		self.position, to.position + OFFSET, .66, 
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT)

	tween.interpolate_property(tween, "playback_speed", 
		1.0, .25, .66, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

	EventManager.can_pause = false


func _on_tween_all_completed():
	if from and from.has_method("exited"):
		from.exited()
	if to and to.has_method("entered"):
		to.entered()
	player.busy = false
	EventManager.can_pause = true
