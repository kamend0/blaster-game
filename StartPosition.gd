extends Position2D


### FUNCTIONS ------------------------------------------------------------------
func _on_Main_player_spawned_with_size(_player_width : float, 
									   player_height : float) -> void:
	var screen_size = get_viewport_rect().size
	position.x = screen_size.x / 2
	position.y = screen_size.y - (player_height)

