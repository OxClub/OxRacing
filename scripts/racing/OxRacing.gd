extends Node3D

# ============================================================
# OXRACING - PROFESSIONAL STUNT COURSE
# Procedural 3D mobile racing level
# ============================================================

const ROAD_WIDTH := 10.0
const SEGMENT_LENGTH := 8.0
const TOTAL_SEGMENTS := 90

var car: Node3D
var camera: Camera3D

var speed := 0.0
var nitro := 100.0
var coins := 0
var progress := 0.0
var finished := false

var steer := 0.0
var touch_left := false
var touch_right := false
var touch_nitro := false

var road_points: Array[Vector3] = []

var speed_label: Label
var progress_label: Label
var coins_label: Label
var nitro_bar: ProgressBar
var state_label: Label
var finish_panel: Panel


func _ready() -> void:
	_build_environment()
	_build_track()
	_build_car()
	_build_camera()
	_build_ui()


# ============================================================
# MATERIALS
# ============================================================

func material(hex: String, metallic := 0.0, roughness := 0.7) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(hex)
	m.metallic = metallic
	m.roughness = roughness
	return m


# ============================================================
# ENVIRONMENT
# ============================================================

func _build_environment() -> void:
	var world := WorldEnvironment.new()

	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#09111f")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#9eb7d5")
	env.ambient_light_energy = 0.8
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC

	world.environment = env
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -25, 0)
	sun.light_energy = 1.4
	sun.shadow_enabled = true
	add_child(sun)

	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-25, 150, 0)
	moon.light_energy = 0.18
	add_child(moon)


# ============================================================
# TRACK GENERATION
# ============================================================

func _build_track() -> void:
	var curve := Curve3D.new()

	var points := [
		Vector3(0, 0, 10),
		Vector3(0, 0, -25),
		Vector3(4, 0, -55),
		Vector3(7, 2, -85),
		Vector3(3, 4, -115),
		Vector3(-5, 4, -145),
		Vector3(-7, 4, -175),
		Vector3(-2, 6, -205),
		Vector3(5, 7, -235),
		Vector3(6, 7, -265),
		Vector3(0, 9, -295),
		Vector3(-6, 9, -325),
		Vector3(-4, 12, -350),
		Vector3(4, 12, -375),
		Vector3(7, 8, -400),
		Vector3(2, 4, -425),
		Vector3(0, 0, -455)
	]

	for p in points:
		curve.add_point(p)

	road_points = _sample_curve(curve)

	for i in range(road_points.size() - 1):
		_make_road_piece(
			road_points[i],
			road_points[i + 1],
			i
		)

	# Grass world.
	var ground := MeshInstance3D.new()
	var ground_mesh := BoxMesh.new()
	ground_mesh.size = Vector3(180, 1, 520)
	ground.mesh = ground_mesh
	ground.position = Vector3(0, -3, -220)
	ground.material_override = material("#14261b")
	add_child(ground)

	# Track decorations.
	for i in range(4, road_points.size(), 6):
		_make_track_marker(road_points[i], i)

	# Special sections.
	_make_ramp_section(road_points[18])
	_make_ramp_section(road_points[42])
	_make_ramp_section(road_points[62])

	_make_boost(road_points[8])
	_make_boost(road_points[30])
	_make_boost(road_points[53])
	_make_boost(road_points[72])

	_make_obstacle(road_points[25], -2.5)
	_make_obstacle(road_points[25], 2.5)

	_make_obstacle(road_points[48], 0)

	_make_obstacle(road_points[67], -2.5)

	# Coins along the racing line.
	for i in range(6, road_points.size() - 3, 5):
		_make_coin(road_points[i] + Vector3.UP * 1.7)

	_make_finish(road_points[road_points.size() - 1])


func _sample_curve(curve: Curve3D) -> Array[Vector3]:
	var result: Array[Vector3] = []

	for i in range(TOTAL_SEGMENTS + 1):
		var t := float(i) / float(TOTAL_SEGMENTS)
		result.append(curve.sample_baked(curve.get_baked_length() * t))

	return result


