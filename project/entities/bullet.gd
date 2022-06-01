extends KinematicBody2D

var velocity = Vector2()

var bullet_settings

func start(passed_global_position, direction, passed_bullet_settings):
	bullet_settings = passed_bullet_settings
	collision_mask = passed_bullet_settings.collision_mask
	global_position = passed_global_position + passed_bullet_settings.initial_position
	velocity = bullet_settings.speed * Vector2.RIGHT * direction.x
	add_to_group("playerBullet")
	$sprite.scale.y = direction.x

func _physics_process(delta):
	velocity.y -= bullet_settings.dropoff
	var collision = move_and_collide(velocity * delta)
	if collision:
		hit()
		if collision.collider.has_method("hit"):
			collision.collider.hit(position, velocity, "bullet")
	
func _ready():
	pass
	
func hit():
	queue_free()

func _on_timeout_timeout():
	queue_free()
