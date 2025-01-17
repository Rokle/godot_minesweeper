extends GridContainer

class_name Board

signal game_over(total_correct)
signal game_win()
signal flag_placed(flagged_count)

#region ------------------------ PRIVATE VARS ----------------------------------

@export var _tile_textures: TileTextures

@onready var _tile: PackedScene = preload("res://scenes/tile/tile.tscn")

var _game_started := false
var _board := {}
var _mines_list: Array[Vector2i] = []
var _flagged_count := 0
var _unrevealed_tiles := 0

#endregion

#region ======================== SET UP METHODS ================================

func _ready() -> void:
	SignalBus.start_game.connect(start_game)
	SignalBus.end_game.connect(_force_game_end)

#endregion

#region ======================== PUBLIC METHODS ================================

func start_game(difficulty: Difficulty) -> void:
	reset()
	
	_game_started = true
	self.columns = difficulty.columns
	_unrevealed_tiles = difficulty.columns*difficulty.rows
	
	_generate_board(difficulty)
	_generate_mines(difficulty)
	_add_tiles_to_scene(difficulty)

func reset() -> void:
	_game_started = false
	_board = {}
	_mines_list = []
	_flagged_count = 0
	_unrevealed_tiles = 0
	
	for tile in get_children():
		tile.queue_free()

func resign() -> void:
	_game_over()

#endregion

#region ======================== PRIVATE METHODS ===============================

func _force_game_end() -> void:
	resign()

func _game_over() -> void:
	_game_started = false
	var mines_count = _count_found_mines()
	_reveal_all_mines()
	game_over.emit(mines_count)

func _count_found_mines() -> int:
	var mines_count = 0
	
	for mine in _mines_list:
		if not _board[mine].flagged:
			continue
		
		mines_count += 1
	
	return mines_count

func _reveal_all_mines() -> void:
	for mine in _mines_list:
		_board[mine].just_reveal_tile()

func _generate_board(difficulty: Difficulty) -> void:
	var cols = difficulty.columns
	var rows = difficulty.rows
	
	for x in range(cols):
		for y in range(rows):
			var tile_vector = Vector2i(x, y)
			
			var tile_info = TileInfo.new()
			
			_board[tile_vector] = tile_info
			
			tile_info.revealed.connect(_decrease_tile_count)
			
			for direction in TileInfo.NEIGHBOUR_DIRECTIONS:
				var neighbour_tile = tile_vector + direction
				
				if not _board.has(neighbour_tile):
					continue
				
				_board[tile_vector].add_neighbour(
					direction, _board[neighbour_tile]
					)
				
				_board[neighbour_tile].add_neighbour(
					-1*direction, _board[tile_vector]
					)

func _generate_mines(difficulty: Difficulty) -> void:
	var cols = difficulty.columns
	var rows = difficulty.rows
	var total_mines = difficulty.mines
	
	var near_mines_tiles = {}
	
	var current_mines = 0
	
	while current_mines < total_mines:
		var tile_x = randi_range(0,cols-1)
		var tile_y = randi_range(0,rows-1)
		
		var tile_vector = Vector2i(tile_x,tile_y)
		
		if _board[tile_vector].state == TileInfo.STATE.MINE:
			continue
		
		current_mines += 1
		
		_board[tile_vector].change_state(TileInfo.STATE.MINE)
		
		_board[tile_vector].revealed_mine.connect(_game_over)
		
		_mines_list.append(tile_vector)
		
		if near_mines_tiles.has(tile_vector):
			near_mines_tiles.erase(tile_vector)
		
		for direction in TileInfo.NEIGHBOUR_DIRECTIONS:
			var tile_near_mine = tile_vector + direction
			
			if not _board.has(tile_near_mine):
				continue
			
			if _board[tile_near_mine].state == TileInfo.STATE.MINE:
				continue
			
			if not near_mines_tiles.has(tile_near_mine):
				near_mines_tiles[tile_near_mine] = 0
			
			near_mines_tiles[tile_near_mine] += 1
	
	for tile in near_mines_tiles.keys():
		_board[tile].change_state(
			TileInfo.MINE_COUNT_TO_TILE_STATE[near_mines_tiles[tile]]
		)

func _add_tiles_to_scene(difficulty: Difficulty) -> void:
	var cols = difficulty.columns
	var rows = difficulty.rows
	
	for y in range(rows):
		for x in range(cols):
			var tile_vector = Vector2i(x, y)
			_add_tile_to_scene(tile_vector)

func _add_tile_to_scene(tile_vector: Vector2i) -> void:
	var tile_info = _board[tile_vector]
	var tile = _tile.instantiate() as Tile
	
	_connect_tile_and_board(tile, tile_vector)
	
	_connect_tile_info_and_tile(tile_info, tile)
	
	tile.set_texture(_tile_textures.hidden)
	
	add_child(tile)

func _connect_tile_and_board(tile: Tile, tile_vector: Vector2i) -> void:
	tile.reveal.connect(_reveal_tile.bind(tile_vector))
	tile.toggle_flag.connect(_toggle_flag_on_tile.bind(tile_vector))

func _connect_tile_info_and_tile(tile_info: TileInfo, tile: Tile) -> void:
	var textures_to_bind = {
		tile_info.STATE.SAFE: _tile_textures.safe,
		tile_info.STATE.C_1: _tile_textures.c_1,
		tile_info.STATE.C_2: _tile_textures.c_2,
		tile_info.STATE.C_3: _tile_textures.c_3,
		tile_info.STATE.C_4: _tile_textures.c_4,
		tile_info.STATE.C_5: _tile_textures.c_5,
		tile_info.STATE.C_6: _tile_textures.c_6,
		tile_info.STATE.C_7: _tile_textures.c_7,
		tile_info.STATE.C_8: _tile_textures.c_8,
		tile_info.STATE.MINE: _tile_textures.mine
	}
	
	var texture_to_bind = textures_to_bind[tile_info.state]
	
	tile_info.revealed.connect(
		tile.set_texture.bind(texture_to_bind)
	)
	
	tile_info.flag_set.connect(
		tile.set_texture.bind(_tile_textures.flagged)
	)
	
	tile_info.flag_removed.connect(
		tile.set_texture.bind(_tile_textures.hidden)
	)
	
	tile_info.revealed_mine.connect(
		tile.set_texture.bind(_tile_textures.mine_selected)
	)

func _toggle_flag_on_tile(tile_vector: Vector2i) -> void:
	if not _game_started:
		return
	
	var tile_info = _board[tile_vector]
	
	if not tile_info.flagged and _flagged_count == len(_mines_list):
		return
	
	if tile_info.opened:
		return
	
	var tile_flagged = tile_info.toggle_flag()
	
	_flagged_count += 1 if tile_flagged else -1
	
	flag_placed.emit(_flagged_count)

func _decrease_tile_count() -> void:
	if not _game_started:
		return
	
	_unrevealed_tiles -= 1
	
	if _unrevealed_tiles == len(_mines_list):
		game_win.emit()

func _reveal_tile(tile_vector: Vector2i) -> void:
	if not _game_started:
		return
	
	var tile_info = _board[tile_vector]
	tile_info.reveal()

#endregion
