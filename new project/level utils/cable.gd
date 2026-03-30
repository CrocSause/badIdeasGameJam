@tool
extends Node3D

@onready var csg_polygon_3d: CSGPolygon3D = $CSGPolygon3D
@onready var path_3d: Path3D = $Path3D

var has_valid_nodepath: bool = false
@export_node_path("Node3D") var nodepath: NodePath:
	set(value):
		if value.get_name_count() > 0:
			print("connected to " + value.get_concatenated_names())
			has_valid_nodepath = true
			nodepath = value.slice(0, value.get_name_count())
@export var use_nodepath_position: bool = false

@export var other_position: Vector3:
	set(value):
		other_position = value
		if auto_update and self.ready:
			update_cable_path()
@export var relative: bool:
	set(value):
		relative = value
		if auto_update and self.ready:
			update_cable_path()
@export_range(0, 100, 1) var point_count: int = 10:
	set(value):
		point_count = value
		if auto_update and self.ready:
			update_cable_path()
@export_range(0.01, 10) var sag_factor: float = 0.5:
	set(value):
		sag_factor = value
		if auto_update and self.ready:
			update_cable_path()


func other_make_relative():
	other_position = other_position - self.global_position
	relative = true

func other_make_global():
	other_position = other_position + self.global_position
	relative = false

@export_tool_button("make relative") var button_make_relative = other_make_relative
@export_tool_button("make global") var button_make_global = other_make_global

var debug_color: Color = Color.MAGENTA

func _ready() -> void:
	debug_color = Color.from_ok_hsl(randf(), randf_range(0.8, 1.0), randf_range(0.2, 0.9))
	update_cable_path()

func sinh2(x: float) -> float:
	var s = sinh(x)
	return s * s
	
func arcsinh(x: float) -> float:
	return log(x + sqrt(x * x + 1))

func update_cable_path():
	var other: Vector3 = other_position
	if not relative and self.is_inside_tree():
		other -= self.global_position
	if use_nodepath_position and has_valid_nodepath:
		other = get_node(nodepath).global_transform
	var vec_center_other_xz = other * Vector3(1, 0, 1)
	var vec_center_other_xz_n = vec_center_other_xz.normalized()
	var other_factor: float = other.dot(vec_center_other_xz_n)
	var other_pos2d: Vector2 = Vector2(other_factor, other.y)
	var h1: float = min(0, other_pos2d.y)
	var hd: float = max(0, other_pos2d.y) - h1
	var x1: float = min(0, other_pos2d.x)
	var x2: float = max(0, other_pos2d.x)
	var s: float = x2 - x1
	var c: float = s / sag_factor
	var i_step = other_factor / (point_count - 1)
	#print(h1, " ", hd, " ", x1, " ", x2, " ", s, " ", c)
	if path_3d == null:
		await ready
	path_3d.curve = Curve3D.new()
	for i in range(0, point_count):
		var x = i * i_step
		var x3: float
		if 0 < other_pos2d.y:
			x3 = x - x1
		else:
			x3 = x2 - x
		var arsh_sh: float = arcsinh(hd / (2 * c * sinh(s / (2 * c))))
		var y: float = 2*c
		y *= (
			sinh2(1 / (2 * c) * (x3 - s * 0.5 + c * arsh_sh)) -
			sinh2(0.5 * (s / (2 * c) - arsh_sh))
		)
		y += h1
		#print(x, " ", x3, " ", hd / (2 * c * sinh(s / 2 * c)), " ", arsh_sh, " ", y)
		var pos3d: Vector3 = vec_center_other_xz_n * x + Vector3(0, y, 0)
		path_3d.curve.add_point(pos3d)

@export_tool_button("update curve") var button_update_curve = update_cable_path
@export var auto_update: bool = true

@export_range(3, 8, 1) var cable_profile: float = 4:
	set(value):
		cable_profile = value
		change_cable_profile()
@export_range(0.01, 0.5, 0.01) var cable_thickness: float = 0.1:
	set(value):
		cable_thickness = value
		change_cable_profile()
@export_range(-2, 2, 0.001) var cable_rotate: float = 0:
	set(value):
		cable_rotate = value
		change_cable_profile()
@export var cable_scale: Vector2 = Vector2(1, 1):
	set(value):
		cable_scale = value
		change_cable_profile()
@export_range(-2, 2, 0.001) var cable_rotate2: float = 0:
	set(value):
		cable_rotate2 = value
		change_cable_profile()

func change_cable_profile():
	if csg_polygon_3d == null:
		await self.ready
	var radian = 2 * PI / cable_profile
	var newpoints: Array[Vector2]
	for i in range(0, cable_profile):
		var angle = (i + cable_rotate) * radian
		newpoints.append((cable_scale * Vector2(cable_thickness, 0).rotated(angle)).rotated(PI * cable_rotate2))
	csg_polygon_3d.polygon = PackedVector2Array(newpoints)

@export var cable_material: Material:
	set(value):
		cable_material = value
		if csg_polygon_3d == null:
			await self.ready
		csg_polygon_3d.material = cable_material

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		var use_position: Vector3 = other_position
		if relative:
			use_position += self.global_position
		DebugDraw3D.draw_square(use_position, 0.5, debug_color)
		DebugDraw3D.draw_square(self.global_position, 0.5, debug_color)

func _enter_tree() -> void:
	set_notify_transform(true)
	set_notify_local_transform(true)
	if self.ready:
		update_cable_path()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED or what == NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
		if auto_update and self.ready:
			update_cable_path()
