extends Node3D

# ============================================================
# OxRacing - Playable 3D stunt racing prototype
# Godot 4.x
# ============================================================

var car: CharacterBody3D
var camera: Camera3D

var speed := 0.0
var max_speed := 34.0
var acceleration := 18.0
var brake_power := 30.0
var steering := 0.0
var nitro := 100.0
var coins := 0
var finished := false

var left_pressed := false
var right_pressed := false
var nitro_pressed := false

var distance := 0.0
var start_z := 10.0
var finish_z := -430.0

var speed_label: Label
var distance_label: Label
var coin_label: Label
var nitro_bar: ProgressBar
var status_label: Label
var finish_panel: Panel
var finish_label: Label


func _ready() -> void:
	_create_environment()
	_create_track()
	_create_car()
	_create_camera()
	_create_hud()


# ============================================================
# ENVIRONMENT
# ============================================================

func _create_environment() -> void:
	var environment := WorldEnvironment.new()
	environment.name = "WorldEnvironment"

	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#101827")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#8fa6c7")
	env.ambient_light_energy = 0.65
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC

	environment.environment = env
	add_child(environment)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-48, -25, 0)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)

	var fill := OmniLight3D.new()
	fill.position = Vector3(0, 10, -100)
	fill.omni_range = 80
	fill.light_energy = 3.0
	add_child(fill)


# ============================================================
# TRACK
# ============================================================

func _create_track() -> void:
	# Main road.
	var road := StaticBody3D.new()
	road.name = "Road"
	add_child(road)

	var road_mesh := MeshInstance3D.new()
	var road_box := BoxMesh.new()
	road_box.size = Vector3(14, 0.5, 450)
	road_mesh.mesh = road_box
	road_mesh.position = Vector3(0, -0.25, -210)
	road_mesh.material_override = _material("#242936")
	road.add_child(road_mesh)

	var road_collision := CollisionShape3D.new()
	var road_shape := BoxShape3D.new()
	road_shape.size = Vector3(14, 0.5, 450)
	road_collision.shape = road_shape
	road_collision.position = Vector3(0, -0.25, -210)
	road.add_child(road_collision)

	# Grass / ground.
	var ground := StaticBody3D.new()
	ground.name = "Ground"
	add_child(ground)

	var ground_mesh := MeshInstance3D.new()
	var ground_box := BoxMesh.new()
	ground_box.size = Vector3(180, 1, 500)
	ground_mesh.mesh = ground_box
	ground_mesh.position = Vector3(0, -0.8, -210)
	ground_mesh.material_override = _material("#17261b")
	ground.add_child(ground_mesh)

	var ground_collision := CollisionShape3D.new()
	var ground_shape := BoxShape3D.new()
	ground_shape.size = Vector3(180, 1, 500)
	ground_collision.shape = ground_shape
	ground_collision.position = Vector3(0, -0.8, -210)
	ground.add_child(ground_collision)

	# Lane markings.
	for z in range(-10, -430, -20):
		_create_box_visual(
			Vector3(0, 0.03, z),
			Vector3(0.35, 0.05, 7),
			"#f4f4f4"
		)

	# Roadside barriers.
	for z in range(-10, -430, -12):
		_create_barrier(Vector3(-8.0, 0.8, z))
		_create_barrier(Vector3(8.0, 0.8, z))

	# Stunt ramps.
	_create_ramp(Vector3(0, 0.8, -65), 12)
	_create_ramp(Vector3(-2, 0.8, -155), 15)
	_create_ramp(Vector3(2, 0.8, -255), 18)
	_create_ramp(Vector3(0, 0.8, -350), 20)

	# Obstacles.
	_create_obstacle(Vector3(-4.0, 1.0, -105))
	_create_obstacle(Vector3(3.8, 1.0, -105))

	_create_obstacle(Vector3(0, 1.0, -205))
	_create_obstacle(Vector3(-3.8, 1.0, -300))

	# Boost strips.
	_create_boost(Vector3(0, 0.15, -35))
	_create_boost(Vector3(-2, 0.15, -225))
	_create_boost(Vector3(2, 0.15, -325))

	# Coins.
	for z in [-25, -48, -125, -140, -180, -230, -280, -315, -365, -395]:
		_create_coin(Vector3(0, 1.4, z))

	_create_finish_line()


