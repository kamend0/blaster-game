# TODO: Add difficulty increasing message + timers


extends CanvasLayer


signal start_game


func _on_StartButton_pressed() -> void:
	# IDEA Could throw difficulties into here...
	$Message.hide()
	$StartButton.hide()
	emit_signal("start_game")


func _ready() -> void:
	$Message.text = "BLASTER"
	$Message.show()
	

func init(score : int, lives : int) -> void:
	update_score(score)
	update_lives(lives)
	

func update_score(score : int) -> void:
	$ScoreNumLabel.text = str(score)


func update_lives(lives : int) -> void:
	if lives <= 0:
		lives = 0
	$LivesNumLabel.text = str(lives)
	

func update_level(level : int) -> void:
	$LevelNumLabel.text = str(level)


func show_game_over() -> void:
	$Message.text = "Game Over"
	$Message.show()
	$GameOverTimer.start()
	yield($GameOverTimer, "timeout")
	$Message.text = "Try Again?"
	$StartButton.show()
