class_name MovementModifier
extends Resource

signal trigged(component : BaseComponent)

func trigger(component : BaseComponent) -> void:
	trigged.emit(component)
