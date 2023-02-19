extends CollisionShape2D


### FUNCTIONS ------------------------------------------------------------------
func _ready() -> void:
	scale.x = get_parent().get_node("GuySprite").scale.x
	scale.y = get_parent().get_node("GuySprite").scale.y

