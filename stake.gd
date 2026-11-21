extends Area2D

func _ready():
	add_to_group("stakes")
	scale = Vector2.ZERO
	create_tween().tween_property(self, "scale", Vector2.ONE, 1.0)
