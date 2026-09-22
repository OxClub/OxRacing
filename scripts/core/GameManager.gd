extends Node3D

var car: Node3D
var camera: Camera3D
var speed := 0.0
var steer := 0.0
var nitro := 100.0
var lap := 1
var elapsed := 0.0
var accelerating := false
var braking := false
var left_pressed := false
var right_pressed := false

var road_mat: StandardMaterial3D
var line_mat: StandardMaterial3D
var grass_mat: StandardMaterial3D
var building_mats: Array[StandardMaterial3D] = []

func mat(color: Color) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.85
	return m

func box(parent: Node3D, pos: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var n = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = size
	n.mesh = mesh
	n.position = pos
	n.material_override = material
	parent.add_child(n)
	return n

func cyl(parent: Node3D, pos: Vector3, radius: float, height: float, material: Material) -> MeshInstance3D:
	var n = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	n.mesh = mesh
	n.position = pos
	n.material_override = material
	parent.add_child(n)
	return n

func _ready() -> void:
	road_mat = mat(Color("#30343b"))
	line_mat = mat(Color("#f5e6a8"))
	grass_mat = mat(Color("#3b7040"))

	building_mats = [
		mat(Color("#8b96a8")),
		mat(Color("#b06b52")),
		mat(Color("#65788f")),
		mat(Color("#9b8c72")),
		mat(Color("#56616e")),
		mat(Color("#b08b78"))
	]

	create_environment()
	create_city()
	create_car()
	create_camera()
	create_hud()
\t_add_scenery_upgrade()

func create_environment() -> void:
	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#8fc7e8")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#ffffff")
	env.ambient_light_energy = 0.75
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env_node.environment = env
	add_child(env_node)

	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -25, 0)
	sun.light_energy = 1.1
	sun.shadow_enabled = true
	add_child(sun)

func create_city() -> void:
	box(self, Vector3(0, -0.3, 0), Vector3(180, 0.5, 180), grass_mat)

	# Large rectangular racing circuit.
	box(self, Vector3(0, 0, -65), Vector3(130, 0.2, 18), road_mat)
	box(self, Vector3(0, 0, 65), Vector3(130, 0.2, 18), road_mat)
	box(self, Vector3(-65, 0, 0), Vector3(18, 0.2, 130), road_mat)
	box(self, Vector3(65, 0, 0), Vector3(18, 0.2, 130), road_mat)

	# Inner road connection strips make the circuit continuous.
	box(self, Vector3(-58, 0, -58), Vector3(32, 0.2, 18), road_mat)
	box(self, Vector3(58, 0, -58), Vector3(32, 0.2, 18), road_mat)
	box(self, Vector3(-58, 0, 58), Vector3(32, 0.2, 18), road_mat)
	box(self, Vector3(58, 0, 58), Vector3(32, 0.2, 18), road_mat)

	# Road center markings.
	for x in range(-55, 56, 10):
		box(self, Vector3(x, 0.13, -65), Vector3(5, 0.04, 0.35), line_mat)
		box(self, Vector3(x, 0.13, 65), Vector3(5, 0.04, 0.35), line_mat)

	for z in range(-55, 56, 10):
		box(self, Vector3(-65, 0.13, z), Vector3(0.35, 0.04, 5), line_mat)
		box(self, Vector3(65, 0.13, z), Vector3(0.35, 0.04, 5), line_mat)

	# City buildings around the circuit.
	for x in range(-85, 86, 14):
		if abs(x) < 75:
			add_building(Vector3(x, 0, -84))
			add_building(Vector3(x, 0, 84))

	for z in range(-70, 71, 14):
		if abs(z) < 60:
			add_building(Vector3(-84, 0, z))
			add_building(Vector3(84, 0, z))

	# Extra inner city blocks.
	for x in [-35.0, -18.0, 18.0, 35.0]:
		for z in [-35.0, 35.0]:
			add_building(Vector3(x, 0, z))

	# Street lights.
	for x in range(-55, 56, 20):
		add_street_light(Vector3(x, 0, -53))
		add_street_light(Vector3(x, 0, 53))

func add_building(p: Vector3) -> void:
	var h = 8.0 + float((abs(int(p.x)) + abs(int(p.z))) % 5) * 3.0
	var w = 8.0
	var d = 8.0
	box(self, Vector3(p.x, h * 0.5, p.z), Vector3(w, h, d), building_mats[(abs(int(p.x)) + abs(int(p.z))) % building_mats.size()])

	# Simple rooftop block.
	if h > 14:
		box(self, Vector3(p.x, h + 1.0, p.z), Vector3(3, 2, 3), building_mats[0])

func add_street_light(p: Vector3) -> void:
	var pole_mat = mat(Color("#25282b"))
	cyl(self, p + Vector3(0, 3, 0), 0.12, 6.0, pole_mat)
	box(self, p + Vector3(0.7, 6.0, 0), Vector3(1.5, 0.12, 0.12), pole_mat)
	var light_mat = mat(Color("#fff2ad"))
	box(self, p + Vector3(1.4, 5.8, 0), Vector3(0.35, 0.35, 0.35), light_mat)