func _make_road_piece(a: Vector3, b: Vector3, index: int) -> void:
	var midpoint := (a + b) * 0.5
	var length := a.distance_to(b)

	var road := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(ROAD_WIDTH, 0.35, length + 0.3)
	road.mesh = mesh
	road.position = midpoint
	road.look_at(b, Vector3.UP)
	road.rotation_degrees.x = 0
	road.material_override = material(
		"#292d38" if index % 2 == 0 else "#252933"
	)
	add_child(road)

	# Edge strips.
	_make_edge(a, b, -ROAD_WIDTH * 0.52)
	_make_edge(a, b, ROAD_WIDTH * 0.52)

	# Centre markings.
	if index % 2 == 0:
		var mark := MeshInstance3D.new()
		var mark_mesh := BoxMesh.new()
		mark_mesh.size = Vector3(0.18, 0.08, min(length * 0.55, 4.0))
		mark.mesh = mark_mesh
		mark.position = midpoint + Vector3.UP * 0.21
		mark.look_at(b, Vector3.UP)
		mark.material_override = material("#f4f4f4")
		add_child(mark)


func _make_edge(a: Vector3, b: Vector3, offset: float) -> void:
	var midpoint := (a + b) * 0.5
	var direction := (b - a).normalized()
	var side := Vector3(-direction.z, 0, direction.x)
	var pos := midpoint + side * offset

	var edge := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.35, 0.3, a.distance_to(b))
	edge.mesh = mesh
	edge.position = pos
	edge.look_at(b + side * offset, Vector3.UP)
	edge.material_override = material("#e63935")
	add_child(edge)


func _make_track_marker(pos: Vector3, index: int) -> void:
	var left := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.5, 2.0, 0.5)
	left.mesh = mesh
	left.position = pos + Vector3(-6, 1, 0)
	left.material_override = material("#ffca3a")
	add_child(left)

	var right := left.duplicate()
	right.position = pos + Vector3(6, 1, 0)
	add_child(right)


# ============================================================
# STUNTS
# ============================================================

func _make_ramp_section(pos: Vector3) -> void:
	var ramp := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(9, 1.2, 12)
	ramp.mesh = mesh
	ramp.position = pos + Vector3.UP * 0.6
	ramp.rotation_degrees.x = -13
	ramp.material_override = material("#e56b26", 0.1, 0.55)
	add_child(ramp)

	for x in [-3.0, 0.0, 3.0]:
		var stripe := MeshInstance3D.new()
		var stripe_mesh := BoxMesh.new()
		stripe_mesh.size = Vector3(0.3, 1.35, 10)
		stripe.mesh = stripe_mesh
		stripe.position = pos + Vector3(x, 1.25, 0)
		stripe.rotation_degrees.x = -13
		stripe.material_override = material("#ffd23f")
		add_child(stripe)


func _make_boost(pos: Vector3) -> void:
	var pad := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(5.5, 0.08, 7)
	pad.mesh = mesh
	pad.position = pos + Vector3.UP * 0.25
	pad.material_override = material("#10a8ff", 0.2, 0.3)
	add_child(pad)

	for x in [-1.5, 0, 1.5]:
		var arrow := MeshInstance3D.new()
		var arrow_mesh := BoxMesh.new()
		arrow_mesh.size = Vector3(0.4, 0.12, 2.2)
		arrow.mesh = arrow_mesh
		arrow.position = pos + Vector3(x, 0.35, 0)
		arrow.material_override = material("#ffffff")
		add_child(arrow)


func _make_obstacle(pos: Vector3, x_offset: float) -> void:
	var obstacle := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(2.3, 2.0, 2.3)
	obstacle.mesh = mesh
	obstacle.position = pos + Vector3(x_offset, 1, 0)
	obstacle.material_override = material("#e33b35")
	add_child(obstacle)

	var warning := MeshInstance3D.new()
	var warning_mesh := BoxMesh.new()
	warning_mesh.size = Vector3(2.5, 0.18, 2.5)
	warning.mesh = warning_mesh
	warning.position = obstacle.position + Vector3.UP * 1.15
	warning.material_override = material("#ffd23f")
	add_child(warning)


