class_name FancyButton
extends Button

@export var ui_components : Array[FancyUIComponent]
var _unique_ui_compeonents : Array[FancyUIComponent]
var set_up_on_ready : bool

func _init(_set_up_on_ready : bool = true) -> void:
	set_up_on_ready = _set_up_on_ready

func _ready() -> void:
	if set_up_on_ready:
		_set_up_components()

func _set_up_components() -> void:
	for c in ui_components:
		_unique_ui_compeonents.append(c.duplicate(true))
	
	var signal_list : Array[Dictionary] = self.get_signal_list()
	for s in signal_list:
		for u in _unique_ui_compeonents:
			for st in u.signal_tiggers:
				if s.get("name") == st.signal_name:
					var bind_dict : Dictionary = st.signal_context
					bind_dict["signal"] = s.get("name")
					u.node = self
					connect(s.get("name"), u.activate.bind(bind_dict))
