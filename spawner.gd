extends Path2D

@export var boat_scene: PackedScene
@export var stake_scene: PackedScene
var total_waves := 5
var skip := false
var stake_ratios := [0.35, 0.65, 0.2, 0.5, 0.8, 0.9]
var stakes_per_wave := {3: 2, 5: 4}
var stakes_placed := 0

# [thuyền nhỏ, thuyền lớn, giây giữa hai thuyền]
var wave_data := {
	1: [5, 0, 1.5],
	2: [10, 0, 1.2],
	3: [8, 5, 1.2],
	4: [0, 10, 1.8],
	5: [6, 6, 1.2],
}

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		var k = event.physical_keycode
		if (k == KEY_SPACE and Input.is_physical_key_pressed(KEY_V)) or (k == KEY_V and Input.is_physical_key_pressed(KEY_SPACE)):
			skip_wave()

func skip_wave():
	skip = true
	for b in get_tree().get_nodes_in_group("boats"):
		b.get_parent().queue_free()
	for b in get_tree().get_nodes_in_group("boss"):
		b.get_parent().queue_free()

func add_stake():
	if stake_scene == null or stakes_placed >= stake_ratios.size():
		return
	var s = stake_scene.instantiate()
	s.position = curve.sample_baked(stake_ratios[stakes_placed] * curve.get_baked_length())
	stakes_placed += 1
	add_child(s)

func raise_stakes(count):
	for i in count:
		await get_tree().create_timer(2.0).timeout
		add_stake()

func enemies_left():
	return get_tree().get_nodes_in_group("boats").size() + get_tree().get_nodes_in_group("boss").size()

func build_list(small, big):
	var list := []
	for i in small:
		list.append(false)
	for i in big:
		list.append(true)
	list.shuffle()
	return list

func _ready():
	smooth_curve()
	draw_river()
	await get_tree().process_frame
	for w in range(1, total_waves + 1):
		get_parent().set_wave(w)
		if stakes_per_wave.has(w):
			raise_stakes(stakes_per_wave[w])
		if w == 4:
			spawn_boss(false)
		if w == 5:
			get_parent().show_banner("PHẢN CÔNG!")
			await get_tree().create_timer(7.0).timeout
			if not skip:
				spawn_retreat()
		var d = wave_data[w]
		for is_big in build_list(d[0], d[1]):
			if skip:
				break
			spawn_boat(w, is_big)
			await get_tree().create_timer(d[2]).timeout
		while enemies_left() > 0:
			await get_tree().create_timer(0.5).timeout
		await get_tree().create_timer(3.0).timeout
		skip = false
	get_parent().win()

func spawn_boat(w, is_big):
	var b = boat_scene.instantiate()
	b.hp = 3 + int(w * 0.5)
	b.speed = 80.0 + w * 10.0
	if is_big:
		b.big = true
		b.hp *= 3
		b.speed *= 0.6
	var f = PathFollow2D.new()
	f.loop = false
	add_child(f)
	f.add_child(b)

func spawn_boss(flee):
	var b = boat_scene.instantiate()
	b.boss = true
	b.flee = flee
	b.hp = 18
	b.speed = 50.0 if flee else 40.0
	var f = PathFollow2D.new()
	f.loop = false
	add_child(f)
	if flee:
		f.progress_ratio = 0.85
	f.add_child(b)

func spawn_retreat():
	spawn_boss(true)
	var ratios = [0.78, 0.72, 0.66]
	var bigs = [true, true, false]
	for i in 3:
		spawn_flee_boat(ratios[i], bigs[i])

func spawn_flee_boat(ratio, is_big):
	var b = boat_scene.instantiate()
	b.flee = true
	b.hp = 6
	b.speed = 60.0
	if is_big:
		b.big = true
		b.hp = 15
		b.speed = 45.0
	var f = PathFollow2D.new()
	f.loop = false
	add_child(f)
	f.progress_ratio = ratio
	f.add_child(b)
	
func smooth_curve():
	var n = curve.point_count
	var pts = []
	for i in n:
		pts.append(curve.get_point_position(i))
	for i in n:
		var prev = pts[max(i - 1, 0)]
		var next = pts[min(i + 1, n - 1)]
		var tangent = (next - prev) * 0.2
		curve.set_point_in(i, -tangent)
		curve.set_point_out(i, tangent)

func draw_river():
	var pts = curve.get_baked_points()
	var layers = [[190.0, Color("c9b27c")], [150.0, Color("2f7fb8")], [90.0, Color("4aa3d8")]]
	for l in layers:
		var r = Line2D.new()
		r.points = pts
		r.width = l[0]
		r.default_color = l[1]
		r.joint_mode = Line2D.LINE_JOINT_ROUND
		r.begin_cap_mode = Line2D.LINE_CAP_ROUND
		r.end_cap_mode = Line2D.LINE_CAP_ROUND
		r.antialiased = true
		r.z_index = -1
		add_child(r)
