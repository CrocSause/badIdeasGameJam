@tool
extends Node3D

@export var geo_instance_for_settings: MeshInstance3D

@export var text_mesh: TextMesh

@export var strings: Array[String]

@export var offset: Vector3

@export var rotate_mesh: Vector3

func update():
	for old in get_children():
		old.queue_free()
	for i in range(0, len(strings)):
		#var new_inst = geo_instance_for_settings.duplicate(11)
		var new_inst = MeshInstance3D.new()
		new_inst.mesh = text_mesh.duplicate()
		new_inst.mesh.text = strings[i]
		new_inst.position = i * offset
		new_inst.rotation_degrees = rotate_mesh
		new_inst.visible = true
		add_child(new_inst)

@export_tool_button("Update") var update_action = update

func _ready() -> void:
	update()
