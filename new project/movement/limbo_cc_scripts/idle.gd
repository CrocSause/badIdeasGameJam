extends LimboState

@onready var walk_run: LimboState = $"../WalkRun"

## Called once, when state is initialized.
func _setup() -> void:
	pass

## Called when state is entered.
func _enter() -> void:
	print("enter idle")

## Called when state is exited.
func _exit() -> void:
	print("exit idle")

## Called each frame when this state is active.
func _update(delta: float) -> void:
	#if Input.is_action_just_pressed(&"jump"):
		#get_root().charbody.freeze = false
		#get_root().want_jump = true
	walk_run.try_jump()
	if get_root().want_move:
		dispatch(&"unidle")
	if Input.is_action_just_pressed("climb"):
		dispatch(&"walking_ledgeclimb")
	get_root().desired_velocity = Vector3.ZERO