func _make_coin(pos: Vector3) -> void:
	var coin := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.55
	mesh.bottom_radius = 0.55
	mesh.height = 0.16
	coin.mesh = mesh
	coin.position = pos
	coin.rotation_degrees.z = 90
	coin.material_override = material("#ffd23f", 0.6, 0.25)
	add_child(coin)


func _make_finish(pos: Vector3) -> void:
	for x in [-4.5, -1.5, 1.5, 4.5]:
		var tile := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(3, 0.15, 3)
		tile.mesh = mesh
		tile.position = pos + Vector3(x, 0.2, 0)

		if int(x) % 2 == 0:
			tile.material_override = material("#ffffff")
		else:
			tile.material_override = material("#111111")

		add_child(tile)

	var banner := Label3D.new()
	banner.text = "FINISH"
	banner.font_size = 96
	banner.modulate = Color("#ffd43b")
	banner.position = pos + Vector3(0, 5, 0)
	banner.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(banner)


# ============================================================
# CAR
# ============================================================

func _build_car() -> void:
	car = Node3D.new()
	car.position = road_points[0] + Vector3.UP * 1.0
	add_child(car)

	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(2.3, 0.65, 4.1)
	body.mesh = body_mesh
	body.position.y = 0.2
	body.material_override = material("#e3262e", 0.25, 0.3)
	car.add_child(body)

	var hood := MeshInstance3D.new()
	var hood_mesh := BoxMesh.new()
	hood_mesh.size = Vector3(2.0, 0.25, 1.4)
	hood.mesh = hood_mesh
	hood.position = Vector3(0, 0.6, -1.0)
	hood.material_override = material("#ff3d43", 0.2, 0.3)
	car.add_child(hood)

	var cabin := MeshInstance3D.new()
	var cabin_mesh := BoxMesh.new()
	cabin_mesh.size = Vector3(1.65, 0.7, 1.8)
	cabin.mesh = cabin_mesh
	cabin.position = Vector3(0, 0.72, 0.25)
	cabin.material_override = material("#101827", 0.5, 0.2)
	car.add_child(cabin)

	for x in [-1.18, 1.18]:
		for z in [-1.35, 1.35]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.42
			wheel_mesh.bottom_radius = 0.42
			wheel_mesh.height = 0.32
			wheel.mesh = wheel_mesh
			wheel.position = Vector3(x, -0.15, z)
			wheel.rotation_degrees.z = 90
			wheel.material_override = material("#0a0a0c")
			car.add_child(wheel)

	# Headlights.
	for x in [-0.7, 0.7]:
		var light := OmniLight3D.new()
		light.position = Vector3(x, 0.3, -2.1)
		light.omni_range = 8
		light.light_energy = 1.8
		light.light_color = Color("#fff4c4")
		car.add_child(light)


# ============================================================
# CAMERA
# ============================================================

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.current = true
	camera.position = car.position + Vector3(0, 5.5, 10)
	add_child(camera)


# ============================================================
# UI
# ============================================================

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	speed_label = _label(layer, "000 KM/H", Vector2(30, 25), 32)
	progress_label = _label(layer, "LEVEL 1   0%", Vector2(30, 68), 23)
	coins_label = _label(layer, "COINS 0", Vector2(1050, 25), 25)
	state_label = _label(layer, "RACE", Vector2(590, 25), 28)

	nitro_bar = ProgressBar.new()
	nitro_bar.position = Vector2(30, 108)
	nitro_bar.size = Vector2(230, 24)
	nitro_bar.max_value = 100
	nitro_bar.value = 100
	layer.add_child(nitro_bar)

	var left := _button(layer, "◀", Vector2(30, 565), Vector2(105, 90))
	left.button_down.connect(func(): touch_left = true)
	left.button_up.connect(func(): touch_left = false)

	var right := _button(layer, "▶", Vector2(150, 565), Vector2(105, 90))
	right.button_down.connect(func(): touch_right = true)
	right.button_up.connect(func(): touch_right = false)

	var nitro_button := _button(layer, "NITRO", Vector2(1050, 555), Vector2(190, 100))
	nitro_button.button_down.connect(func(): touch_nitro = true)
	nitro_button.button_up.connect(func(): touch_nitro = false)

	finish_panel = Panel.new()
	finish_panel.position = Vector2(390, 205)
	finish_panel.size = Vector2(500, 300)
	finish_panel.visible = false
	layer.add_child(finish_panel)

	var title := Label.new()
	title.text = "🏆  RACE COMPLETE"
	title.position = Vector2(105, 50)
	title.add_theme_font_size_override("font_size", 32)
	finish_panel.add_child(title)

	var reward := Label.new()
	reward.text = "+500 COINS"
	reward.position = Vector2(165, 105)
	reward.add_theme_font_size_override("font_size", 28)
	finish_panel.add_child(reward)

	var replay := Button.new()
	replay.text = "RACE AGAIN"
	replay.position = Vector2(130, 190)
	replay.size = Vector2(240, 60)
	replay.pressed.connect(func(): get_tree().reload_current_scene())
	finish_panel.add_child(replay)


