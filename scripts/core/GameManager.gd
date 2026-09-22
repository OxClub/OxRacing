extends Node3D

var car: VehicleBody3D
var camera: Camera3D
var nitro := 100.0
var accelerating := false
var braking := false
var left_pressed := false
var right_pressed := false
var nitro_pressed := false

var road_mat: StandardMaterial3D
var curb_mat: StandardMaterial3D
var grass_mat: StandardMaterial3D
var dark_mat: StandardMaterial3D
var building_mats: Array[StandardMaterial3D] = []

func mat(c: Color, rough := 0.8) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	return m

func mesh_box(parent: Node3D, p: Vector3, s: Vector3, material: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = s
	n.mesh = b
	n.position = p
	n.material_override = material
	parent.add_child(n)
	return n

func static_box(parent: Node3D, p: Vector3, s: Vector3, material: Material) -> void:
	var body := StaticBody3D.new()
	body.position = p

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = s
	collision.shape = shape
	body.add_child(collision)

	parent.add_child(body)
	mesh_box(body, Vector3.ZERO, s, material)

func _ready() -> void:
	road_mat = mat(Color("#25282d"))
	curb_mat = mat(Color("#dedbd0"))
	grass_mat = mat(Color("#315f36"))
	dark_mat = mat(Color("#111318"))

	building_mats = [
		mat(Color("#46515d")),
		mat(Color("#6b7078")),
		mat(Color("#8b735f")),
		mat(Color("#3e5967")),
		mat(Color("#7a5c52")),
		mat(Color("#596c5b"))
	]

	create_environment()
	create_city()
	create_car()
	create_camera()
	create_hud()

func create_environment() -> void:
	var world := WorldEnvironment.new()
	var e := Environment.new()

	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("#91c9e8")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color.WHITE
	e.ambient_light_energy = 0.7
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC

	world.environment = e
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, -30, 0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 180.0
	add_child(sun)

func create_city() -> void:
	static_box(
		self,
		Vector3(0, -0.3, 0),
		Vector3(190, 0.5, 190),
		grass_mat
	)

	road(Vector3(0, 0, -65), Vector3(140, 0.25, 20))
	road(Vector3(0, 0, 65), Vector3(140, 0.25, 20))
	road(Vector3(-65, 0, 0), Vector3(20, 0.25, 140))
	road(Vector3(65, 0, 0), Vector3(20, 0.25, 140))

	road(Vector3(-60, 0, -60), Vector3(30, 0.25, 20))
	road(Vector3(60, 0, -60), Vector3(30, 0.25, 20))
	road(Vector3(-60, 0, 60), Vector3(30, 0.25, 20))
	road(Vector3(60, 0, 60), Vector3(30, 0.25, 20))

	for x in range(-58, 59, 12):
		mesh_box(
			self,
			Vector3(x, 0.15, -65),
			Vector3(6, 0.035, 0.28),
			curb_mat
		)
		mesh_box(
			self,
			Vector3(x, 0.15, 65),
			Vector3(6, 0.035, 0.28),
			curb_mat
		)

	for z in range(-58, 59, 12):
		mesh_box(
			self,
			Vector3(-65, 0.15, z),
			Vector3(0.28, 0.035, 6),
			curb_mat
		)
		mesh_box(
			self,
			Vector3(65, 0.15, z),
			Vector3(0.28, 0.035, 6),
			curb_mat
		)

	for x in [-86.0, -66.0, -44.0, -22.0, 22.0, 44.0, 66.0, 86.0]:
		add_building(Vector3(x, 0, -86))
		add_building(Vector3(x, 0, 86))

	for z in [-66.0, -44.0, -22.0, 22.0, 44.0, 66.0]:
		add_building(Vector3(-86, 0, z))
		add_building(Vector3(86, 0, z))

	for x in range(-52, 53, 26):
		add_tree(Vector3(x, 0, -52))
		add_tree(Vector3(x, 0, 52))
		add_lamp(Vector3(x, 0, -54))
		add_lamp(Vector3(x, 0, 54))

func road(p: Vector3, s: Vector3) -> void:
	static_box(self, p, s, road_mat)

	if s.x > s.z:
		for x in range(-60, 61, 10):
			mesh_box(
				self,
				Vector3(x, p.y + 0.15, p.z),
				Vector3(4, 0.035, 0.22),
				curb_mat
			)
	else:
		for z in range(-60, 61, 10):
			mesh_box(
				self,
				Vector3(p.x, p.y + 0.15, z),
				Vector3(0.22, 0.035, 4),
				curb_mat
			)

func add_building(p: Vector3) -> void:
	var seed := abs(int(p.x * 3.0 + p.z * 7.0))
	var h := 10.0 + float(seed % 5) * 4.0
	var w := 11.0 + float(seed % 3) * 2.0
	var d := 10.0 + float((seed / 3) % 3) * 2.0

	var bmat := building_mats[seed % building_mats.size()]

	mesh_box(
		self,
		Vector3(p.x, h / 2.0, p.z),
		Vector3(w, h, d),
		bmat
	)

	mesh_box(
		self,
		Vector3(p.x, h * 0.56, p.z - d * 0.505),
		Vector3(w * 0.72, h * 0.62, 0.08),
		dark_mat
	)

	if h > 18:
		mesh_box(
			self,
			Vector3(p.x, h + 1.0, p.z),
			Vector3(w * 0.35, 2.0, d * 0.35),
			dark_mat
		)

func add_tree(p: Vector3) -> void:
	var trunk := mat(Color("#5a3b27"))
	var leaves := mat(Color("#214f2b"))

	var c := CylinderMesh.new()
	c.top_radius = 0.18
	c.bottom_radius = 0.22
	c.height = 2.5

	var t := MeshInstance3D.new()
	t.mesh = c
	t.position = p + Vector3(0, 1.25, 0)
	t.material_override = trunk
	add_child(t)

	var s := SphereMesh.new()
	s.radius = 1.6
	s.height = 3.2

	var crown := MeshInstance3D.new()
	crown.mesh = s
	crown.position = p + Vector3(0, 3.0, 0)
	crown.material_override = leaves
	add_child(crown)

func add_lamp(p: Vector3) -> void:
	var pole := mat(Color("#20242a"))
	var light := mat(Color("#ffe7a0"))

	var c := CylinderMesh.new()
	c.top_radius = 0.1
	c.bottom_radius = 0.13
	c.height = 6.0

	var n := MeshInstance3D.new()
	n.mesh = c
	n.position = p + Vector3(0, 3, 0)
	n.material_override = pole
	add_child(n)

	mesh_box(
		self,
		p + Vector3(0.55, 5.85, 0),
		Vector3(1.1, 0.12, 0.12),
		pole
	)

	mesh_box(
		self,
		p + Vector3(1.05, 5.7, 0),
		Vector3(0.3, 0.3, 0.3),
		light
	)

func create_car() -> void:
	car = VehicleBody3D.new()
	car.name = "PlayerCar"
	car.mass = 1100.0
	car.linear_damp = 0.15
	car.angular_damp = 1.5
	car.position = Vector3(0, 1.4, -65)
	add_child(car)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()

	shape.size = Vector3(1.9, 0.7, 4.0)
	collision.shape = shape
	collision.position = Vector3(0, 0.65, 0)

	car.add_child(collision)

	mesh_box(
		car,
		Vector3(0, 0.7, 0),
		Vector3(2.1, 0.55, 4.1),
		mat(Color("#c91f31"), 0.45)
	)

	mesh_box(
		car,
		Vector3(0, 1.05, 0.15),
		Vector3(1.55, 0.48, 1.65),
		mat(Color("#101a24"), 0.25)
	)

	mesh_box(
		car,
		Vector3(0, 0.98, -1.5),
		Vector3(1.75, 0.12, 0.65),
		mat(Color("#e5e5e5"), 0.35)
	)

	mesh_box(
		car,
		Vector3(0, 0.55, 2.0),
		Vector3(1.8, 0.18, 0.35),
		dark_mat
	)

	add_wheel(Vector3(-1.0, 0.25, -1.35), true, true)
	add_wheel(Vector3(1.0, 0.25, -1.35), true, true)
	add_wheel(Vector3(-1.0, 0.25, 1.35), false, true)
	add_wheel(Vector3(1.0, 0.25, 1.35), false, true)

func add_wheel(p: Vector3, steering: bool, traction: bool) -> void:
	var w := VehicleWheel3D.new()

	w.position = p
	w.wheel_radius = 0.38
	w.wheel_rest_length = 0.16
	w.suspension_travel = 0.2
	w.suspension_stiffness = 70.0
	w.damping_compression = 0.45
	w.damping_relaxation = 0.55
	w.wheel_friction_slip = 9.0 if steering else 7.5
	w.wheel_roll_influence = 0.08
	w.use_as_steering = steering
	w.use_as_traction = traction

	car.add_child(w)

	var tire := MeshInstance3D.new()
	var cyl := CylinderMesh.new()

	cyl.top_radius = 0.38
	cyl.bottom_radius = 0.38
	cyl.height = 0.28

	tire.mesh = cyl
	tire.rotation_degrees = Vector3(90, 0, 0)
	tire.material_override = dark_mat

	w.add_child(tire)

func create_camera() -> void:
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 68
	add_child(camera)

	camera.global_position = Vector3(0, 7, -75)
	camera.look_at(car.global_position)

func create_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)

	label(layer, "OXRACING", Vector2(35, 24), 32, "Title")
	label(layer, "LAP 1 / 3", Vector2(35, 66), 23, "Lap")
	label(layer, "SPEED 000 KM/H", Vector2(35, 100), 22, "Speed")
	label(layer, "NITRO 100%", Vector2(35, 132), 20, "Nitro")

	button(layer, "◀", Vector2(35, 575), Vector2(105, 105), "left")
	button(layer, "▶", Vector2(155, 575), Vector2(105, 105), "right")
	button(layer, "BRAKE", Vector2(1000, 600), Vector2(105, 70), "brake")
	button(layer, "GO", Vector2(1135, 545), Vector2(110, 110), "accelerate")
	button(layer, "NITRO", Vector2(1000, 515), Vector2(105, 65), "nitro")

