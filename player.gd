extends CharacterBody2D

@export var speed := 300.0
@export var arrow_scene: PackedScene
@export var fire_cooldown := 0.4
var can_fire := true

func _physics_process(_delta):
	var dir := Vector2(
		int(Input.is_physical_key_pressed(KEY_D)) - int(Input.is_physical_key_pressed(KEY_A)),
		int(Input.is_physical_key_pressed(KEY_S)) - int(Input.is_physical_key_pressed(KEY_W))
	)
	velocity = dir.normalized() * speed
	move_and_slide()

	look_at(get_global_mouse_position())

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_fire:
		fire()

func fire():
	can_fire = false
	var a = arrow_scene.instantiate()
	a.global_position = global_position
	a.rotation = rotation
	get_tree().current_scene.add_child(a)
	await get_tree().create_timer(fire_cooldown).timeout
	can_fire = true
