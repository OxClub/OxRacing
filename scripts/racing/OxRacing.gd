extends Node3D

var car: Node3D
var camera: Camera3D
var speed := 0.0
var nitro := 100.0
var distance := 0.0
var finished := false

var speed_label: Label
var progress_label: Label
var nitro_bar: ProgressBar
var finish_panel: Panel


func _ready() -> void:
	create_world()
	create_car()
	create_camera()
	create_ui()


func mat(hex: String) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(hex)
	return m


func box(pos: Vector3, size: Vector3, color: String) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	n.mesh = mesh
	n.position = pos
	n.material_override = mat(color)
	add_child(n)
	return n


func create_world() -> void:
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#101827")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color.WHITE
	env.ambient_light_energy = 0.8
	env_node.environment = env
	add_child(env_node)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -25, 0)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	add_child(sun)

	box(Vector3(0, -0.5, -215), Vector3(14, 1, 450), "#292d38")
	box(Vector3(0, -1.2, -215), Vector3(100, 1, 450), "#17251b")

	for z in range(0, -440, -20):
		box(Vector3(0, 0.03, z), Vector3(0.25, 0.06, 7), "#ffffff")

	for z in range(0, -440, -15):
		box(Vector3(-7.5, 0.5, z), Vector3(0.5, 1, 10), "#e33b35")
		box(Vector3(7.5, 0.5, z), Vector3(0.5, 1, 10), "#e33b35")

	create_ramp(Vector3(0, 0.5, -65))
	create_ramp(Vector3(-2, 0.5, -160))
	create_ramp(Vector3(2, 0.5, -270))
	create_ramp(Vector3(0, 0.5, -370))

	for z in [-110, -210, -315]:
		box(Vector3(-3.5, 1, z), Vector3(2.5, 2, 2.5), "#e33b35")
		box(Vector3(3.5, 1, z), Vector3(2.5, 2, 2.5), "#e33b35")

	for z in [-35, -230, -335]:
		box(Vector3(0, 0.08, z), Vector3(5, 0.1, 7), "#159ee8")

	for z in [-30, -50, -95, -140, -190, -245, -300, -350, -400]:
		create_coin(Vector3(0, 1.5, z))

	box(Vector3(-5, 0.1, -430), Vector3(1.6, 0.2, 3), "#ffffff")
	box(Vector3(-3, 0.1, -430), Vector3(1.6, 0.2, 3), "#111111")
	box(Vector3(-1, 0.1, -430), Vector3(1.6, 0.2, 3), "#ffffff")
	box(Vector3(1, 0.1, -430), Vector3(1.6, 0.2, 3), "#111111")
	box(Vector3(3, 0.1, -430), Vector3(1.6, 0.2, 3), "#ffffff")
	box(Vector3(5, 0.1, -430), Vector3(1.6, 0.2, 3), "#111111")


func create_ramp(pos: Vector3) -> void:
	var ramp := box(pos, Vector3(9, 1.2, 14), "#e26b25")
	ramp.rotation_degrees.x = -12


func create_coin(pos: Vector3) -> void:
	var coin := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.55
	mesh.bottom_radius = 0.55
	mesh.height = 0.18
	coin.mesh = mesh
	coin.position = pos
	coin.rotation_degrees.z = 90
	coin.material_override = mat("#ffd33d")
	add_child(coin)


func create_car() -> void:
	car = Node3D.new()
	car.position = Vector3(0, 1, 8)
	add_child(car)

	box_car(Vector3(0, 0.3, 0), Vector3(2.4, 0.7, 4), "#e3262e")
	box_car(Vector3(0, 0.85, 0.2), Vector3(1.7, 0.65, 1.8), "#172334")

	for x in [-1.25, 1.25]:
		for z in [-1.25, 1.25]:
			box_car(Vector3(x, -0.15, z), Vector3(0.45, 0.55, 0.8), "#111111")


func box_car(pos: Vector3, size: Vector3, color: String) -> void:
	var n := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	n.mesh = mesh
	n.position = pos
	n.material_override = mat(color)
	car.add_child(n)


