extends Area3D

@export var audio: AudioStream
@export_range(-80, 0, 0.5) var volume_db: float
@export var track_id: String
@export var play_below_count: int = 1
enum PlayingOverrideMode {NoPlay, Fadeout}
@export var playing_override_mode: PlayingOverrideMode = PlayingOverrideMode.Fadeout
@export var fade_seconds: float = 10

@onready var music_player_default = preload("res://sound/music_player.tscn")


func _on_body_entered(character: Node3D) -> void:
	#print("enter")
	var playcount = GlobalReferences.intstate_manager.get_key_value_or_0(track_id)
	var is_playing = GlobalReferences.intstate_manager.key_above_zero("musicplaying")
	if not (is_playing and playing_override_mode == PlayingOverrideMode.NoPlay):
		#print("try play")
		if playcount < play_below_count:
			#print("will play")
			GlobalReferences.intstate_manager.set_key("musicplaying", IntState.new_intstate(IntState.ReplaceMode.Add, 1))
			GlobalReferences.intstate_manager.set_key(track_id, IntState.new_intstate(IntState.ReplaceMode.Add, 1))
			var music_player = music_player_default.instantiate()
			GlobalReferences.player.add_child(music_player)
			music_player.stream = audio
			music_player.track_id = track_id
			if is_playing:
				music_player.start_after(fade_seconds * 0.8)
				for player in GlobalReferences.playing_tracks.values():
					player.fadeout(fade_seconds)
			else:
				music_player.start_after(0)
			GlobalReferences.playing_tracks[track_id] = music_player
