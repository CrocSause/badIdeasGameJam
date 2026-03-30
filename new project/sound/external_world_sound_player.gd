@tool
extends Node3D

@onready var road_noise: AudioStreamPlayer3D = $"road noise"
@onready var wind_noise: AudioStreamPlayer3D = $"wind noise"
@onready var wind_animation_player: AnimationPlayer = $"wind noise/AnimationPlayer"
@onready var rumble: AudioStreamPlayer3D = $rumble
@onready var wind_2: AudioStreamPlayer3D = $"wind 2"
@onready var blips: AudioStreamPlayer3D = $blips
@onready var blips_2: AudioStreamPlayer3D = $blips2
@onready var wind_hiss: AudioStreamPlayer3D = $"wind hiss"

var external_bus_idx: int
var bass_boost_effect: AudioEffectLowShelfFilter

func _ready() -> void:
	external_bus_idx = AudioServer.get_bus_index(&"External")
	bass_boost_effect = AudioServer.get_bus_effect(external_bus_idx, 0)
	road_noise.pitch_scale = randf_range(0.91, 0.96)
	wind_animation_player.speed_scale = randf_range(0.9, 1.1)
	wind_animation_player.play(&"wind volume", -1, randf_range(0.9, 1.2))
	rumble.pitch_scale = randf_range(0.18, 0.23)
	wind_2.pitch_scale = randf_range(0.95, 1.07)
	blips.pitch_scale = randf_range(0.25, 0.3)
	blips_2.pitch_scale = randf_range(0.25, 0.3)
	wind_hiss.pitch_scale = randf_range(0.97, 1.21)
	road_noise.play(randf() * 120)
	wind_noise.play(randf() * 180)
	rumble.play(randf() * 60)
	wind_2.play(randf() * 240)
	blips.play(randf() * 15)
	blips_2.play(randf() * 15)
	wind_hiss.play(randf() * 20)

func _process(delta: float) -> void:
	var viewport = get_viewport()
	if Engine.is_editor_hint():
		viewport = EditorInterface.get_editor_viewport_3d()
	var listener = viewport.get_audio_listener_3d()
	if listener == null:
		listener = viewport.get_camera_3d()
	var listendist = listener.global_position.length()
	if listendist < 4:
		# just don't place two that close together
		var amount = clamp(remap(listener.global_position.length(), 3.0, 1.0, 0.0, 1.0), 0.0, 1.0)
		bass_boost_effect.gain = 1 + 3 * amount * amount
