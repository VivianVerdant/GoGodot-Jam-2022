class_name BulletSettings
extends Resource

export var dropoff:float
export var damage:float
export var speed:float
export var size:float
export var color:Color
var owner:Node
export var initial_position:Vector2
export var initial_velocity:Vector2
export(int, FLAGS, "Player", "Enemies", "World") var collision_mask
