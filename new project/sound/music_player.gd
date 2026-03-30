extends AudioStreamPlayer

var track_id: String
var is_fading_out: bool = false

func start_after(time: float):
	if time == 0:
		self.play(0)
	else:
		var playtween = get_tree().create_tween()
		playtween.tween_interval(time)
		playtween.tween_callback(_on_timer_timeout)

func _on_timer_timeout() -> void:
	self.play(0)

func fadeout(time: float):
	if not is_fading_out:
		is_fading_out = true
		var fadetween = get_tree().create_tween()
		fadetween.tween_property($".", "volume_db", -80, time)
		await fadetween.finished
		self.stop()
		self.queue_free()
		GlobalReferences.intstate_manager.set_key("musicplaying", IntState.new_intstate(IntState.ReplaceMode.SubtractOrZero, 1))
		GlobalReferences.playing_tracks.erase(track_id)
