extends LimboState

## Called once, when state is initialized.
func _setup() -> void:
	pass

## Called when state is entered.
func _enter() -> void:
	print("enter freefall")

## Called when state is exited.
func _exit() -> void:
	print("exit freefall")

## Called each frame when this state is active.
func _update(delta: float) -> void:
	#agent.apply_central_force(Vector3(0, ProjectSettings.get_setting("physics/3d/default_gravity") * delta, 0))
	#agent.desired_velocity = Vector3.ZERO
	#if agent.linear_velocity.is_zero_approx():
		## if stuck in place, jostle the character to reset collisions, hopefully
		#agent.apply_central_impulse(100 * Vector3.UP)
	#agent.move_and_slide()
	#get_root().desired_air_velocity = get_root().wish_dir
	get_root().desired_air_velocity = lerp(get_root().desired_air_velocity, Vector3.ZERO, 0.1 * delta)
