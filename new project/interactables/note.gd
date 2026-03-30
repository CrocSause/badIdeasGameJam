@tool
extends StaticBody3D

@onready var camera_3d: Camera3D = $rotate/tilt/Camera3D
@onready var plane: MeshInstance3D = $plane
@onready var sub_viewport: SubViewport = $SubViewport
@onready var page: MeshInstance3D = $SubViewport/page
@onready var rich_text_label: RichTextLabel = $SubViewport/MarginContainer/RichTextLabel
@onready var margin_container: MarginContainer = $SubViewport/MarginContainer


@export_group("Page")

@export var note_page: NotePage:
	set(value):
		note_page = value
		if not is_node_ready():
			await ready
		update_page_material(value)

func update_page_material(value):
	print("updating page material")
	var page_material: ShaderMaterial = page.get_active_material(0)
	var page_array = value.get_page().to_separate()
	print(page_array)
	page_material.set_shader_parameter("page_lines", page_array[0])
	page_material.set_shader_parameter("page_lines_repeat", page_array[1])
	page_material.set_shader_parameter("page_lines_use", page_array[2])
	page_material.set_shader_parameter("page_size", Vector2i(page_array[3], page_array[4]))
	page_material.set_shader_parameter("page_loop", page_array[5])

@export_range(0, 3, 1) var rotate: int:
	set(value):
		rotate = value
		if not is_node_ready():
			await ready
		page.get_active_material(0).set_shader_parameter("paper_rotate", value)
@export var flip_x: bool:
	set(value):
		flip_x = value
		if not is_node_ready():
			await ready
		page.get_active_material(0).set_shader_parameter("paper_flip_x", value)
@export var flip_y: bool:
	set(value):
		flip_y = value
		if not is_node_ready():
			await ready
		page.get_active_material(0).set_shader_parameter("paper_flip_y", value)
@export_range(0, 4, 1) var color: int:
	set(value):
		color = value
		if not is_node_ready():
			await ready
		page.get_active_material(0).set_shader_parameter("paper_color_select", value)

@export_group("Text")

@onready var text_edit_delay: Timer = $TextEditDelay

@export var text_margin: Vector4:
	set(value):
		text_margin = value
		if margin_container == null or not is_node_ready():
			await ready
		if not rich_text_label.is_finished():
			await rich_text_label.finished
		if text_edit_delay != null and not text_edit_delay.is_stopped():
			await text_edit_delay.timeout
		if margin_container != null:
			margin_container.add_theme_constant_override(&"margin_left"  , 10 * value.x)
			margin_container.add_theme_constant_override(&"margin_top"   , 10 * value.y)
			margin_container.add_theme_constant_override(&"margin_right" , 10 * value.z)
			margin_container.add_theme_constant_override(&"margin_bottom", 10 * value.w)
			if text_edit_delay != null:
				text_edit_delay.start(0.25)

## https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html
@export_multiline() var text: String = "blah [b][i]blah[/i][/b] [code]blah[/code] [color=red]blah[/color]":
	set(value):
		text = value
		if not is_node_ready() or not rich_text_label.is_finished(): await ready
		rich_text_label.text = text

@export var font_color: Color:
	set(value):
		font_color = value
		if rich_text_label == null or not is_node_ready(): await ready
		if not rich_text_label.is_finished(): await rich_text_label.finished
		if rich_text_label != null: rich_text_label.add_theme_color_override(&"default_color", value)

@export var line_separation: int:
	set(value):
		line_separation = value
		if rich_text_label == null or not is_node_ready(): await ready
		if not rich_text_label.is_finished(): await rich_text_label.finished
		if rich_text_label != null: rich_text_label.add_theme_constant_override(&"line_separation", value)

@export var paragraph_separation: int:
	set(value):
		paragraph_separation = value
		if rich_text_label == null or not is_node_ready(): await ready
		if not rich_text_label.is_finished(): await rich_text_label.finished
		if rich_text_label != null: rich_text_label.add_theme_constant_override(&"paragraph_separation", value)

@export var normal_font: Font:
	set(value):
		normal_font = value
		if rich_text_label == null or not is_node_ready(): await ready
		if not rich_text_label.is_finished(): await rich_text_label.finished
		if rich_text_label != null: rich_text_label.add_theme_font_override(&"normal_font", value)

