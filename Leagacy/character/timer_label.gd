extends Label

var timer_on : bool = true
var time_elapsed : float = 0.0

func reset() -> void:
	time_elapsed = 0.0

func _process(delta: float) -> void:
	if timer_on:
		time_elapsed += delta
		text = "Time: %s" % format_time(time_elapsed)

func format_time(seconds : float) -> String:
	var mins : int = int(seconds) / 60
	var secs : int = int(seconds) % 60
	var msec : int = int((seconds - int(seconds)) * 100)
	
	return "%02d:%02d:%02d" % [mins, secs, msec]
