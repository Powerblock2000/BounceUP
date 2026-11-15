@tool
class_name ItemRegistry

extends Resource

@export var items: Dictionary[int, Item]: ## DO NOT EDIT, use the dock instead.
	set(value):
		items = value
		emit_changed()