func _create_box_visual(pos: Vector3, size: Vector3, color: String) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	mesh_instance.material_override = _material(color)
	add_child(mesh_instance)
	return mesh_instance


func _create_barrier(pos: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	add_child(body)

	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.7, 1.6, 8)
	mesh.mesh = box
	mesh.material_override = _material("#e43d30")
	body.add_child(mesh)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.7, 1.6, 8)
	collision.shape = shape
	body.add_child(collision)


func _create_ramp(pos: Vector3, height: float) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation_degrees.x = -14
	add_child(body)

	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(11, 1.2, 18)
	mesh.mesh = box
	mesh.material_override = _material("#e16b25")
	body.add_child(mesh)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(11, 1.2, 18)
	collision.shape = shape
	body.add_child(collision)

	# Ramp stripes.
	for i in range(-4, 5, 2):
		var stripe := MeshInstance3D.new()
		var stripe_box := BoxMesh.new()
		stripe_box.size = Vector3(0.35, 1.3, 17)
		stripe.mesh = stripe_box
		stripe.position.x = i
		stripe.position.y = 0.65
		stripe.material_override = _material("#ffd34d")
		body.add_child(stripe)


func _create_obstacle(pos: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	add_child(body)

	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(2.5, 2.0, 2.5)
	mesh.mesh = box
	mesh.material_override = _material("#e83b32")
	body.add_child(mesh)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.5, 2.0, 2.5)
	collision.shape = shape
	body.add_child(collision)

	# Yellow warning bar.
	var warning := MeshInstance3D.new()
	var warning_box := BoxMesh.new()
	warning_box.size = Vector3(2.7, 0.25, 2.7)
	warning.mesh = warning_box
	warning.position.y = 1.15
	warning.material_override = _material("#ffd447")
	body.add_child(warning)


func _create_boost(pos: Vector3) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(5.5, 0.08, 7)
	mesh.mesh = box
	mesh.position = pos
	mesh.material_override = _material("#19a9ff")
	add_child(mesh)


func _create_coin(pos: Vector3) -> void:
	var mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.65
	cylinder.bottom_radius = 0.65
	cylinder.height = 0.18
	mesh.mesh = cylinder
	mesh.position = pos
	mesh.rotation_degrees.z = 90
	mesh.material_override = _material("#ffd23f")
	add_child(mesh)

	var spin := SpinCoin.new()
	spin.target = mesh
	mesh.add_child(spin)


func _create_finish_line() -> void:
	for x in [-5.5, -3.5, -1.5, 0.5, 2.5, 4.5]:
		_create_box_visual(
			Vector3(x, 0.08, finish_z),
			Vector3(1.7, 0.1, 1.5),
			"#ffffff" if int(x + 6) % 2 == 0 else "#111111"
		)

	var banner := Label3D.new()
	banner.text = "FINISH"
	banner.font_size = 96
	banner.modulate = Color("#ffdf45")
	banner.position = Vector3(0, 6, finish_z)
	banner.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(banner)


# ============================================================
# CAR
# ============================================================

