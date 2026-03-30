@tool
extends StaticBody3D


@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d_2: CollisionShape3D = $CollisionShape3D2


@export_range(0, 100, 0.01, "hide_control", "or_greater") var ramp_height: float = 1:
	set(value):
		ramp_height = value
		if collision_shape_3d == null:
			await self.ready
		var shape: ConvexPolygonShape3D = collision_shape_3d.shape
		shape.points[4].y = ramp_height
		shape.points[5].y = ramp_height
		if collision_shape_3d_2 == null:
			await self.ready
		var box: BoxShape3D = collision_shape_3d_2.shape
		box.size.y = ramp_height - ramp_cut_bottom
		collision_shape_3d_2.position.y = (ramp_height + ramp_cut_bottom) * 0.5
		if mesh_instance_3d == null:
			await self.ready
		make_arraymesh()

@export_range(0, 100, 0.01, "hide_control", "or_greater") var ramp_width: float = 1:
	set(value):
		ramp_width = value
		if collision_shape_3d == null:
			await self.ready
		var shape: ConvexPolygonShape3D = collision_shape_3d.shape
		shape.points[0].x = -ramp_width
		shape.points[1].x = ramp_width
		shape.points[2].x = ramp_width
		shape.points[3].x = -ramp_width
		shape.points[4].x = -ramp_width
		shape.points[5].x = ramp_width
		shape.points[6].x = -ramp_width
		shape.points[7].x = ramp_width
		if collision_shape_3d_2 == null:
			await self.ready
		var box: BoxShape3D = collision_shape_3d_2.shape
		box.size.x = ramp_width * 2
		if mesh_instance_3d == null:
			await self.ready
		make_arraymesh()

@export_range(0, 100, 0.01, "hide_control", "or_greater") var ramp_depth: float = 5:
	set(value):
		ramp_depth = value
		if collision_shape_3d == null:
			await self.ready
		var shape: ConvexPolygonShape3D = collision_shape_3d.shape
		shape.points[2].z = -ramp_depth
		shape.points[3].z = -ramp_depth
		shape.points[4].z = -ramp_depth
		shape.points[5].z = -ramp_depth
		if collision_shape_3d_2 == null:
			await self.ready
		#var box: BoxShape3D = collision_shape_3d_2.shape
		collision_shape_3d_2.position.z = -(ramp_depth - 0.5 * ramp_slide_back)
		if mesh_instance_3d == null:
			await self.ready
		make_arraymesh()

@export_range(0, 100, 0.01, "hide_control", "or_greater") var ramp_slide_back: float = 0:
	set(value):
		ramp_slide_back = value
		if collision_shape_3d_2 == null:
			await self.ready
		var box: BoxShape3D = collision_shape_3d_2.shape
		box.size.z = ramp_slide_back
		collision_shape_3d_2.position.z = -(ramp_depth - 0.5 * ramp_slide_back)
		collision_shape_3d.position.z = ramp_slide_back
		if mesh_instance_3d == null:
			await self.ready
		make_arraymesh()

@export_range(0, 100, 0.01, "hide_control", "or_greater") var ramp_cut_bottom: float = 0:
	set(value):
		ramp_cut_bottom = min(value, ramp_height)
		if collision_shape_3d == null:
			await self.ready
		var shape: ConvexPolygonShape3D = collision_shape_3d.shape
		shape.points[2].y = ramp_cut_bottom
		shape.points[3].y = ramp_cut_bottom
		var ramp_bottom_z: float = (ramp_depth * ramp_cut_bottom) / ramp_height - ramp_depth
		shape.points[6].z = ramp_bottom_z
		shape.points[7].z = ramp_bottom_z
		if collision_shape_3d_2 == null:
			await self.ready
		var box: BoxShape3D = collision_shape_3d_2.shape
		box.size.y = ramp_height - ramp_cut_bottom
		collision_shape_3d_2.position.y = (ramp_height + ramp_cut_bottom) * 0.5
		if mesh_instance_3d == null:
			await self.ready
		make_arraymesh()

func make_arraymesh():
	var vertices = PackedVector3Array()
	vertices.push_back(Vector3(-ramp_width, 0, ramp_slide_back))
	vertices.push_back(Vector3(ramp_width, 0, ramp_slide_back))
	vertices.push_back(Vector3(-ramp_width, ramp_height, -ramp_depth + ramp_slide_back))
	vertices.push_back(Vector3(ramp_width, ramp_height, -ramp_depth + ramp_slide_back))
	vertices.push_back(Vector3(-ramp_width, ramp_height, -ramp_depth))
	vertices.push_back(Vector3(ramp_width, ramp_height, -ramp_depth))
	vertices.push_back(Vector3(-ramp_width, ramp_cut_bottom, -ramp_depth))
	vertices.push_back(Vector3(ramp_width, ramp_cut_bottom, -ramp_depth))
	vertices.push_back(Vector3(-ramp_width, ramp_cut_bottom, -ramp_depth + ramp_slide_back))
	vertices.push_back(Vector3(ramp_width, ramp_cut_bottom, -ramp_depth + ramp_slide_back))
	var ramp_bottom_z: float = (ramp_depth * ramp_cut_bottom) / ramp_height - ramp_depth + ramp_slide_back
	vertices.push_back(Vector3(-ramp_width, 0, ramp_bottom_z))
	vertices.push_back(Vector3(ramp_width, 0, ramp_bottom_z))

	var uvs = PackedVector2Array()
	uvs.resize(len(vertices))
	for i in range(0, len(vertices)):
		uvs[i] = Vector2(vertices[i].x, vertices[i].z)
	for i in range(6, len(vertices)):
		uvs[i] += Vector2(0, ramp_height - ramp_cut_bottom)

	# Initialize the ArrayMesh.
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([1, 0, 3, 2, 5, 4, 7, 6, 9, 8, 11, 10, 1, 0])

	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	arr_mesh.resource_local_to_scene = true
	mesh_instance_3d.mesh = arr_mesh

@export var show_debug_mesh_in_game: bool = false

func _ready() -> void:
	if not Engine.is_editor_hint():
		if show_debug_mesh_in_game:
			make_arraymesh()
		else:
			mesh_instance_3d.queue_free()
	else:
		make_arraymesh()