@export var bold_font: Font:
	set(value):
		bold_font = value
		if rich_text_label == null or not is_node_ready(): await ready
		if not rich_text_label.is_finished(): await rich_text_label.finished
		if rich_text_label != null: rich_text_label.add_theme_font_override(&"bold_font", value)

@export var bold_italics_font: Font:
	set(value):
		bold_italics_font = value
		if rich_text_label == null or not is_node_ready(): await ready
		if not rich_text_label.is_finished(): await rich_text_label.finished
		if rich_text_label != null: rich_text_label.add_theme_font_override(&"bold_italics_font", value)

@export var italics_font: Font:
	set(value):
		italics_font = value
		if rich_text_label == null or not is_node_ready(): await ready
		if not rich_text_label.is_finished(): await rich_text_label.finished
		if rich_text_label != null: rich_text_label.add_theme_font_override(&"italics_font", value)

@export var mono_font: Font:
	set(value):
		mono_font = value
		if rich_text_label == null or not is_node_ready(): await ready
		if not rich_text_label.is_finished(): await rich_text_label.finished
		if rich_text_label != null: rich_text_label.add_theme_font_override(&"mono_font", value)

@export var normal_font_size: int:
	set(value):
		normal_font_size = value
		if rich_text_label == null or not is_node_ready(): await ready
		if not rich_text_label.is_finished(): await rich_text_label.finished
		if rich_text_label != null: rich_text_label.add_theme_font_size_override(&"normal_font_size", value)

@export var bold_font_size: int:
	set(value):
		bold_font_size = value
		if rich_text_label == null or not is_node_ready(): await ready
		if not rich_text_label.is_finished(): await rich_text_label.finished
		if rich_text_label != null: rich_text_label.add_theme_font_size_override(&"bold_font_size", value)

@export var bold_italics_font_size: int:
	set(value):
		bold_italics_font_size = value
		if rich_text_label == null or not is_node_ready(): await ready
		if not rich_text_label.is_finished(): await rich_text_label.finished
		if rich_text_label != null: rich_text_label.add_theme_font_size_override(&"bold_italics_font_size", value)

@export var italics_font_size: int:
	set(value):
		italics_font_size = value
		if rich_text_label == null or not is_node_ready(): await ready
		if not rich_text_label.is_finished(): await rich_text_label.finished
		if rich_text_label != null: rich_text_label.add_theme_font_size_override(&"italics_font_size", value)

@export var mono_font_size: int:
	set(value):
		mono_font_size = value
		if rich_text_label == null or not is_node_ready(): await ready
		if not rich_text_label.is_finished(): await rich_text_label.finished
		if rich_text_label != null: rich_text_label.add_theme_font_size_override(&"mono_font_size", value)

var current_camera: Camera3D
#var curr_cam_original_gxform: Transform3D
var curr_cam_original_xform: Transform3D
var to_cam_pos: Vector3
var to_cam_gpos: Vector3
var to_cam_quat: Quaternion
var from_cam_pos: Vector3
var from_cam_gpos: Vector3
var from_cam_quat: Quaternion
var bez_point_pos: Vector3
var bez_point_gpos: Vector3
var original_fov: float

var interpolate: float = 0
var is_moving_cam: bool = false
var can_cancel: bool = false
var counter: float = 0.0
var counter_max: float = 2.0
var counter_scale: float = 1.0

var input_shim_id: int