func _create_car() -> void:
	car = CharacterBody3D.new()
	car.name = "PlayerCar"
	car.position = Vector3(0, 1.1, start_z)
	add_child(car)

	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(2.4, 0.7, 4.2)
	body.mesh = body_mesh
	body.position.y = 0.25
	body.material_override = _material("#e3262e")
	car.add_child(body)

	var cabin := MeshInstance3D.new()
	var cabin_mesh := BoxMesh.new()
	cabin_mesh.size = Vector3(1.75, 0.7, 1.9)
	cabin.mesh = cabin_mesh
	cabin.position = Vector3(0, 0.82, 0.15)
	cabin.material_override = _material("#172334")
	car.add_child(cabin)

	# Front bumper.
	var bumper := MeshInstance3D.new()
	var bumper_mesh := BoxMesh.new()
	bumper_mesh.size = Vector3(2.5, 0.25, 0.25)
	bumper.mesh = bumper_mesh
	bumper.position = Vector3(0, 0.05, -2.15)
	bumper.material_override = _material("#f6f6f6")
	car.add_child(bumper)

	# Wheels.
	for x in [-1.25, 1.25]:
		for z in [-1.35, 1.35]:
			_create_wheel(x, z)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.3, 1.5, 4.0)
	collision.shape = shape
	collision.position.y = 0.3
	car.add_child(collision)


func _create_wheel(x: float, z: float) -> void:
	var wheel := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.42
	cylinder.bottom_radius = 0.42
	cylinder.height = 0.32
	wheel.mesh = cylinder
	wheel.rotation_degrees.z = 90
	wheel.position = Vector3(x, -0.1, z)
	wheel.material_override = _material("#111111")
	car.add_child(wheel)


# ============================================================
# CAMERA
# ============================================================

func _create_camera() -> void:
	camera = Camera3D.new()
	camera.name = "ChaseCamera"
	camera.current = true
	add_child(camera)

	camera.position = Vector3(0, 6, 11)
	camera.rotation_degrees.x = -12


# ============================================================
# HUD
# ============================================================

func _create_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)

	speed_label = _make_label(layer, "SPEED 0 KM/H", Vector2(35, 25), 30)
	distance_label = _make_label(layer, "LEVEL 1   0%", Vector2(35, 65), 24)
	coin_label = _make_label(layer, "COINS 0", Vector2(1050, 25), 25)

	nitro_bar = ProgressBar.new()
	nitro_bar.position = Vector2(35, 105)
	nitro_bar.size = Vector2(230, 25)
	nitro_bar.max_value = 100
	nitro_bar.value = 100
	layer.add_child(nitro_bar)

	status_label = _make_label(layer, "GO!", Vector2(570, 25), 32)

	# Mobile controls.
	var left := _make_button(layer, "◀", Vector2(35, 585), Vector2(105, 90))
	left.button_down.connect(func(): left_pressed = true)
	left.button_up.connect(func(): left_pressed = false)

	var right := _make_button(layer, "▶", Vector2(155, 585), Vector2(105, 90))
	right.button_down.connect(func(): right_pressed = true)
	right.button_up.connect(func(): right_pressed = false)

	var boost := _make_button(layer, "NITRO", Vector2(1080, 570), Vector2(165, 105))
	boost.button_down.connect(func(): nitro_pressed = true)
	boost.button_up.connect(func(): nitro_pressed = false)

	# Finish panel.
	finish_panel = Panel.new()
	finish_panel.position = Vector2(390, 210)
	finish_panel.size = Vector2(500, 280)
	finish_panel.visible = false
	layer.add_child(finish_panel)

	finish_label = _make_label(finish_panel, "", Vector2(45, 40), 32)

	var replay := Button.new()
	replay.text = "REPLAY"
	replay.position = Vector2(130, 185)
	replay.size = Vector2(240, 60)
	replay.pressed.connect(_restart)
	finish_panel.add_child(replay)


func _make_label(parent: Node, text_value: String, pos: Vector2, size: int) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = pos
	label.add_theme_font_size_override("font_size", size)
	parent.add_child(label)
	return label


func _make_button(parent: Node, text_value: String, pos: Vector2, size: Vector2) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = pos
	button.size = size
	button.add_theme_font_size_override("font_size", 32)
	parent.add_child(button)
	return button


# ============================================================
# GAME LOOP
# ============================================================

func _physics_process(delta: float) -> void:
	if finished:
		return

	_read_controls(delta)
	_drive_car(delta)
	_update_camera(delta)
	_update_hud()
	_check_finish()


