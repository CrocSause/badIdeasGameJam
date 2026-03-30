extends Node3D


@onready var nodeRotate: Node3D = $Rotate
@onready var flip: Node3D = $Rotate/Flip
@onready var nodeSpringarm: SpringArm3D = $Rotate/Flip/SpringArm3D
@onready var nodePointer: Node3D = $AimDebugPointer
@onready var nodeRaycast: RayCast3D = $Rotate/Flip/SpringArm3D/AimRaycast
@onready var first_person: Node3D = $Rotate/Flip/FirstPerson
@onready var camera_third_person: Camera3D = $Rotate/Flip/SpringArm3D/CameraThirdPerson
@onready var camera_first_person: Camera3D = $Rotate/Flip/FirstPerson/CameraFirstPerson
@onready var hold_position: Node3D = $Rotate/Flip/FirstPerson/HoldPosition
@onready var nodePointer_mesh: MeshInstance3D = $AimDebugPointer/AimDebugPointer_internal


var next_distance: float = 10
var camera_distance: float = 10
var scale_in: float = 0.9
var scale_out: float = 1.2

var mouse_movement: Vector2 = Vector2(0,0)
var next_movement: Vector2 = Vector2(0,0)
var view_rotation: Quaternion = Quaternion()
var view_tilt: Quaternion = Quaternion()
#var camera_basis: Basis = Basis.IDENTITY

var aim_dist: float = 0
var aim_norm: Vector3 = Vector3(0, 0, 0)
var aim_pos: Vector3 = Vector3(0, 0, 0)

var look_speed_mult: float = 1
var zoom_speed_mult: float = 1
var capture: bool = true

var colliding: bool = false
var colliding_with: Node

enum LookMode {MOUSE_MOVE, MOUSE_MOVE_NOCAP, MENU_BG, FREEZE, MOUSE_DRAG, FREEZE_CAP}
var look_mode: LookMode = LookMode.MOUSE_MOVE
var middle_mouse_down: bool = false
var use_mouse_movement: bool = true

var process_aim: bool = true
var can_call_click: bool = true

var third_person_select: bool = false
var active_camera: Node
var is_active: bool = true:
	set(value):
		is_active = value
		nodePointer.visible = value
		nodeRaycast.enabled = value
		camera_third_person.current = value
		camera_first_person.current = value
		if value:
			nodeRotate.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			nodeRotate.process_mode = Node.PROCESS_MODE_DISABLED

var input_shims: Dictionary[int, Callable]

# Called when the node enters the scene tree for the first time.
func _ready():
	scale_out = 1 / scale_in
	set_mode_menu()
	GlobalReferences.camera = self
	active_camera = camera_first_person

func add_raycast_exception(col_obj: CollisionObject3D):
	nodeRaycast.add_exception(col_obj)

func get_collider():
	return nodeRaycast.get_collider()

func get_collider_shape():
	return nodeRaycast.get_collider_shape()


func set_mode_move():
	zoom_speed_mult = 1
	look_speed_mult = 1
	use_mouse_movement = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	look_mode = LookMode.MOUSE_MOVE

func set_mode_move_nocap():
	zoom_speed_mult = 1
	look_speed_mult = 1
	use_mouse_movement = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	look_mode = LookMode.MOUSE_MOVE_NOCAP

func set_mode_freeze():
	zoom_speed_mult = 0
	look_speed_mult = 0
	use_mouse_movement = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	look_mode = LookMode.FREEZE

func set_mode_freeze_captured():
	zoom_speed_mult = 0
	look_speed_mult = 0
	use_mouse_movement = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	look_mode = LookMode.FREEZE_CAP

func set_mode_menu():
	zoom_speed_mult = 0
	look_speed_mult = 0.1
	use_mouse_movement = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	look_mode = LookMode.MENU_BG

func set_mode_grab():
	zoom_speed_mult = 1
	look_speed_mult = 5
	use_mouse_movement = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	look_mode = LookMode.MOUSE_DRAG


