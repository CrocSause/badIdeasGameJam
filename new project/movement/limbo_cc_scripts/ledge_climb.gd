extends LimboState

@onready var climb_shapecast: ShapeCast3D = $"../../Faceforward/Climb Shapecast"

var is_moving_to_ledge: bool = false
var move_to: Vector3
var wait_frame: bool = false
var use_shapecast: bool = true
var climb_time: float = 1
var non_sc_climb_time: float = 0.2
var non_sc_pos: Vector3

## Called once, when state is initialized.
func _setup() -> void:
	pass

## Called when state is entered.
func _enter() -> void:
	climb_shapecast.enabled = true
	is_moving_to_ledge = false
	wait_frame = false
	print("enter climb")

## Called when state is exited.
func _exit() -> void:
	climb_shapecast.enabled = false
	is_moving_to_ledge = false
	use_shapecast = true
	print("exit climb")

## Called each frame when this state is active.
func _update(delta: float) -> void:
	if wait_frame and not is_moving_to_ledge:
		#print("running shapecast")
		climb_shapecast.enabled = true
		var results = climb_shapecast.collision_result
		#print(results)
		if (use_shapecast and climb_shapecast.is_colliding()) or not use_shapecast:
			#print("found ledges")
			#is_moving_to_ledge = true
			#move_to = results[0].point
			if use_shapecast:
				for i in range(0, climb_shapecast.get_collision_count()):
					var temp_move_to = results[i].point
					print(results[i])
					var charbody = get_root().charbody
					var space_state = charbody.get_world_3d().direct_space_state
					var query = PhysicsShapeQueryParameters3D.new()
					query.shape = climb_shapecast.shape
					query.transform = Transform3D.IDENTITY.translated(temp_move_to + Vector3(0, 1, 0) + 0.1 * results[i].normal)
					query.collision_mask = climb_shapecast.collision_mask
					var result = space_state.intersect_shape(query, 1)
					print(result)
					if len(result) == 0:
						#print("found fittable ledge")
						move_to = temp_move_to
						is_moving_to_ledge = true
						#print(move_to)
						break
			else:
				move_to = non_sc_pos
				is_moving_to_ledge = true
			if is_moving_to_ledge == false:
				#print("exiting")
				dispatch(&"ledgeclimb_finish")
			else:
				print("found suitable ledge")
				get_root().desired_velocity = Vector3.ZERO
				var climb_time_use = climb_time
				if not use_shapecast:
					climb_time_use = non_sc_climb_time
				var climb_tween = get_tree().create_tween()
				move_to.y += 0.05
				climb_tween.tween_property(get_root().charbody, "position", move_to, climb_time_use).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				#climb_tween.chain().tween_property(self, "is_moving_to_ledge", false, 0)
				climb_tween.chain().tween_callback(dispatch.bind(&"ledgeclimb_finish")).set_delay(0)
		else:
			#print("exiting")
			dispatch(&"ledgeclimb_finish")
	wait_frame = true
