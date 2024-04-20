extends CanvasLayer

signal start_game

@onready var lives_counter: Array[Node] = $MarginContainer/HBoxContainer/LivesCounter.get_children()
@onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel
@onready var message: Label = $VBoxContainer/Message
@onready var start_button: TextureButton = $VBoxContainer/StartButton
@onready var shield_bar: TextureProgressBar = $MarginContainer/HBoxContainer/ShieldBar

var score: int = 0

func _ready():
	SignalManager.change_score.connect(update_score)

var bar_textures = {
	"green": preload("res://assets/bar_green_200.png"),
	"yellow": preload("res://assets/bar_yellow_200.png"),
	"red": preload("res://assets/bar_red_200.png")
}

func update_shield(value):
	shield_bar.texture_progress = bar_textures["green"]
	if value < 0.4:
		shield_bar.texture_progress = bar_textures["red"]
	elif value < 0.7:
		shield_bar.texture_progress = bar_textures["yellow"]
	shield_bar.value = value

func show_message(text):
	message.text = text
	message.show()
	$Timer.start()
	
func update_score(value):
	score += value
	score_label.text = str(score)
	
func update_lives(value):
	for item in 3:
		# Visibility of each LifeGraphic Node in the array is being set to a boolean value of false or true
		# Grab LifeGraphic Node index [0 - 3], and if the value (number of lives passed in) is greater than
		# the index (item), its true so it stays, or it's false and it goes invisible
		lives_counter[item].visible = value > item
		
func game_over():
	show_message("Game Over!")
	await $Timer.timeout
	start_button.show()


func _on_timer_timeout():
	message.hide()
	message.text = ""


func _on_start_button_pressed():
	start_button.hide()
	score = 0
	update_score(score)
	start_game.emit()