func label(
	layer: CanvasLayer,
	text_value: String,
	pos: Vector2,
	size: int,
	name_value: String
) -> void:
	var l := Label.new()
	l.name = name_value
	l.text = text_value
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	layer.add_child(l)

func button(
	layer: CanvasLayer,
	text_value: String,
	pos: Vector2,
	size: Vector2,
	action: String
) -> void:
	var b := Button.new()

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
		"left":
			left_pressed = value
		"right":
			right_pressed = value
		"accelerate":
			accelerating = value
		"brake":
			braking = value
		"nitro":
			nitro_pressed = value

func _physics_process(delta: float) -> void:
	if car == null:
		return

	var accel := accelerating \
		or Input.is_key_pressed(KEY_W) \
		or Input.is_key_pressed(KEY_UP)

	var brake := braking \
		or Input.is_key_pressed(KEY_S) \
		or Input.is_key_pressed(KEY_DOWN)

	var left := left_pressed \
		or Input.is_key_pressed(KEY_A) \
		or Input.is_key_pressed(KEY_LEFT)

	var right := right_pressed \
		or Input.is_key_pressed(KEY_D) \
		or Input.is_key_pressed(KEY_RIGHT)

	var boost := nitro_pressed or Input.is_key_pressed(KEY_SHIFT)

	var steer_input := 0.0

	if left:
		steer_input -= 1.0

	if right:
		steer_input += 1.0

	var speed_kmh := car.linear_velocity.length() * 3.6

	var steer_limit := lerp(
		0.52,
		0.18,
		clamp(speed_kmh / 140.0, 0.0, 1.0)
	)

	car.steering = move_toward(
		car.steering,
		steer_input * steer_limit,
		delta * 4.5
	)

	car.engine_force = 0.0

	if accel:
		car.engine_force = 45.0

	if boost and accel and nitro > 0.0:
		car.engine_force = 85.0
		nitro = max(0.0, nitro - 32.0 * delta)

	if brake:
		car.brake = 32.0
	else:
		car.brake = 0.0

	var target := (
		car.global_position
		+ car.global_transform.basis.z * 10.5
		+ Vector3(0, 5.8, 0)
	)

	camera.global_position = camera.global_position.lerp(
		target,
		min(delta * 7.0, 1.0)
	)

	camera.look_at(car.global_position + Vector3(0, 0.8, 0))

	var hud := get_node_or_null("HUD")

	if hud:
		hud.get_node("Speed").text = "SPEED %03d KM/H" % int(speed_kmh)
		hud.get_node("Nitro").text = "NITRO %03d%%" % int(nitro)
