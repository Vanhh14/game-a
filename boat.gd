extends Area2D

@export var speed := 80.0
@export var stuck_seconds := 3.0
@export var slow_seconds := 2.5
var hp := 3
var big := false
var boss := false
var flee := false
var base_color := Color(1, 1, 1)
var slow_time := 0.0
var stuck_time := 0.0
@onready var follower = get_parent()

func _ready():
	follower.loop = false
	area_entered.connect(_on_area_entered)
	if boss:
		add_to_group("boss")
		scale = Vector2(2.4, 2.4)
		base_color = Color(0.35, 0.1, 0.1)
	else:
		add_to_group("boats")
	if big:
		scale = Vector2(1.6, 1.6)
		base_color = Color(0.55, 0.55, 0.55)
	modulate = base_color

func _physics_process(delta):
	if stuck_time > 0:
		stuck_time -= delta
		return
	var mult := 1.0
	if slow_time > 0:
		slow_time -= delta
		mult = 0.4
	if flee:
		follower.progress -= speed * mult * delta
		if follower.progress_ratio <= 0.0:
			follower.queue_free()
		return
	follower.progress += speed * mult * delta
	if follower.progress_ratio >= 1.0:
		var dmg = 3 if boss else 1
		get_tree().current_scene.damage_base(dmg)
		follower.queue_free()

func _on_area_entered(area):
	if not area.is_in_group("stakes"):
		return
	if boss:
		if flee:
			stuck_time = 9999.0
		return
	if big:
		slow_time = slow_seconds
	else:
		stuck_time = stuck_seconds

func take_damage(d):
	var invincible = boss and not flee
	if not invincible:
		hp -= d
		if hp <= 0:
			follower.queue_free()
			return
	flash()

func flash():
	modulate = Color(2, 2, 2)
	await get_tree().create_timer(0.1).timeout
	modulate = base_color
