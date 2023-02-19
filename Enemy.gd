extends KinematicBody2D


### SIGNALS --------------------------------------------------------------------
signal enemy_killed
signal player_hurt


func enemy_killed(enemy_kill_score : int) -> void:
	emit_signal("enemy_killed", enemy_kill_score)
	

func player_hurt(enemy_damage : int) -> void:
	emit_signal("player_hurt", enemy_damage)


### VARIABLES ------------------------------------------------------------------
var width
var height
var enemy_speed
var screen_size
var enemy_kill_score = 1
var enemy_damage = 1
var min_speed = 256
var max_speed = 512
var was_killed = false


### FUNCTIONS ------------------------------------------------------------------
# VIRTUAL METHODS --------------------------------------------------------------
func _init() -> void:
	hide()


func _ready() -> void:
	# _ready() runs when children (including EnemySprite) are ready
	screen_size = get_parent().screen_size
	width = $EnemySprite.texture.get_width() * $EnemySprite.scale.x
	height = $EnemySprite.texture.get_height() * $EnemySprite.scale.y
	enemy_speed = rand_range(min_speed, max_speed)


func _process(delta : float) -> void:
	position.y += enemy_speed * delta
	if position.y > screen_size.y:
		was_killed = false # Probably unnecessary but who cares
		die()
	

# TODO: when we have the functionality, kill/hurt player when hit
# 	for now just doing when enemy gets passed the player
#func _physics_process(delta : float) -> void:
#	var collision = move_and_collide(Vector2.ZERO)
#	if collision != null:
#		var body = collision.collider
#		if (body.name == "BlasterGuy"):
#			pass # Player loses (a life?)


# SPAWNING FUNCTIONS -----------------------------------------------------------
func spawn_at(x_pos : float, y_pos: float) -> void:
	position.x = x_pos
	position.y = y_pos
	show()


func die() -> void:
	if was_killed:
		enemy_killed(enemy_kill_score)
	else:
		player_hurt(enemy_damage)
	queue_free()


func change_speed(new_min : int, new_max : int) -> void:
	enemy_speed = rand_range(new_min, new_max)

