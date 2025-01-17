extends Control

#region ------------------------ PRIVATE VARS ----------------------------------

@export var message: Label
@export var start_game: Button
@export var difficulty_selector: Control

#endregion

#region ======================== PUBLIC METHODS ================================

func open_menu() -> void:
	start_game.visible = true
	difficulty_selector.visible = true

#endregion

#region ======================== INPUT METHODS =================================

func _on_start_game_button_up() -> void:
	message.visible = false
	start_game.visible = false
	difficulty_selector.visible = false
	SignalBus.start_game.emit(difficulty_selector.get_difficulty())
	

#endregion
