extends Node

@export var rock_scene: PackedScene
@export var rock_follow_path: PathFollow2D
@export var player: RigidBody2D
@export var enemy_scene: PackedScene
@export var powerups: Array[PackedScene]

var level = 0
var score = 0
var playing = false
var screensize = Vector2.ZERO

func _ready():
	screensize = get_viewport().get_visible_rect().size
	SignalManager.toggle_crt_on.connect(_on_crt_toggle_on)
	SignalManager.toggle_crt_off.connect(_on_crt_toggle_off)

func _process(delta):
	if not playing:
		return
	if get_tree().get_nodes_in_group("rocks").size() == 0:
		new_level()

func _input(event):
	if event.is_action_pressed("pause"):
		if not playing:
			return
		get_tree().paused = !get_tree().paused
		var message = $HUD/VBoxContainer/Message
		if get_tree().paused:
			message.text = "Paused"
			message.show()
		else:
			message.text = ""
			message.hide() 

func new_game():
	play_music()
	get_tree().call_group("rocks", "queue_free")
	get_tree().call_group("enemies", "queue_free")
	level = 0
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready!")
	player.reset()
	await $HUD/Timer.timeout
	playing = true

func play_music():
	$Music.play()

func game_over():
	$Music.stop()
	playing = false
	$HUD.game_over()
	
func new_level():
	$LevelupSound.play()
	level += 1
	$HUD.show_message("Wave %s" % level)
	for i in level:
		rock_spawn(3)
	$EnemyTimer.start(randf_range(3,8))

func rock_spawn(size, pos = null, vel = null):
	if pos == null:
		rock_follow_path.progress = randi()
		pos = rock_follow_path.position
	if vel == null:
		# Velocity is set to the RIGHT Vector in a range from 0 radians to 2PI radians, and then multiplied by an amount
		# between 50 and 125 to give it extra rotation.
		vel = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50.0, 125.0)
	var r = rock_scene.instantiate()
	r.screensize = screensize
	r.start(pos, vel, size)
	call_deferred("add_child", r)
	r.exploded.connect(_on_rock_exploded)
	
func _on_rock_exploded(size, radius, pos, vel):
	$ExplosionSound.play()
	if size <= 1:
		return
	# Create variable offset in for loop
	# It will be the values in the [] during the loop (so two times, once for -1 and once for +1)
	for offset in [-1, 1]:
		# A direction is calculated based on the player's direction at the exploded rock - the orthongal position
		# (perpindicular to the player) is grabbed in both the -1 and +1 direction for each loop
		var dir = player.position.direction_to(pos).orthogonal() * offset
		# Create the new pos and new vel for the smaller rock and make them slightly faster
		var newpos = pos + (dir * radius)
		var newvel = dir * vel.length() * 1.1
		rock_spawn(size - 1, newpos, newvel)

func _on_enemy_timer_timeout():
	if get_tree().get_nodes_in_group("enemies").size() >= 5:
		return
	var e = enemy_scene.instantiate()
	add_child(e)
	e.target = player
	var enemy_spawn_timer_countdown = 15 - level
	$EnemyTimer.start(enemy_spawn_timer_countdown)


func _on_powerup_spawn_timer_timeout():
	var p = powerups[randi_range(0,powerups.size()-1)].instantiate()
	add_child(p)
	p.position.x = randi_range(50, screensize.x - 50)
	p.position.y = randi_range(-50, screensize.y + 50)

func _on_crt_toggle_on():
	$PostProcessing.show()
	
func _on_crt_toggle_off():
	$PostProcessing.hide()
