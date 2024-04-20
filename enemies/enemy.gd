extends Area2D

signal change_score

@export var bullet_scene: PackedScene

@export var speed: int = 150
@export var rotation_speed: int = 120
@export var health: int = 3
@export var bullet_spread: float = 0.2

var follow: PathFollow2D = PathFollow2D.new()
var target = null

func _ready():
	$Sprite2D.frame = randi() % 3
	var number_of_paths = $EnemyPaths.get_child_count()
	var path = $EnemyPaths.get_children()[randi() % number_of_paths]
	path.add_child(follow)
	follow.loop = false

func _physics_process(delta):
	rotation += deg_to_rad(rotation_speed) * delta
	follow.progress += speed * delta
	position = follow.global_position
	if follow.progress_ratio >= 1:
		queue_free()

func shoot():
	$ShootSound.play()
	var dir = global_position.direction_to(target.global_position)
	dir = dir.rotated(randf_range(-bullet_spread, bullet_spread))
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(global_position, dir)

func shoot_pulse(n, delay):
	for i in n:
		shoot()
		await get_tree().create_timer(delay).timeout

func take_damage(amount):
	health -= amount
	$AnimationPlayer.play("flash")
	if health <= 0:
		explode()

func explode():
	SignalManager.change_score.emit(2)
	$ExplosionSound.play()
	speed = 0
	$GunCooldown.stop()
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.hide()
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	queue_free()
	
func _on_gun_cooldown_timeout():
	shoot_pulse(3,0.15)
	#shoot()

func _on_body_entered(body):
	if body.is_in_group("rocks"):
		return
	# Explode if the body isn't a rock, a.k.a its the player
	explode()
	body.shield -= 50


func _on_area_entered(area):
	if area.is_in_group("bullets") and !area.is_in_group("enemy_bullet"):
		$HitMarkerSound.play()
