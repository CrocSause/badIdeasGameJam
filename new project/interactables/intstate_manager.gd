extends Node


var keys: Dictionary[String, IntState]

func set_key(keyname: String, value: IntState):
	if keys.has(keyname):
		keys[keyname] = value.replace(keys[keyname].value)
	else:
		keys[keyname] = value.replace(0)

func has_key(keyname: String) -> bool:
	return keys.has(keyname)

func key_above_zero(keyname: String) -> bool:
	if keys.has(keyname):
		return keys[keyname].value > 0
	else:
		return false

func get_key_value_or_0(keyname: String) -> int:
	if keys.has(keyname):
		return keys[keyname].value
	else:
		return 0

func clear_key(keyname: String):
	keys[keyname] = IntState.new()

func delete_key(keyname: String):
	keys.erase(keyname)