func create_camera() -> void:
	camera = Camera3D.new()
	camera.position = Vector3(0, 6, 12)
	add_child(camera)
	camera.current = true


func create_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	speed_label = Label.new()
	speed_label.text = "SPEED 0"
	speed_label.position = Vector2(30, 25)
	speed_label.add_theme_font_size_override("font_size", 30)
	layer.add_child(speed_label)

	progress_label = Label.new()
	progress_label.text = "LEVEL 1   0%"
	progress_label.position = Vector2(30, 65)
	progress_label.add_theme_font_size_override("font_size", 24)
	layer.add_child(progress_label)

	nitro_bar = ProgressBar.new()
	nitro_bar.position = Vector2(30, 105)
	nitro_bar.size = Vector2(220, 25)
	nitro_bar.value = 100
	layer.add_child(nitro_bar)

	var left := Button.new()
	left.text = "◀"
	left.position = Vector2(30, 560)
	left.size = Vector2(110, 90)
	layer.add_child(left)

	var right := Button.new()
	right.text = "▶"
	right.position = Vector2(155, 560)
	right.size = Vector2(110, 90)
	layer.add_child(right)

	var nitro_button := Button.new()
	nitro_button.text = "NITRO"
	nitro_button.position = Vector2(1030, 560)
	nitro_button.size = Vector2(190, 90)
	layer.add_child(nitro_button)

	left.button_down.connect(func(): car.set_meta("left", true))
	left.button_up.connect(func(): car.set_meta("left", false))
	right.button_down.connect(func(): car.set_meta("right", true))
	right.button_up.connect(func(): car.set_meta("right", false))
	nitro_button.button_down.connect(func(): car.set_meta("nitro", true))
	nitro_button.button_up.connect(func(): car.set_meta("nitro", false))

	finish_panel = Panel.new()
	finish_panel.position = Vector2(400, 220)
	finish_panel.size = Vector2(480, 230)
	finish_panel.visible = false
	layer.add_child(finish_panel)

	var finish_text := Label.new()
	finish_text.text = "🏆 LEVEL COMPLETE!\n\n+500 COINS"
	finish_text.position = Vector2(90, 55)
	finish_text.add_theme_font_size_override("font_size", 30)
	finish_panel.add_child(finish_text)

	var replay := Button.new()
	replay.text = "REPLAY"
	replay.position = Vector2(145, 155)
	replay.size = Vector2(190, 50)
	replay.pressed.connect(func(): get_tree().reload_current_scene())
	finish_panel.add_child(replay)


func _process(delta: float) -> void:
	if finished:
		return

	var left := Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)
	var right := Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)
	var accelerate := Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	var boost := Input.is_key_pressed(KEY_SHIFT)

	if car.has_meta("left") and car.get_meta("left"):
		left = true
	if car.has_meta("right") and car.get_meta("right"):
		right = true
	if car.has_meta("nitro") and car.get_meta("nitro"):
		boost = true

	if accelerate:
		speed = move_toward(speed, 32.0, 18.0 * delta)
	else:
		speed = move_toward(speed, 10.0, 6.0 * delta)

	if boost and nitro > 0:
		speed = move_toward(speed, 50.0, 35.0 * delta)
		nitro -= 30.0 * delta
	else:
		nitro = min(100.0, nitro + 8.0 * delta)

	var steer := 0.0
	if left:
		steer -= 1.0
	if right:
		steer += 1.0

	car.position.x += steer * 10.0 * delta
	car.position.x = clamp(car.position.x, -5.3, 5.3)

	car.position.z -= speed * delta
	distance = 8.0 - car.position.z

	if car.position.z <= -430:
		finished = true
		speed = 0
		finish_panel.visible = true

	var target_camera := car.position + Vector3(0, 5.5, 11)
	camera.position = camera.position.lerp(target_camera, delta * 5.0)
	camera.look_at(car.position + Vector3(0, 1, -12))

	speed_label.text = "SPEED %03d KM/H" % int(speed * 4)
	progress_label.text = "LEVEL 1   %d%%" % int(clamp(distance / 438.0 * 100.0, 0, 100))
	nitro_bar.value = nitro
