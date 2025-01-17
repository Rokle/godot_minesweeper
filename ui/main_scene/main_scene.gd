extends Control

#region ------------------------ PRIVATE VARS ----------------------------------

@export var _board_ui: Control
@export var _menu_ui: Control

#endregion

#region ======================== SET UP METHODS ================================

func _ready() -> void:
	_board_ui.game_ended.connect(_menu_ui.open_menu)

#endregion
