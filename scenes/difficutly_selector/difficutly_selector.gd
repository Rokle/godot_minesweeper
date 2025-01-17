extends Control

#region ------------------------ PRIVATE VARS ----------------------------------

@onready var _default_difficulty: Difficulty = load(
	"res://data/difficulty/default_difficulty.tres"
)

@export var _easy_difficulty: Difficulty
@export var _normal_difficulty: Difficulty
@export var _hard_difficulty: Difficulty

@export var _row_counter: Label
@export var _row_slider: Slider
@export var _column_counter: Label
@export var _column_slider: Slider
@export var _mine_counter: Label
@export var _mine_slider: Slider

var _selected_difficulty: Difficulty

#endregion

#region ======================== SET UP METHODS ================================

func _ready() -> void:
	_init_selected_difficulty()
	_check_difficulty_presets()

func _init_selected_difficulty() -> void:
	_selected_difficulty = Difficulty.new()
	_set_difficulty(_default_difficulty)

func _check_difficulty_presets() -> void:
	if not _easy_difficulty:
		_easy_difficulty = _default_difficulty
	if not _normal_difficulty:
		_normal_difficulty = _default_difficulty
	if not _hard_difficulty:
		_hard_difficulty = _default_difficulty

#endregion

#region ======================== PUBLIC METHODS ================================

func get_difficulty() -> Difficulty:
	return _selected_difficulty

#endregion

#region ======================== PRIVATE METHODS ===============================

func _on_row_slider_value_changed(value: int) -> void:
	_selected_difficulty.rows = value
	_row_counter.text = "Rows: %s" % value

func _on_column_slider_value_changed(value: int) -> void:
	_selected_difficulty.columns = value
	_column_counter.text = "Columns: %s" % value

func _on_mine_slider_value_changed(value: int) -> void:
	_selected_difficulty.mines = value
	_mine_counter.text = "Mines: %s" % value

func _on_easy_button_down() -> void:
	_set_difficulty(_easy_difficulty)

func _on_normal_button_down() -> void:
	_set_difficulty(_normal_difficulty)

func _on_hard_button_down() -> void:
	_set_difficulty(_hard_difficulty)

func _set_difficulty(difficutly: Difficulty):
	_selected_difficulty.copy_values(difficutly)
	_update_slider_values()

func _update_slider_values() -> void:
	_row_slider.value = _selected_difficulty.rows
	_column_slider.value = _selected_difficulty.columns
	_mine_slider.value = _selected_difficulty.mines

#endregion