func create_car() -> void:
	car = Node3D.new()
	car.name = "PlayerCar"
	car.position = Vector3(0, 1.0, -65)
	add_child(car)

	var body = box(car, Vector3(0, 0.5, 0), Vector3(2.5, 0.7, 4.4), mat(Color("#d51f2f")))
	box(car, Vector3(0, 1.0, 0.1), Vector3(1.8, 0.55, 2.0), mat(Color("#18212d")))

	var wheel_mat = mat(Color("#111111"))
	for x in [-1.25, 1.25]:
		for z in [-1.35, 1.35]:
			var w = cyl(car, Vector3(x, 0.25, z), 0.42, 0.3, wheel_mat)
			w.rotation_degrees = Vector3(90, 0, 0)

func create_camera() -> void:
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 70
	add_child(camera)

func create_hud() -> void:
\t_add_scenery_upgrade()
	var layer = CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)

	var title = Label.new()
	title.text = "OXRACING"
	title.position = Vector2(35, 25)
	title.add_theme_font_size_override("font_size", 32)
	layer.add_child(title)

	var lap_label = Label.new()
	lap_label.name = "Lap"
	lap_label.text = "LAP 1 / 3"
	lap_label.position = Vector2(35, 70)
	lap_label.add_theme_font_size_override("font_size", 24)
	layer.add_child(lap_label)

	var speed_label = Label.new()
	speed_label.name = "Speed"
	speed_label.position = Vector2(35, 105)
	speed_label.add_theme_font_size_override("font_size", 22)
	layer.add_child(speed_label)

	var nitro_label = Label.new()
	nitro_label.name = "Nitro"
	nitro_label.position = Vector2(35, 138)
	nitro_label.add_theme_font_size_override("font_size", 20)
	layer.add_child(nitro_label)

	make_button(layer, "◀", Vector2(45, 570), Vector2(100, 100), "left")
	make_button(layer, "▶", Vector2(165, 570), Vector2(100, 100), "right")
	make_button(layer, "BRAKE", Vector2(1000, 585), Vector2(110, 75), "brake")
	make_button(layer, "GO", Vector2(1130, 540), Vector2(110, 110), "accelerate")
	make_button(layer, "NITRO", Vector2(1000, 495), Vector2(110, 65), "nitro")

func make_button(layer: CanvasLayer, text_value: String, pos: Vector2, size: Vector2, action: String) -> void:
	var b = Button.new()
	b.text = text_value
	b.position = pos
	b.size = size
	b.add_theme_font_size_override("font_size", 22)
	layer.add_child(b)

	b.button_down.connect(func():
		set_action(action, true)
	)
	b.button_up.connect(func():
		set_action(action, false)
	)

func set_action(action: String, value: bool) -> void:
	match action:
		"left": left_pressed = value
		"right": right_pressed = value
		"accelerate": accelerating = value
		"brake": braking = value
		"nitro":
			if value and nitro > 0:
				speed = min(speed + 12.0, 55.0)

func _process(delta: float) -> void:
	if car == null:
		return

	elapsed += delta

	var keyboard_accel = Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	var keyboard_brake = Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)
	var keyboard_left = Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)
	var keyboard_right = Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)

	var accel = accelerating or keyboard_accel
	var brake = braking or keyboard_brake
	var left = left_pressed or keyboard_left
	var right = right_pressed or keyboard_right

	if accel:
		speed = move_toward(speed, 38.0, 22.0 * delta)
	else:
		speed = move_toward(speed, 0.0, 7.0 * delta)

	if brake:
		speed = move_toward(speed, 0.0, 35.0 * delta)

	var steering = 0.0
	if left:
		steering -= 1.0
	if right:
		steering += 1.0

	car.rotate_y(-steering * 1.7 * delta * clamp(speed / 15.0, 0.2, 2.0))
	car.translate_object_local(Vector3(0, 0, -speed * delta))

	# Keep the player roughly inside the city.
	car.position.x = clamp(car.position.x, -72.0, 72.0)
	car.position.z = clamp(car.position.z, -72.0, 72.0)

	# Chase camera.
	var behind = car.global_position + car.global_transform.basis.z * 10.0 + Vector3(0, 6, 0)
	camera.global_position = camera.global_position.lerp(behind, min(delta * 6.0, 1.0))
	camera.look_at(car.global_position + Vector3(0, 1, 0))

	var hud = get_node_or_null("HUD")
	if hud:
		hud.get_node("Speed").text = "SPEED  %03d KM/H" % int(speed * 3.0)
		hud.get_node("Nitro").text = "NITRO  %03d%%" % int(nitro)

	if speed > 30.0 and nitro > 0 and Input.is_key_pressed(KEY_SHIFT):
		nitro = max(0.0, nitro - 25.0 * delta)
		speed = min(55.0, speed + 15.0 * delta)

func _add_scenery_upgrade() -> void:
	var scenery_script := load("res://scripts/core/Scenery.gd")
	if scenery_script:
		var scenery := Node3D.new()
		scenery.name = "CityScenery"
		scenery.set_script(scenery_script)
		add_child(scenery)