func _read_controls(delta: float) -> void:
	var steer_input := 0.0

	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT) or left_pressed:
		steer_input -= 1.0

	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT) or right_pressed:
		steer_input += 1.0

	steering = move_toward(steering, steer_input, delta * 7.0)

	var accelerating := Input.is_key_pressed(KEY_W) \
		or Input.is_key_pressed(KEY_UP)

	var braking := Input.is_key_pressed(KEY_S) \
		or Input.is_key_pressed(KEY_DOWN)

	if accelerating:
		speed = move_toward(speed, max_speed, acceleration * delta)
	else:
		speed = move_toward(speed, 8.0, 8.0 * delta)

	if braking:
		speed = move_toward(speed, 0.0, brake_power * delta)

	var using_nitro := Input.is_key_pressed(KEY_SHIFT) or nitro_pressed

	if using_nitro and nitro > 0.0 and speed > 5.0:
		speed = move_toward(speed, max_speed + 18.0, 35.0 * delta)
		nitro = max(0.0, nitro - 30.0 * delta)
	else:
		nitro = min(100.0, nitro + 7.0 * delta)


func _drive_car(delta: float) -> void:
	var steering_strength := 9.0

	if speed > 1.0:
		car.velocity.x = steering * steering_strength
	else:
		car.velocity.x = move_toward(car.velocity.x, 0.0, 20.0 * delta)

	car.velocity.z = -speed

	# Gravity.
	if not car.is_on_floor():
		car.velocity.y -= 22.0 * delta
	else:
		car.velocity.y = -0.5

	car.move_and_slide()

	# Keep car inside the road.
	car.position.x = clamp(car.position.x, -5.4, 5.4)

	distance = start_z - car.position.z

	# Automatic stunt jump over ramp sections.
	if _near_ramp(car.position.z):
		if car.is_on_floor():
			car.velocity.y = 10.5

	# Reset if player falls.
	if car.position.y < -8.0:
		car.position = Vector3(0, 2, start_z - distance)
		car.velocity = Vector3.ZERO
		speed = 0.0


func _near_ramp(z: float) -> bool:
	return (
		abs(z + 65.0) < 9.0
		or abs(z + 155.0) < 9.0
		or abs(z + 255.0) < 9.0
		or abs(z + 350.0) < 9.0
	)


func _update_camera(delta: float) -> void:
	if not car:
		return

	var target := car.global_position + Vector3(0, 5.5, 10.5)

	camera.global_position = camera.global_position.lerp(
		target,
		min(1.0, delta * 5.0)
	)

	camera.look_at(
		car.global_position + Vector3(0, 0.8, -10),
		Vector3.UP
	)


func _update_hud() -> void:
	if speed_label:
		speed_label.text = "SPEED %03d KM/H" % int(speed * 4.0)

	if distance_label:
		var progress := clamp(
			(distance / (start_z - finish_z)) * 100.0,
			0.0,
			100.0
		)
		distance_label.text = "LEVEL 1   %d%%" % int(progress)

	if coin_label:
		coin_label.text = "COINS %d" % coins

	if nitro_bar:
		nitro_bar.value = nitro

	if status_label:
		if speed > max_speed:
			status_label.text = "NITRO!"
		elif not car.is_on_floor():
			status_label.text = "AIR!"
		else:
			status_label.text = "GO!"


func _check_finish() -> void:
	if car.global_position.z <= finish_z:
		_finish_race()


func _finish_race() -> void:
	finished = true
	speed = 0
	car.velocity = Vector3.ZERO

	coins += 500

	finish_panel.visible = true
	finish_label.text = "🏆 LEVEL COMPLETE\n\n+500 COINS\n\nTOTAL COINS: %d" % coins


func _restart() -> void:
	get_tree().reload_current_scene()


func _material(color: String) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color)
	material.roughness = 0.7
	return material


# ============================================================
# COIN SPIN
# ============================================================

class SpinCoin extends Node:
	var target: MeshInstance3D

	func _process(delta: float) -> void:
		if target:
			target.rotate_y(delta * 4.0)
