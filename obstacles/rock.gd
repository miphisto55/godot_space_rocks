extends RigidBody2D

signal exploded

@export var rock_sprite: Sprite2D
@export var collisionShape: CollisionShape2D
@export var explosion: Sprite2D

var screensize: Vector2 = Vector2.ZERO
var size: float
var radius: float
var scale_factor = 0.2

func start(_position, _velocity, _size):
	self.position = _position
	size = _size
	mass = 1.5 * self.size
	rock_sprite.scale = Vector2.ONE * scale_factor * size
	radius = int((rock_sprite.texture.get_size().x / 2) * rock_sprite.scale.x)
	
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = radius
	collisionShape.shape = shape
	self.linear_velocity = _velocity
	self.angular_velocity = randf_range(-PI, PI)
	explosion.scale = Vector2.ONE * 0.75 * size

func _integrate_forces(physics_state):
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0 - radius, screensize.x + radius)
	xform.origin.y = wrapf(xform.origin.y, 0 - radius, screensize.y + radius)
	physics_state.transform = xform
	
func explode():
	SignalManager.change_score.emit(1) 
	collisionShape.set_deferred("disabled", true)
	rock_sprite.hide()
	var explosion_animation_player = explosion.get_child(0)
	explosion_animation_player.play("explosion")
	explosion.show()
	exploded.emit(size, radius, self.position, self.linear_velocity)
	self.linear_velocity = Vector2.ZERO
	self.angular_velocity = 0
	await explosion_animation_player.animation_finished
	queue_free()
	
