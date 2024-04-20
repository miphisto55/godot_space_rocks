extends RigidBody2D

signal lives_changed
signal dead
signal shield_changed

@export var ship_sprite: Sprite2D
@export var playerCollisionShape: CollisionShape2D
@export var bullet_scene: PackedScene
@export var muzzle: Marker2D

@export var max_shield: float = 100.0
@export var shield_regen: float = 5.0
@export var fire_rate: float = 0.25
@export var engine_power: int = 500
@export var strafe_engine_power: int = 200
@export var spin_power: int = 5500

var shield = 0: set = set_shield
var reset_pos: bool = false
var lives: int = 0: set = set_lives
var can_shoot: bool = true
var thrust: Vector2 = Vector2.ZERO
var strafe_thrust: Vector2 = Vector2.ZERO
var rotation_dir: float = 0.0
var screensize = Vector2.ZERO
var radius

enum PlayerState {INIT, ALIVE, INVUL, DEAD}
var state: PlayerState = PlayerState.INIT

func set_lives(value):
	lives = value
	shield = max_shield
	lives_changed.emit(lives)
	if lives <= 0:
		$Muzzle/Sprite2D.hide()
		$Muzzle/Sprite2D2.hide()
		$Area2D/Shield.hide()
		change_state(PlayerState.DEAD)
	else:
		change_state(PlayerState.INVUL)

func set_shield(value):
	value = min(value, max_shield)
	shield = value
	shield_changed.emit(shield / max_shield)
	if shield <= 0:
		lives -= 1
		explode()

func _ready():
	change_state(PlayerState.ALIVE)
	screensize = get_viewport_rect().size
	$GunCooldown.wait_time = fire_rate
	radius = int((ship_sprite.texture.get_size().x / 2) * ship_sprite.scale.x)
	
func _process(delta):
	get_input()
	shield += shield_regen * delta

func _integrate_forces(physics_state):
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0 - radius, screensize.x + radius)
	xform.origin.y = wrapf(xform.origin.y, 0 - radius, screensize.y + radius)
	physics_state.transform = xform
	
	if reset_pos:
		physics_state.transform.origin = screensize / 2
		reset_pos = false

func get_input():
	$ExhaustParticles.emitting = false
	thrust = Vector2.ZERO
	strafe_thrust = Vector2.ZERO
	
	if (state in [PlayerState.DEAD, PlayerState.INIT]) or get_tree().paused:
		return
		
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
		
	if Input.is_action_pressed("thrust"):
		$ExhaustParticles.emitting = true
		thrust = self.transform.x * engine_power
		if not $EngineSound.playing:
			$EngineSound.play()
	else:
		$EngineSound.stop()
		
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	
	if Input.is_action_pressed("strafe_left"):
		strafe_thrust = -self.transform.y * strafe_engine_power
	if Input.is_action_pressed("strafe_right"):
		strafe_thrust = self.transform.y * strafe_engine_power
		
func _physics_process(delta):
	constant_force = thrust + strafe_thrust
	constant_torque = rotation_dir * spin_power

func shoot():
	if state == PlayerState.INVUL:
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(muzzle.global_transform)
	$LaserSound.play()
	$FlarePrimary.emitting = true
	$FlarePrimary/FlarePrimary2.emitting = true
	$FlarePrimary/FlarePrimary3.emitting = true

func reset():
	$Muzzle/Sprite2D.show()
	$Muzzle/Sprite2D2.show()
	$Area2D/Shield.show()
	reset_pos = true
	ship_sprite.show()
	lives = 3
	change_state(PlayerState.ALIVE)

func change_state(new_state):
	match new_state:
		PlayerState.INIT:
			playerCollisionShape.set_deferred("disabled", true)
			$Area2D/AreaCollisionShape.set_deferred("disabled", true)
			$AnimationPlayer.play("invul")
		PlayerState.ALIVE:
			playerCollisionShape.set_deferred("disabled", false)
			$Area2D/AreaCollisionShape.set_deferred("disabled", false)
		PlayerState.INVUL:
			playerCollisionShape.set_deferred("disabled", true)
			$Area2D/AreaCollisionShape.set_deferred("disabled", true)
			$AnimationPlayer.play("invul")
			$InvulnerabilityTimer.start()
		PlayerState.DEAD:
			$EngineSound.stop()
			playerCollisionShape.set_deferred("disabled", true)
			$Area2D/AreaCollisionShape.set_deferred("disabled", true)
			ship_sprite.hide()
			linear_velocity = Vector2.ZERO
			dead.emit()
	state = new_state

func explode():
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	$Explosion.hide()
	
func _on_gun_cooldown_timeout():
	can_shoot = true
	$FlarePrimary.emitting = false
	$FlarePrimary/FlarePrimary2.emitting = false
	$FlarePrimary/FlarePrimary3.emitting = false


func _on_invulnerability_timer_timeout():
	change_state(PlayerState.ALIVE)


func _on_body_entered(body):
	if body.is_in_group("rocks"):
		shield -= body.size * 25
		body.explode()


func _on_area_2d_area_entered(area):
	if area.is_in_group("enemy_bullet"):
		$AnimationPlayer.play("flash")
		$HitMarkerSound.play()