func _label(parent: Node, text_value: String, pos: Vector2, size: int) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = pos
	label.add_theme_font_size_override("font_size", size)
	parent.add_child(label)
	return label


func _button(parent: Node, text_value: String, pos: Vector2, size: Vector2) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = pos
	button.size = size
	button.add_theme_font_size_override("font_size", 30)
	parent.add_child(button)
	return button


# ============================================================
# GAMEPLAY
# ============================================================

func _process(delta: float) -> void:
	if finished:
		return

	var accelerating := true

	var left := touch_left \
		or Input.is_key_pressed(KEY_A) \
		or Input.is_key_pressed(KEY_LEFT)

	var right := touch_right \
		or Input.is_key_pressed(KEY_D) \
		or Input.is_key_pressed(KEY_RIGHT)

	var boosting := touch_nitro \
		or Input.is_key_pressed(KEY_SHIFT)

	if accelerating:
		speed = move_toward(speed, 30.0, 16.0 * delta)

	if boosting and nitro > 0:
		speed = move_toward(speed, 52.0, 35.0 * delta)
		nitro -= 32.0 * delta
	else:
		nitro = min(100.0, nitro + 7.0 * delta)

	steer = 0

	if left:
		steer -= 1

	if right:
		steer += 1

	# Move car forward through the course.
	var movement := speed * delta
	var current_z := car.position.z

	current_z -= movement

	# Find nearest track position.
	var nearest := _nearest_track_point(car.position)

	if nearest >= 0:
		var target := road_points[nearest]
		var lateral := car.position - target

		car.position.x += steer * 9.0 * delta
		car.position.y = move_toward(car.position.y, target.y + 1.0, delta * 8.0)

	# Keep the player on the course.
	car.position.x = clamp(car.position.x, -9.0, 9.0)
	car.position.z = current_z

	progress = clamp(
		(10.0 - car.position.z) / 465.0 * 100.0,
		0.0,
		100.0
	)

	# Camera follows the car.
	var camera_target := car.position + Vector3(0, 5.5, 11)
	camera.position = camera.position.lerp(
		camera_target,
		min(delta * 5.0, 1.0)
	)

	camera.look_at(
		car.position + Vector3(0, 1.0, -14),
		Vector3.UP
	)

	speed_label.text = "%03d KM/H" % int(speed * 4.0)
	progress_label.text = "LEVEL 1   %d%%" % int(progress)
	coins_label.text = "COINS %d" % coins
	nitro_bar.value = nitro

	if boosting and nitro > 0:
		state_label.text = "NITRO!"
	else:
		state_label.text = "RACE"

	if car.position.z <= -450:
		_finish()


func _nearest_track_point(pos: Vector3) -> int:
	var best := -1
	var best_distance := INF

	for i in range(road_points.size()):
		var d := pos.distance_squared_to(road_points[i])

		if d < best_distance:
			best_distance = d
			best = i

	return best


func _finish() -> void:
	finished = true
	speed = 0
	coins += 500
	finish_panel.visible = true
