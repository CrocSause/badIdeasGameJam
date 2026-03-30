extends LimboState

@onready var camera: Node3D = $"../../Camera"
@onready var stair_raycast_l: RayCast3D = $"../../Faceforward/stair_raycast_l"
@onready var stair_raycast_c: RayCast3D = $"../../Faceforward/stair_raycast_c"
@onready var stair_raycast_r: RayCast3D = $"../../Faceforward/stair_raycast_r"

## Called once, when state is initialized.
func _setup() -> void:
	pass

## Called when state is entered.
func _enter() -> void:
	print("enter walkrun")

## Called when state is exited.
func _exit() -> void:
	print("exit walkrun")

func try_jump() -> void:
	if Input.is_action_just_pressed(&"jump"):# or get_root().last_frame_frozen_this_frame_jump:
		#print("jump-------------------------------------")
		get_root().charbody.freeze = false
		#get_root().want_jump = false
		#agent.linear_velocity *= 5
		var norm = get_root().ground_normal if not get_root().on_ramp else Vector3.UP
		agent.apply_central_impulse(get_root().charbody.mass * (1 * get_root().wish_dir * get_root().ground_friction + 2 * norm + 2 * Vector3.UP))
		get_root().desired_velocity += get_root().wish_dir + norm

## Called each frame when this state is active.
func _update(delta: float) -> void:
	#rotate.basis = camera.nodeRotate.basis
	if Input.is_action_pressed("run"):
		get_root().desired_velocity = get_root().wish_dir * get_root().run_velocity
	else:
		get_root().desired_velocity = get_root().wish_dir * get_root().normal_walk_velocity
	#var step_raycast_hit: bool = false
	#var step_up_height: float = 0
	#if stair_raycast_l.is_colliding():
		#step_raycast_hit = true
		##print(stair_raycast_l.get_collision_point())
		#step_up_height = max(step_up_height, stair_raycast_l.get_collision_point().y - get_root().charbody.global_position.y)
	#if stair_raycast_c.is_colliding():
		#step_raycast_hit = true
		##print(stair_raycast_c.get_collision_point())
		#step_up_height = max(step_up_height, stair_raycast_c.get_collision_point().y - get_root().charbody.global_position.y)
	#if stair_raycast_r.is_colliding():
		#step_raycast_hit = true
		##print(stair_raycast_r.get_collision_point())
		#step_up_height = max(step_up_height, stair_raycast_r.get_collision_point().y - get_root().charbody.global_position.y)
	#if step_up_height < 0.5 and step_up_height > 0.05:
		#print("do stair climb")
		#agent.apply_central_impulse(get_root().charbody.mass * (0.25 * get_root().wish_dir * get_root().ground_friction + step_up_height * 1.5 * Vector3.UP))
		#get_root().desired_velocity += 0.25 * get_root().wish_dir + step_up_height * 1.5 * Vector3.UP
		#if not get_root().is_stepping:
			#get_root().desired_air_velocity += 0.25 * get_root().wish_dir + step_up_height * 20 * Vector3.UP
		#get_root().is_stepping = true
		#get_root().is_jump_crouching = true
		#if not get_root().is_crouching:
			#get_root().crouch_move_objects()
		#var ledge_climb: LimboState = $"../LedgeClimb"
		#if ledge_climb != null:
			#ledge_climb.use_shapecast = false
			#ledge_climb.non_sc_climb_time = 0.2
			#ledge_climb.non_sc_pos = stair_raycast_c.global_position
			#ledge_climb.non_sc_pos.y -= 1
			#ledge_climb.non_sc_pos.y += step_up_height + 0.1
			##step_up_height = 0
			##step_raycast_hit = false
			#dispatch(&"walking_ledgeclimb")
	if get_root().can_move:
		try_jump()
		#agent.move_and_slide()
		if Input.is_action_just_pressed("climb"):
			dispatch(&"walking_ledgeclimb")
	#if not get_root().want_move and not get_root().want_jump and get_root().desired_velocity.length() < 0.001:
		#dispatch(&"idle")
