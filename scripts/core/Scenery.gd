extends Node3D

var trunk_mat: StandardMaterial3D
var leaf_mats: Array[StandardMaterial3D] = []
var building_mats: Array[StandardMaterial3D] = []
var window_mat: StandardMaterial3D
var sidewalk_mat: StandardMaterial3D
var grass_mat: StandardMaterial3D
var lamp_mat: StandardMaterial3D

func make_mat(color: Color, roughness := 0.8) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	return m

func box(p: Vector3, s: Vector3, material: Material) -> void:
	var n := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = s
	n.mesh = mesh
	n.position = p
	n.material_override = material
	add_child(n)

func _ready() -> void:
	trunk_mat = make_mat(Color("#5a3824"))
	window_mat = make_mat(Color("#243d50"), 0.25)
	sidewalk_mat = make_mat(Color("#aaa9a2"))
	grass_mat = make_mat(Color("#3c713c"))
	lamp_mat = make_mat(Color("#20252a"))

	leaf_mats = [
		make_mat(Color("#245b2b")),
		make_mat(Color("#2f6d32")),
		make_mat(Color("#3d7d39")),
		make_mat(Color("#1f4d29"))
	]

	building_mats = [
		make_mat(Color("#59636d")),
		make_mat(Color("#77736d")),
		make_mat(Color("#8a6d58")),
		make_mat(Color("#536b73")),
		make_mat(Color("#765b52")),
		make_mat(Color("#68735f"))
	]

	create_sidewalks()
	create_trees()
	create_extra_buildings()
	create_lamps()
	create_planters()

func create_sidewalks() -> void:
	# Main horizontal sidewalks
	for z in [-54.0, 54.0]:
		box(Vector3(0, 0.13, z), Vector3(140, 0.20, 3.0), sidewalk_mat)

	# Main vertical sidewalks
	for x in [-54.0, 54.0]:
		box(Vector3(x, 0.13, 0), Vector3(3.0, 0.20, 140), sidewalk_mat)

func create_trees() -> void:
	var positions := [
		Vector3(-48, 0, -54), Vector3(-36, 0, -54),
		Vector3(-24, 0, -54), Vector3(-12, 0, -54),
		Vector3(12, 0, -54), Vector3(24, 0, -54),
		Vector3(36, 0, -54), Vector3(48, 0, -54),

		Vector3(-48, 0, 54), Vector3(-36, 0, 54),
		Vector3(-24, 0, 54), Vector3(-12, 0, 54),
		Vector3(12, 0, 54), Vector3(24, 0, 54),
		Vector3(36, 0, 54), Vector3(48, 0, 54),

		Vector3(-54, 0, -42), Vector3(-54, 0, -30),
		Vector3(-54, 0, -18), Vector3(-54, 0, 18),
		Vector3(-54, 0, 30), Vector3(-54, 0, 42),

		Vector3(54, 0, -42), Vector3(54, 0, -30),
		Vector3(54, 0, -18), Vector3(54, 0, 18),
		Vector3(54, 0, 30), Vector3(54, 0, 42)
	]

	for i in positions.size():
		create_tree(positions[i], i)

func create_tree(p: Vector3, index: int) -> void:
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.18
	trunk_mesh.bottom_radius = 0.27
	trunk_mesh.height = 2.6
	trunk.mesh = trunk_mesh
	trunk.position = p + Vector3(0, 1.3, 0)
	trunk.material_override = trunk_mat
	add_child(trunk)

	var height := 2.8 + float(index % 3) * 0.55
	var radius := 1.35 + float((index + 1) % 3) * 0.25

	var crown := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	crown.mesh = sphere
	crown.position = p + Vector3(0, height, 0)
	crown.scale = Vector3(1.0, 1.15, 1.0)
	crown.material_override = leaf_mats[index % leaf_mats.size()]
	add_child(crown)

func create_extra_buildings() -> void:
	var positions := [
		Vector3(-82, 0, -38), Vector3(-82, 0, 38),
		Vector3(82, 0, -38), Vector3(82, 0, 38),
		Vector3(-38, 0, -82), Vector3(38, 0, -82),
		Vector3(-38, 0, 82), Vector3(38, 0, 82)
	]

	for i in positions.size():
		var p := positions[i]
		var h := 12.0 + float(i % 4) * 3.5
		var w := 9.0 + float(i % 3) * 2.0
		var d := 9.0 + float((i + 1) % 3) * 2.0

		box(
			Vector3(p.x, h / 2.0, p.z),
			Vector3(w, h, d),
			building_mats[i % building_mats.size()]
		)

		# Front glass/window strip
		if abs(p.z) > abs(p.x):
			box(
				Vector3(p.x, h * 0.55, p.z - sign(p.z) * d * 0.51),
				Vector3(w * 0.65, h * 0.55, 0.10),
				window_mat
			)
		else:
			box(
				Vector3(p.x - sign(p.x) * w * 0.51, h * 0.55, p.z),
				Vector3(0.10, h * 0.55, d * 0.65),
				window_mat
			)

func create_lamps() -> void:
	var positions := [
		Vector3(-51, 0, -48), Vector3(-27, 0, -48),
		Vector3(27, 0, -48), Vector3(51, 0, -48),
		Vector3(-51, 0, 48), Vector3(-27, 0, 48),
		Vector3(27, 0, 48), Vector3(51, 0, 48)
	]

	for p in positions:
		var pole := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.07
		cylinder.bottom_radius = 0.11
		cylinder.height = 5.5
		pole.mesh = cylinder
		pole.position = p + Vector3(0, 2.75, 0)
		pole.material_override = lamp_mat
		add_child(pole)

		box(
			p + Vector3(0.45, 5.35, 0),
			Vector3(0.9, 0.10, 0.10),
			lamp_mat
		)

func create_planters() -> void:
	for x in [-42.0, -30.0, 30.0, 42.0]:
		box(Vector3(x, 0.35, -51.5), Vector3(2.2, 0.7, 1.5), grass_mat)
		box(Vector3(x, 0.35, 51.5), Vector3(2.2, 0.7, 1.5), grass_mat)
