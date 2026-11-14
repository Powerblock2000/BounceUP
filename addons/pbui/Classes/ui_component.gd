class_name FancyUIComponent
extends Resource

signal trigger(node: Control, context : Dictionary)

@export var signal_tiggers : Array[SignalTrigger]

var node : Control

func activate(context : Dictionary) -> void:
	trigger.emit(node, context)
