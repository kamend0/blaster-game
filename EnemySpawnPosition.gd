extends Position2D


### VARIABLES ------------------------------------------------------------------
var screen_size
var spawn_buffer_bottom = 128 				# Pixels


### FUNCTIONS ------------------------------------------------------------------
func _on_Main_player_spawned_with_size(_player_width : int, 
									   _player_height : int) -> void:
	# TODO Update; just fixed to middle of screen
	screen_size = get_viewport_rect().size
	position.x = screen_size.x / 2
	position.y = screen_size.y / 2


func randomize_enemy_spawn_pos(enemy_width_buffer : float, 
							   enemy_height_buffer : float) -> void:
	screen_size = get_viewport_rect().size
	var spawn_x_min = enemy_width_buffer
	var spawn_x_max = screen_size.x - enemy_width_buffer
	var spawn_y_min = enemy_height_buffer
	var spawn_y_max = screen_size.y - enemy_height_buffer - spawn_buffer_bottom
	position.x = rand_range(spawn_x_min, spawn_x_max)
	position.y = rand_range(spawn_y_min, spawn_y_max)

