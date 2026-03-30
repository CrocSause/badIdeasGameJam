extends LimboState

## Called once, when state is initialized.
func _setup() -> void:
	pass

## Called when state is entered.
func _enter() -> void:
	print("enter fallland")
	print("todo: implement landing state")
	#if get_root().is_jump_crouching and not get_root().is_crouching:
		#get_root().crouch_move_objects_back()
	get_root().desired_air_velocity = Vector3.ZERO
	dispatch(&"standup_walk")

## Called when state is exited.
func _exit() -> void:
	print("exit fallland")

## Called each frame when this state is active.
func _update(delta: float) -> void:
	get_root().is_stepping = false
	pass
