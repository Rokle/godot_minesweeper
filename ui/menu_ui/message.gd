extends Label

#region ======================== SET UP METHODS ================================

func _ready() -> void:
	SignalBus.show_message.connect(_show_message)

#endregion

#region ======================== PRIVATE METHODS ===============================

func _show_message(message: String) -> void:
	visible = true
	text = message

#endregion
