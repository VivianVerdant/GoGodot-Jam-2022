extends Camera2D

const OFFSET = Vector2(240, 160)

var to
var from
onready var tween = $tween

func _ready():
	EventManager.connect("room_entered", self, "set_target_room")
	

func set_target_room(room):
	from = to
	to = room
	
	tween.interpolate_property(self, "position", 
		self.position, to.position + OFFSET, .66, 
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT)

	tween.interpolate_property(tween, "playback_speed", 
		1.0, .25, .66, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_tween_all_completed():
	if from and from.has_method("exited"):
		from.exited()
	if to and to.has_method("entered"):
		to.entered()
