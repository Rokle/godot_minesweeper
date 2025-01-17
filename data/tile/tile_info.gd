extends Resource

class_name TileInfo

signal flag_set()
signal flag_removed()
signal revealed()
signal revealed_mine()

enum STATE{
	SAFE,
	C_1,
	C_2,
	C_3,
	C_4,
	C_5,
	C_6,
	C_7,
	C_8,
	MINE
}

const MINE_COUNT_TO_TILE_STATE = {
	0:TileInfo.STATE.SAFE,
	1:TileInfo.STATE.C_1,
	2:TileInfo.STATE.C_2,
	3:TileInfo.STATE.C_3,
	4:TileInfo.STATE.C_4,
	5:TileInfo.STATE.C_5,
	6:TileInfo.STATE.C_6,
	7:TileInfo.STATE.C_7,
	8:TileInfo.STATE.C_8,
}

const NEIGHBOUR_DIRECTIONS = [
	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
	Vector2i(-1,  0),                  Vector2i(1,  0),
	Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1)
]

#region ------------------------ PUBLIC VARS -----------------------------------

var neighbours: Dictionary = {}
var opened: bool = false
var flagged: bool = false
var state: STATE = STATE.SAFE

#endregion

#region ======================== PUBLIC METHODS ================================

func add_neighbour(direction: Vector2i, tile_info: TileInfo) -> void:
	neighbours[direction] = tile_info

func change_state(new_state: STATE) -> void:
	state = new_state

func toggle_flag() -> bool:
	if opened:
		return false
	
	flagged = !flagged
	
	if flagged:
		flag_set.emit()
	else:
		flag_removed.emit()
	
	return flagged

func just_reveal_tile() -> void:
	opened = true
	
	revealed.emit()

func reveal() -> void:
	if opened or flagged:
		return
	
	if state == STATE.MINE:
		revealed_mine.emit()
		return
	
	just_reveal_tile()
	
	reveal_neighbors()

func reveal_neighbors() -> void:
	if state != STATE.SAFE:
		return
	
	for neighbour in neighbours.values():
		neighbour.reveal()

#endregion
