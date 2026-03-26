extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var shoe_squeak_1: AudioStreamPlayer3D = $"shoe squeak 1"
@onready var shoe_squeak_2: AudioStreamPlayer3D = $"shoe squeak 2"

var advance_to_next = false

func _physics_process(delta: float) -> void:
	pass

func play_shoe_squeak():
	if advance_to_next == false:
		shoe_squeak_1.play()
		advance_to_next = true
	else:
		shoe_squeak_2.play()
		advance_to_next = false
