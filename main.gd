extends Node2D

var base_hp := 10
var wave := 0
var ended := false
@onready var hp_label = $HpLabel

func _ready():
	RenderingServer.set_default_clear_color(Color("3d6b3a"))
	update_label()

func set_wave(n):
	wave = n
	update_label()

func damage_base(d):
	if ended:
		return
	base_hp -= d
	update_label()
	if base_hp <= 0:
		end_game("THUA", Color(1, 0.2, 0.2))

func win():
	if ended:
		return
	end_game("THẮNG", Color(0.3, 1, 0.4))

func end_game(text, color):
	ended = true
	get_tree().paused = true
	var l = Label.new()
	l.text = text
	l.position = Vector2(440, 180)
	l.add_theme_font_size_override("font_size", 96)
	l.add_theme_color_override("font_color", color)
	add_child(l)
	var b = Button.new()
	b.text = "Chơi lại"
	b.process_mode = Node.PROCESS_MODE_ALWAYS
	b.position = Vector2(476, 340)
	b.custom_minimum_size = Vector2(200, 60)
	b.pressed.connect(restart)
	add_child(b)

func restart():
	get_tree().paused = false
	get_tree().reload_current_scene()

func update_label():
	hp_label.text = "Đợt %d | Căn cứ: %d" % [wave, base_hp]

func show_banner(text):
	var l = Label.new()
	l.text = text
	l.position = Vector2(380, 230)
	l.add_theme_font_size_override("font_size", 72)
	l.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	add_child(l)
	await get_tree().create_timer(3.0).timeout
	l.queue_free()
