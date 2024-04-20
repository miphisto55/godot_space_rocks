extends Area2D

@export var bullet_speed = 1000
@export var bullet_damage = 15

func start(_pos, _dir):
	position = _pos
	rotation = _dir.angle()

func _process(delta):
	position += transform.x * bullet_speed * delta


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.shield -= bullet_damage
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