func _input(event):
	if is_active:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
				next_distance *= lerp(1.0, scale_in, zoom_speed_mult)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
				next_distance *= lerp(1.0, scale_out, zoom_speed_mult)
			elif event.button_index == MOUSE_BUTTON_MIDDLE:
				middle_mouse_down = event.pressed
			elif event.button_index == MOUSE_BUTTON_LEFT and can_call_click and event.pressed and colliding:
				if colliding_with.collision_layer & 4:
					#colliding_with.get_parent()
					colliding_with.click()
			#if look_mode not in [LookMode.MOUSE_MOVE, LookMode.MOUSE_DRAG]:
			if look_mode == LookMode.MENU_BG:
				# when a proper menu is added this needs to be removed and explicitly handled by the menu
				set_mode_move()
			elif look_mode == LookMode.FREEZE:
				set_mode_freeze_captured()
		elif event is InputEventMagnifyGesture:
			next_distance *= lerp(1.0, (1 / event.factor), zoom_speed_mult)
		elif event is InputEventMouseMotion and use_mouse_movement: # and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			next_movement = event.screen_relative * look_speed_mult
		elif event is InputEventMouseMotion and look_mode == LookMode.MOUSE_DRAG and middle_mouse_down:
			next_movement = event.screen_relative * look_speed_mult
		elif event is InputEventPanGesture:
			next_movement = event.delta * 100 * look_speed_mult
		#elif event is InputEventKey:
		#	if event.keycode == KEY_ESCAPE and event.pressed:
		#		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event.is_action_pressed("swap_cameras"):
			if not third_person_select:
				third_person_select = true
				camera_first_person.current = false and is_active
				camera_third_person.current = true and is_active
				nodeSpringarm.spring_length = camera_distance
				active_camera = camera_third_person
			else:
				third_person_select = false
				camera_first_person.current = true and is_active
				camera_third_person.current = false and is_active
				nodeSpringarm.spring_length = 0
				active_camera = camera_first_person
		elif event.is_action_pressed("release_mouse"):# or (event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed):
			if look_mode != LookMode.FREEZE_CAP:
				set_mode_menu()
			else:
				set_mode_freeze()
		for cb in input_shims.values():
			if cb.is_valid():
				cb.call(event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_active:
		camera_distance = lerp(camera_distance, next_distance, 1 - pow(1 - 0.3, 10 * delta))
		nodeSpringarm.spring_length = camera_distance
		mouse_movement = lerp(mouse_movement, next_movement, 1 - pow(1 - 0.8, 10 * delta))
		view_tilt = Quaternion(nodeSpringarm.basis.x, -0.001 * mouse_movement.y)
		var tilt_up: float = nodeSpringarm.basis.y.y
		var m: float = min(max(2.5 * (tilt_up + 0.2), 0.0), 1.0)
		var tilt_fb_temp: float = -0.5 * tilt_up + 0.1
		var feedback: float = lerp(lerp(-tilt_up, tilt_fb_temp, m), lerp(tilt_fb_temp, 0.0, m), m)
		nodeSpringarm.basis = Basis(nodeSpringarm.basis.get_rotation_quaternion() * view_tilt.normalized() * Quaternion(nodeSpringarm.basis.x, nodeSpringarm.basis.y.z * -0.2 * feedback))
		first_person.basis = nodeSpringarm.basis
		view_rotation = Quaternion(nodeRotate.basis.y, -0.001 * mouse_movement.x)
		nodeRotate.basis = Basis(nodeRotate.basis.get_rotation_quaternion() * view_rotation.normalized())
		next_movement = Vector2(0, 0)
		if Input.is_action_pressed("flip_camera"):
			flip.basis = Basis(nodeRotate.basis.y, PI)
		else:
			flip.basis = Basis.IDENTITY
		
		#camera_basis = camera_3d.global_transform.basis

		if process_aim:
			nodePointer.visible = true
			if(nodeRaycast.is_colliding()):
				colliding = true
				colliding_with = nodeRaycast.get_collider()
				nodePointer.visible = true
				aim_pos = nodeRaycast.get_collision_point()
				nodePointer.global_transform.origin = lerp(aim_pos, active_camera.global_position, 0.9)
				aim_dist = nodeRaycast.global_transform.origin.distance_to(aim_pos)
				aim_norm = nodeRaycast.get_collision_normal()
				if aim_norm.is_equal_approx(Vector3(0, 1, 0)) or aim_norm.is_equal_approx(Vector3(0, -1, 0)):
					nodePointer.global_transform.basis = Basis.looking_at(aim_norm, Vector3(1, 0, 0))
				else:
					nodePointer.global_transform.basis = Basis.looking_at(aim_norm)
				#nodePointer_mesh.scale = Vector3(0.05, 0.05, 0.05) * aim_dist * aim_dist
			else:
				colliding = false
				colliding_with = null
				nodePointer.visible = false
				aim_dist = 100000000
		else:
			nodePointer.visible = false
			colliding_with = null

func _exit_tree() -> void:
	set_mode_menu()
