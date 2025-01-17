extends Control

signal game_ended()

#region ------------------------ PRIVATE VARS ----------------------------------

@export var _mine_counter: Label
@export var _time_counter: Label
@export var _board: Board
@export var _resign_button: Button
@export var _timer: Timer

var _selected_difficulty: Difficulty

var _game_time: int = 0

#endregion

#region ======================== SET UP METHODS ================================

func _ready() -> void:
	SignalBus.start_game.connect(_on_game_start)
	_board.game_over.connect(_on_game_over)
	_board.flag_placed.connect(_update_mine_counter)
	_board.game_win.connect(_on_game_win)

#endregion

#region ======================== PRIVATE METHODS ===============================

func _on_game_start(difficulty: Difficulty) -> void:
	_mine_counter.visible = true
	_resign_button.visible = true
	_time_counter.visible = true
	_selected_difficulty = difficulty
	_game_time = 0
	_update_time()
	_timer.start(1)
	_update_mine_counter(0)

func _on_game_over(correct_mines: int) -> void:
	SignalBus.show_message.emit(
		"Game Over! You found %d mines out of %d. Play again?" % \
		[correct_mines, _selected_difficulty.mines]
	)
	
	_on_game_end()

func _on_game_win() -> void:
	SignalBus.show_message.emit(
		"You won! All %d mines were correctly identified. Play again?" % \
		 _selected_difficulty.mines
	)
	
	_on_game_end()

func _on_game_end() -> void:
	_resign_button.visible = false
	_timer.stop()
	game_ended.emit()

func _update_mine_counter(flaged_mines: int) -> void:
	var mine_count = max(_selected_difficulty.mines - flaged_mines, 0)
	_mine_counter.text = "Mines: %s" % (mine_count)

func _update_time() -> void:
	@warning_ignore("integer_division")
	_time_counter.text = "Time: %02d:%02d" % [_game_time/60, _game_time%60]

func _on_timer_timeout() -> void:
	_game_time += 1
	_update_time()

#endregion

#region ======================== INPUT METHODS =================================

func _on_resign_button_up() -> void:
	_board.resign()

#endregion
