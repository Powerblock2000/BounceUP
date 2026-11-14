@tool
class_name DialogLabel
#TODO Migrate to Obsidian!
## This allows you to write dialog and control the flow using custom and built in tags.
##
## To get started, add a [DialogLabel] to your scene. Then write your dialog. Now you can add
## tags to customize the functionality. We provide some built in tags but you can easily
## add your own by modifing [member custom_tags] (More info below). Our built in tags consist of:
## [code]{wait}[/code],[code] {set_talking}[/code],[code] {np}, [/code]and[code] {pause}[/code].
## Whenever ANY tag is parsed a signal is emited called [code]{tag_name}_signal[/code].
## These signals DO NOT contain any arguments regardless of what you set in your dialog.
## 
## [br][br][b]• Wait[/b]:[br]
## To use the [code]{wait}[/code] tag, just type out [code]{wait=5}[/code] (Replace 5 with the amount of time to wait).

extends RichTextLabel

signal tag_triggered(tag_data : Dictionary)
signal character_appeared ## Use this to add SFX or VFX to the text appearing
signal finished_playing

signal wait_signal
signal set_talking_signal
signal np_signal
signal pause_signal

## This is the text that is displayed when played. You can use BOTH BBCode AND our own custom tags! More info can be found in [DialogLabel] documentation.
@export_multiline() var dialog_text : String
@export var custom_tags : Array[String] = []
@export_range(.001, 200, 1.0, "or_greater") var speed : float = 10.0

const _LOOK_FOR : Array[String] = ["wait", "set_talking", "np", "pause"]

var _playing : bool = false
var _playing_text : bool = false
var _talking : String = ""
var _next_np : bool = false
var _current_page : int = 0
var _finished : bool = false

func skip() -> void:
	var _original_speed : int = speed
	speed = 200
	await np_signal
	speed = _original_speed

func is_playing() -> bool:
	return _playing

func pause() -> void:
	_playing = false

func np() -> void:
	_current_page += 1
	
	_playing = false
	_next_np = true

func wait(time_s : String) -> void:
	if not time_s.is_valid_float():
		PBFuncs.debug_print("Wait is NOT a valid float", true, 1, "PBUI - DialogLabel")
		return
	
	var time : float = time_s.to_float()
	
	_playing = false
	await get_tree().create_timer(time, true, false, true).timeout
	_playing = true

func get_talker() -> String:
	return _talking

func set_talking(t_name : String) -> void:
	_talking = t_name

func _ready() -> void:
	var defualt_text : String = "-DialogLabel-"
	
	if Engine.is_editor_hint() and text != defualt_text:
		text = defualt_text
	else:
		text = ""
		visible_ratio = 0
		init_parser()
		parse_dialog()
		play()

var regex : RegEx = RegEx.new()
func init_parser() -> void:
	regex.compile(r"\{(?P<command>\w+)(?:=(?P<value>[^}]+))?\}")

var tags_index : Dictionary = {}
func parse_dialog() -> void:
	var search_for : Array[String] = custom_tags + _LOOK_FOR
	
	var matches : Array[RegExMatch] = regex.search_all(dialog_text)
	
	for m in matches:
		var start_idx : int = m.get_start(0)
		var end_idx : int = m.get_end(0)
		
		var full_match : String = m.get_string(0)
		var command : String = m.get_string("command")
		var value : String = m.get_string("value")
		
		if search_for.has(command):
			tags_index.set(start_idx, {"start_index": start_idx, "end_index": end_idx, "full_match": full_match, "command": command, "value": value})
	
	set_page(_current_page)

func set_page(page_idx : int) -> void:
	var page_boundaries : Array[int] = [0]
	for d in tags_index.values():
		if d is Dictionary:
			if d["command"] == "np":
				page_boundaries.append(d["end_index"])
	
	page_boundaries.append(dialog_text.length())
	
	page_boundaries.sort()
	
	if page_idx >= 0 and page_idx < page_boundaries.size() - 1:
		var page_start : int = page_boundaries[page_idx]
		var page_end : int = page_boundaries[page_idx + 1]
		var page_range : int = page_end - page_start
		
		var page_text_raw : String = dialog_text.substr(page_start, page_range)
		
		var page_text_clean : String = regex.sub(page_text_raw, "", true)
		
		text = page_text_clean
	else:
		PBFuncs.debug_print("Page out of bounds: %s" % parse_idx, true, 1, "PBUI - DialogLabel")

func _process(_delta: float) -> void:
	if _playing and not _playing_text:
		_play_text()

var parse_idx : int = 0
func _play_text() -> void:
	_playing_text = true
	while _playing and text != "":
		await get_tree().create_timer(1 / speed, true, false, true).timeout
		visible_characters += 1
		for t in tags_index:
			var tag_data : Dictionary = tags_index[t]
			if parse_idx == t:
				
				print("Tag found: %s" % tags_index[t]["command"])
				
				if self.has_signal("%s_signal" % tag_data["command"]):
					print("Emiting signal %s_signal" % tag_data["command"])
					emit_signal("%s_signal" % tag_data["command"])
				
				tag_triggered.emit(tag_data)
				
				if self.has_method(tag_data["command"]):
					if tag_data["value"] == "":
						self.call(tag_data["command"])
					else:
						self.call(tag_data["command"], tag_data["value"])
		
		if parse_idx == dialog_text.length() - 1:
			finished_playing.emit()
			_playing = false
			_finished = true
			break
		
		parse_idx += 1
		
		_playing_text = _playing

func restart() -> void:
	if !_finished:
		return
	
	_finished = false
	
	if _next_np:
		visible_ratio = 0
		_next_np = false
	_playing = true

func play() -> void:
	if _finished:
		return
	
	if _next_np:
		visible_ratio = 0
		set_page(_current_page)
		_next_np = false
	_playing = true

func _validate_property(property: Dictionary) -> void:
	if property.name == "text":
		property.usage &= ~PROPERTY_USAGE_EDITOR
