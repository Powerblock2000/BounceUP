class_name FancyTextureButton
extends TextureButton

@export var ui_components : Array[FancyUIComponent]

func _ready() -> void:
	_set_up_components()

func _set_up_components() -> void:
	var signal_list : Array[Dictionary] = self.get_signal_list()
	for s in signal_list:
		for u in ui_components:
			for st in u.signal_tiggers:
				if s.get("name") == st.signal_name:
					var bind_dict : Dictionary = st.signal_context
					bind_dict["signal"] = s.get("name")
					u.node = self
					connect(s.get("name"), u.activate.bind(bind_dict))