func _ready() -> void:
	input_shim_id = self.get_rid().get_id()
	var plane_mat: StandardMaterial3D = plane.mesh.surface_get_material(0)
	plane_mat.albedo_texture = sub_viewport.get_texture()
	plane_mat.emission_texture = sub_viewport.get_texture()
	plane_mat.backlight_texture = sub_viewport.get_texture()
	if Engine.is_editor_hint():
		sub_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	else:
		sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	var enums_are_janky = ["UPDATE_DISABLED", "UPDATE_ONCE", "UPDATE_WHEN_VISIBLE", "UPDATE_WHEN_PARENT_VISIBLE", "UPDATE_ALWAYS"]
	print(enums_are_janky[sub_viewport.render_target_update_mode])
	#print(input_shim_id)
	note_page.connect("changed", update_page_material.bind(note_page))
	page.get_active_material(0).set_shader_parameter("paper_mult_shift", Vector2(randf_range(-20, 20), randf_range(-20, 20)))
	if false: # fold me with > in gutter
		pass
		#var page_names: Array[String] = [
			#"Plain Page",
			#"Vertical Lines",
			#"Wide Horizontal Lines",
			#"Narrow Horizontal Lines",
			#"Narrow Horizontal Lines With Vertical Line",
			#"Wide Grid",
			#"Narrow Grid",
			#"Plus Grid",
			#"IBM Green Bars",
			#"Svema Red Box",
		#]
		#var pages: Array[NotePageCollection] = [
			#NotePageCollection.basic_page(19, 18, 19), # plain
			#NotePageCollection.colors([
				#NotePageCollection.basic_page( 1,  0,  1), # black vert only
				#NotePageCollection.basic_page( 5,  4,  5), # blue vert only
				#NotePageCollection.basic_page( 3,  2,  3), # pink vert only
			#]),
			#NotePageCollection.colors([
				#NotePageCollection.basic_page(59, 58, 59), # black vert only
				#NotePageCollection.basic_page(61, 60, 61), # blue vert only
				#NotePageCollection.basic_page(63, 62, 63), # pink vert only
			#]),
			#NotePageCollection.colors([ # double horizontal
				#NotePageCollection.basic_page(53, 52, 53), # black
				#NotePageCollection.basic_page(55, 54, 55), # blue
			#]),
			#NotePageCollection.colors([ # double horizontal with bar
				#NotePageCollection.variations([ # black
					#NotePageCollection.basic_page(45, 44, 45), # black vertical by hole
					#NotePageCollection.basic_page(47, 46, 47), # pink vertical by hole
				#]),
				#NotePageCollection.variations([ # blue
					#NotePageCollection.basic_page(49, 48, 49), # blue vertical by hole
					#NotePageCollection.basic_page(51, 50, 51), # pink vertical by hole
				#]),
			#]),
			#NotePageCollection.colors([ # big grid
				#NotePageCollection.variations([ # black across
					#NotePageCollection.basic_page( 7,  6,  7), # black down
					#NotePageCollection.basic_page( 9,  8,  9), # pink down
				#]),
				#NotePageCollection.variations([ # blue across
					#NotePageCollection.basic_page(11, 10, 11), # blue down
					#NotePageCollection.basic_page(13, 12, 13), # pink down
				#]),
				#NotePageCollection.variations([ # pink across
					#NotePageCollection.basic_page(15, 14, 15), # black down
					#NotePageCollection.basic_page(17, 16, 17), # pink down
				#])
			#]),
			#NotePageCollection.variations([ # small grid
				#NotePageCollection.colors([
					#NotePageCollection.basic_page(21, 20, 21), # small grid black
					#NotePageCollection.basic_page(23, 22, 23), # small grid blue
					#NotePageCollection.basic_page(25, 24, 25), # small grid pink
				#]),
				#NotePageCollection.colors([ # no vertical on first two
					#NotePageCollection.basic_page(33, 32, 33), # black
					#NotePageCollection.basic_page(35, 34, 35), # blue
					#NotePageCollection.basic_page(37, 36, 37), # pink
				#]),
				#NotePageCollection.colors([ # big grid on first two
					#NotePageCollection.basic_page(39, 38, 39), # black
					#NotePageCollection.basic_page(41, 40, 41), # blue
					#NotePageCollection.basic_page(43, 42, 43), # pink
				#]),
			#]),
			#NotePageCollection.colors([ # plus grid
				#NotePageCollection.basic_page(53, 52, 53), # black
				#NotePageCollection.basic_page(55, 54, 55), # blue
				#NotePageCollection.basic_page(57, 56, 57), # pink
			#]),
			#
			### special pages at end
			#NotePageCollection.alternating_page(26, 27, 1, 1, 16, 13), # ibm green bars continuous feed paper
			### soviet svema magnetic tape i think back of the box for recording notes
			#NotePageCollection.variations([
				#NotePage.from_separate([28, 29, 30, 29, 31, 0, 0, 0], [1, 1, -1, 1, 1, 1, 1, 1], 2, 12, 12, false), # one line gap on top, one line gap on bottom
				#NotePage.from_separate([28, 29, 30, 29, 31, 0, 0, 0], [1, 1, -1, 4, 1, 1, 1, 1], 2, 12, 12, false), # one line gap on top, four line gap on bottom
			#]),
		#]
		#for i in range(0, len(pages)):
			#var npc = pages[i]
			##print(npc)
			#var name = page_names[i]
			#var filename = name.to_lower().replace(" ", "_") + ".tres"
			#filename = "\"res://interactables/note resources/pages/" + filename + "\""
			#ResourceSaver.save(npc, filename)
			#print(filename)

