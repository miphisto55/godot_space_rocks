extends Sprite2D

@export var shaderTimer: Timer

var time: float = 0.0

func update_shield_in_shader(value):
	if shaderTimer.time_left > 0:
		material.set_shader_parameter("shieldValue", value * shaderTimer.time_left * 10.0)
		material.set_shader_parameter("shieldRadius", shaderTimer.time_left)
	else:
		material.set_shader_parameter("shieldValue", value)
		material.set_shader_parameter("shieldRadius", 0.18)

func _process(delta):
	material.set_shader_parameter("elapsed", time)
	material.set_shader_parameter("intensity", 0.8 + shaderTimer.time_left * 7.0)
	time += delta


func _on_area_2d_area_entered(area):
	if area.is_in_group("enemy_bullet"):
		shaderTimer.start()
