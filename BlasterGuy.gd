extends KinematicBody2D


### VARIABLES ------------------------------------------------------------------
# PLAYER VARS ------------------------------------------------------------------
var speed = 128 						# Pixels/sec
var velocity = 0 						# Pixels/sec
var max_velocity = 400 					# Pixels/sec
var braking_adjustment = 0.75 			# Makes changing directions smoother
var friction_coefficient = 0.1			# Enables slowing to stop
var guy_width
var guy_height
var dead = false


# PROJECTILE VARS --------------------------------------------------------------
var PROJECTILE
var projectile_offset = 16 				# Pixels to offset spawned projectiles
var fire_rate = 0.2 					# Seconds per shot


# MAIN / INPUT / UTILITY VARS --------------------------------------------------
var screen_size 						# Size of game window
var hold_time_limit = 0.25 				# Seconds


### FUNCTIONS ------------------------------------------------------------------
# VIRTUAL METHODS --------------------------------------------------------------
func _ready() -> void:
	hide()
	# PLAYER VARS
	guy_width = $GuySprite.texture.get_width() * $GuySprite.scale.x
	guy_height = $GuySprite.texture.get_height() * $GuySprite.scale.y
	velocity = 0
	dead = false
	# PROJECTILE VARS
	PROJECTILE = preload('res://Projectile.tscn')
	# MAIN / INPUT / UTILITY VARS
	screen_size = get_viewport_rect().size
	
	# TIMERS
	$ShotCooldownTimer.wait_time = fire_rate
	$ShootHoldTimer.wait_time = hold_time_limit


func _process(delta : float) -> void:
	if not dead: 						# lol
		handle_movement(delta)
		handle_shoot()


# MAIN / UTILITY / INPUT FUNCTIONS ---------------------------------------------
func start(pos : Vector2) -> void:
	_ready()
	position = pos
	show()
	


func player_is_holding(button_name : String,
					   hold_timer : Timer,
					   hold_limit : float) -> bool:
	# Scenario 1: They just pressed the button; kick off the timer
	if Input.is_action_just_pressed(button_name):
		hold_timer.wait_time = hold_limit
		hold_timer.start()
		return true
	# Scenario 2: They are still pressing the button after initial press
	elif Input.is_action_pressed(button_name):
		return true
	# Scenario 3: They just released; check if they took too long to do so
	elif Input.is_action_just_released(button_name):
		if hold_timer.is_stopped():
			return true
		else:
			return false
	# Scenario 4: They're not pressing the button at all
	else:
		return false


func die() -> void:
	dead = true
	hide()
	

func play_hurt_sound() -> void:
	$HurtSound.play()
	

func change_fire_rate(factor : float) -> void:
	fire_rate *= factor
	$ShootHoldTimer.wait_time = fire_rate


# MOVEMENT FUNCTIONS -----------------------------------------------------------
func handle_movement(delta : float) -> void:
	# Prioritize change of direction to enable smoother movement
	# Impose speed limit
	if Input.is_action_pressed("move_right") and (abs(velocity) < max_velocity):
		velocity += speed * delta * \
					(1 + (int(velocity < 0) * braking_adjustment))
	if Input.is_action_pressed("move_left") and (abs(velocity) < max_velocity):
		velocity -= speed * delta * \
					(1 + (int(velocity > 0) * braking_adjustment))
	
	velocity = lerp(velocity, 0, friction_coefficient)
	position.x += velocity
	
	if did_hit_wall(position.x):
		stop()


func did_hit_wall(x_pos : float) -> bool:
	return (x_pos <= guy_width or x_pos >= screen_size.x - guy_width)


func stop() -> void:
	position.x = clamp(position.x, 		# No going off of the screen
					   guy_width, 		# Must apply player size offset
					   screen_size.x - guy_width)
	velocity = 0


# SHOOTING FUNCTIONS -----------------------------------------------------------
func handle_shoot() -> void:
	# If the player hits the shoot button, then shoot once
	if Input.is_action_just_pressed("shoot"):
		shoot()

	# But if they hold down the button, meter their fire rate
	if player_is_holding("shoot", $ShootHoldTimer, hold_time_limit):
		meter_shot()


func shoot() -> void:
	# Find where to put the new projectile relative to the player
	var projectile_x = position.x
	var projectile_y = position.y - guy_height - projectile_offset
	
	# Instance projectile object, init w/ correct position for it
	var projectile = PROJECTILE.instance()
	projectile.init(projectile_x, projectile_y) # Note custom init function
	
	# Spawn projectile into the main scene
	get_parent().add_child(projectile)
	
	# Pew pew
	$BlastSound.play()
	
	# Start the cooldown timer (currently only checked if holding button)
	$ShotCooldownTimer.start()
	

func meter_shot() -> void:
	if $ShotCooldownTimer.is_stopped():
		shoot()
	
