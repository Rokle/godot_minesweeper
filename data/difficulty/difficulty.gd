## Class used to set rows, columns, and mines for difficulty,
## designed to easily allow difficulty settings to be set in inspector.
extends Resource

class_name Difficulty

#region ------------------------ PUBLIC VARS -----------------------------------

@export var rows := 0
@export var columns := 0
@export var mines := 0

#endregion

#region ======================== PUBLIC METHODS ================================

func copy_values(difficulty: Difficulty) -> void:
	rows = difficulty.rows
	columns = difficulty.columns
	mines = difficulty.mines

#endregion
