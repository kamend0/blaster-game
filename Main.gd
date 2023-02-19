extends Node


### SIGNALS --------------------------------------------------------------------
signal player_spawned_with_size


func player_spawned_with_size() -> void:
	emit_signal("player_spawned_with_size",
				$BlasterGuy.guy_width, 
				$BlasterGuy.guy_height)


### VARIABLES ------------------------------------------------------------------
# UTILITY / GAMEPLAY VARS ------------------------------------------------------
#var paused = false 				# TODO: Implement a pause button
var screen_size
var difficulty_trigger_score
var difficulty_step
var difficulty_trigger_scores = [12, 25, 40, 60, 90, 125, 172, 212]
#var difficulty_trigger_scores = [5, 10, 15, 20, 25, 30, 35] # Test


# ENEMY VARS -------------------------------------------------------------------
var ENEMY
var min_enemy_spawn_rate 			# Enemies spawn at 1/(this) per second
var max_enemy_spawn_rate			# Thus, lower = faster spawn rate
var min_enemy_speed
var max_enemy_speed
var enemy_spawn_location

# PLAYER VARS ------------------------------------------------------------------
var lives
var score


### FUNCTIONS ------------------------------------------------------------------
# VIRTUAL METHODS --------------------------------------------------------------
func _ready() -> void:
	init()
	randomize()
	player_spawned_with_size()
	ENEMY = preload('res://Enemy.tscn')
	screen_size = $Backdrop.get_viewport_rect().size
	$EnemySpawnTimer.wait_time = rand_range(min_enemy_spawn_rate,
											max_enemy_spawn_rate)
	$HUD.connect("start_game", self, "new_game")


func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_quit"):
		get_tree().quit()
	if event.is_action_pressed("toggle_game_pause"):
		pass # TODO: Implement a pause button
		

func _process(_delta : float) -> void:
	if score >= difficulty_trigger_score:
		increase_difficulty()


func _on_EnemySpawnTimer_timeout() -> void:
	spawn_enemy()


func _on_Enemy_enemy_killed(enemy_kill_score : int) -> void:
	score += enemy_kill_score
	$HUD.update_score(score)
	

func _on_Enemy_player_hurt(enemy_damage : int) -> void:
	lives -= enemy_damage
	$HUD.update_lives(lives)
	$BlasterGuy.play_hurt_sound()
	if lives <= 0:
		game_over()


# GAMEPLAY FUNCTIONS -----------------------------------------------------------
func init() -> void:
	min_enemy_spawn_rate = 0.9
	max_enemy_spawn_rate = 0.3
	min_enemy_speed = 256
	max_enemy_speed = 512
	lives = 3
#	lives = 500						# TESTING
	score = 0
	difficulty_trigger_score = difficulty_trigger_scores[0]
	difficulty_step = 0


func new_game() -> void:
	init()
	$HUD.init(score, lives)
	$BlasterGuy.start($StartPosition.position)
	$EnemySpawnTimer.start()
	$ThemeMusic.play()
	

func game_over() -> void:
	$ThemeMusic.stop()
	$GameOverSound.play()
	$BlasterGuy.die()
	$EnemySpawnTimer.stop()
	get_tree().call_group("enemies", "queue_free")
	$HUD.show_game_over()
	$HUD.connect("start_game", self, "new_game")


func spawn_enemy() -> void:
	var enemy = ENEMY.instance()
	add_child(enemy) # Will not spawn - initialized as hidden
	
	# Choose a random spawn location
	enemy_spawn_location = get_node("EnemySpawnPath/EnemySpawnLocation")
	enemy_spawn_location.offset = rand_range(enemy.width / 2,
											 screen_size.x - (enemy.width / 2))
											
	# Adjust enemy speed as needed
	enemy.change_speed(min_enemy_speed, max_enemy_speed)
	
	# Spawn the enemy
	enemy.spawn_at(enemy_spawn_location.position.x,
				   enemy_spawn_location.position.y)
	
	# Connect to enemy signals signal
	enemy.connect("enemy_killed", self, "_on_Enemy_enemy_killed")
	enemy.connect("player_hurt", self, "_on_Enemy_player_hurt")


func update_enemy_spawn_times() -> void:
	$EnemySpawnTimer.wait_time = rand_range(min_enemy_spawn_rate,
											max_enemy_spawn_rate)
											

func increase_difficulty() -> void:
	$DifficultyUpSound.play()
	# Beef up enemies
	increase_enemy_spawn_rate()
	increase_enemy_speed()
	# And give the player a helping hand
	$BlasterGuy.change_fire_rate(0.85)
	print("Fire rate is now: ", $BlasterGuy.fire_rate)
	difficulty_step += 1
	if difficulty_step < len(difficulty_trigger_scores):
		difficulty_trigger_score = difficulty_trigger_scores[difficulty_step]
	else:
		difficulty_trigger_score *= 1.2
	$HUD.update_level(difficulty_step)
	

func increase_enemy_spawn_rate() -> void:
	if difficulty_step % 2 == 0:
		min_enemy_spawn_rate *= 0.85
	else:
		max_enemy_spawn_rate *= 0.95
	$EnemySpawnTimer.wait_time = rand_range(min_enemy_spawn_rate,
											max_enemy_spawn_rate)


func increase_enemy_speed() -> void:
	if difficulty_step % 2 == 0:
		min_enemy_speed *= 1.15
	else:
		max_enemy_speed *= 1.15

