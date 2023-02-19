extends KinematicBody2D


### VARIABLES ------------------------------------------------------------------
var projectile_speed = 32


### FUNCTIONS ------------------------------------------------------------------
# VIRTUAL METHODS --------------------------------------------------------------
func _ready() -> void:
	scale.x = $ProjectileSprite.scale.x
	scale.y = $ProjectileSprite.scale.y


func _physics_process(delta : float) -> void:
	position.y -= projectile_speed 		# Move across screen
	var collision = move_and_collide(Vector2.ZERO * delta)
	if collision != null:
		var enemy_hit = collision.collider
		enemy_hit.was_killed = true
		enemy_hit.die()				# Enemy was killed
		queue_free()					# Depawn projectile


func _on_ProjectileVisibilityNotifier2D_screen_exited() -> void:
	queue_free()


# SPAWNING FUNCTIONS -----------------------------------------------------------
func init(x_pos : float, y_pos : float) -> void:
	position.x = x_pos
	position.y = y_pos

