extends Area2D

@export var speed := 700.0
@export var damage := 1

func _ready():
	area_entered.connect(_on_area_entered)
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _on_area_entered(area):
	if area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free()
