extends CanvasLayer

@onready var tooltip_text: RichTextLabel = $Control/Tooltip/MarginContainer/TooltipText
@onready var tooltip_c: PanelContainer = $Control/Tooltip
@onready var control: Control = $Control

class OverrideFontType extends Resource:
	var font : Font
	var name : StringName

func change_theme(theme : Theme) -> void:
	control.theme = theme

func show_tooltip(tooltip : String, fonts : Array[OverrideFontType] = []) -> void:
	tooltip_text.text = tooltip
	
	for f in fonts:
		tooltip_text.add_theme_font_override(f.name, f.font)
	
	tooltip_c.show()

func hide_tooltip() -> void:
	tooltip_c.hide()
