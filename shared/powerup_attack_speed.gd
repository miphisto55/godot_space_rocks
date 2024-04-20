extends Area2D

var screensize = Vector2.ZERO

func _ready():
	var tween = create_tween().set_parallel().set_trans(Tween.TRANS_QUAD)
	tween.tween_property($SpriteInit, "scale", scale * 2.0, 1.0)
	tween.tween_property($SpriteInit, "modulate:a", 0.0, 1.0)
	await tween.finished

func _on_body_entered(body):
	if body.is_in_group("Player"):
		SignalManager.powerup_attack_speed_pickup.emit(Enums.POWERUPS.ATTACK_SPEED)
		$CollisionShape2D.set_deferred("disabled", true)
		var tween = create_tween().set_parallel().set_trans(Tween.TRANS_QUAD)
		tween.tween_property(self, "scale", scale * 1.5, 0.3)
		tween.tween_property(self, "modulate:a", 0.0, 0.3)
		await tween.finished
		queue_free()

func _on_lifetime_timeout():
	queue_free()