func click():
	#current_camera = get_viewport().get_camera_3d()
	#print("click")
	if GlobalReferences.camera != null:
		#print("GlobalReferences.camera is not null")
		current_camera = GlobalReferences.camera.active_camera
		if current_camera != null:
			#print("GlobalReferences.camera.active_camera is not null")
			GlobalReferences.camera.set_mode_freeze_captured()
			GlobalReferences.camera.input_shims[input_shim_id] = input_shim
			GlobalReferences.camera.can_call_click = false
			GlobalReferences.player.movement.can_move = false
			#curr_cam_original_gxform = current_camera.global_transform
			curr_cam_original_xform = current_camera.transform
			to_cam_pos = camera_3d.position
			to_cam_gpos = camera_3d.global_position
			to_cam_quat = Quaternion(camera_3d.global_transform.basis)
			from_cam_pos = current_camera.global_position - self.global_position
			from_cam_gpos = current_camera.global_position
			from_cam_quat = Quaternion(current_camera.global_transform.basis)
			bez_point_pos = to_cam_pos.normalized() * from_cam_pos.length()
			bez_point_gpos = bez_point_pos + self.global_position
			original_fov = current_camera.fov
			counter = 0
			counter_scale = 1.0
			can_cancel = false
			#var tween = create_tween()
			#tween.tween_property($".", "interpolate", 1, 4.0)
			#tween.parallel().tween_callback(f_can_cancel).set_delay(0.25)
			is_moving_cam = true

func f_can_cancel():
	can_cancel = true

func reset_curr_cam():
	if current_camera != null:
		#print("reset")
		counter = 0
		counter_scale = 1.0
		is_moving_cam = false
		#current_camera.global_transform = curr_cam_original_gxform
		current_camera.transform = curr_cam_original_xform
		GlobalReferences.camera.set_mode_move()
		GlobalReferences.camera.input_shims.erase(input_shim_id)
		GlobalReferences.camera.can_call_click = true
		GlobalReferences.player.movement.can_move = true
		current_camera.fov = original_fov

func input_shim(event):
	if event is InputEventMouseButton:
		if event.pressed and counter > 0.25:
			#print("input shim")
			#var temp_cam_pos  = to_cam_pos
			#var temp_cam_gpos = to_cam_gpos
			#var temp_cam_quat = to_cam_quat
			#to_cam_pos        = from_cam_pos
			#to_cam_gpos       = from_cam_gpos
			#to_cam_quat       = from_cam_quat
			#from_cam_pos      = temp_cam_pos
			#from_cam_gpos     = temp_cam_gpos
			#from_cam_quat     = temp_cam_quat
			#counter = 1.0
			counter_scale = -1.0
			#var tween = create_tween()
			#tween.tween_property($".", "interpolate", 1, 4.0)
			#tween.chain().tween_callback(reset_curr_cam)
			is_moving_cam = true

func _process(delta: float) -> void:
	if current_camera != null:
		if is_moving_cam:
			#print(counter)
			var next_counter = counter + delta * counter_scale
			if next_counter <= counter_max:# and next_counter >= 0:
				counter = next_counter
				interpolate = smoothstep(0, 1, counter / counter_max)
			if counter < 0:
				is_moving_cam = false
				reset_curr_cam()
			else:
				var bez_1 = lerp(from_cam_gpos, bez_point_gpos, interpolate)
				var bez_2 = lerp(bez_point_gpos, to_cam_gpos, interpolate)
				var interpolated_gpos = lerp(bez_1, bez_2, interpolate)
				var interpolated_quat = from_cam_quat.slerp(to_cam_quat, interpolate)
				var new_xform = Transform3D(Basis(interpolated_quat), interpolated_gpos)
				current_camera.global_transform = new_xform
				current_camera.fov = lerp(original_fov, camera_3d.fov, interpolate)

func _on_rich_text_label_finished() -> void:
	if not Engine.is_editor_hint():
		sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
