extends Node2D

var cell_size = 50
var grid_size = 15

var board_state: Array = []
var board_components: Array = []
var board_labels: Array = []

var dead_color = Color(.5, .5, .5, .5)
var alive_color = Color(.9, .9, .9, .9)

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in grid_size:
		var row = []
		for j in grid_size:
			row.append(0)
		board_state.append(row)
	
	board_state[10][10] = 1
	board_state[11][10] = 1
	board_state[12][10] = 1
	board_state[12][9] = 1
	board_state[11][8] = 1
	
	for i in grid_size:
		var row = []
		for j in grid_size:
			var t = ColorRect.new()
			t.size = Vector2(cell_size - 1, cell_size - 1)
			t.color = Color(alive_color if board_state[i][j] == 1 else dead_color)
			t.position = Vector2(i * cell_size, j * cell_size)
			add_child(t)
			row.append(t)
			
			var l = Label.new()
			l.position = Vector2(i * cell_size, j * cell_size)
			l.text = str(i) + ", " + str(j)
			add_child(l)
		board_components.append(row)

func _sum(a: int, b: int) -> int:
	return a + b

func _on_timer_timeout() -> void:
	_resolve_step()

func _set_cell(x: int, y: int, value: int) -> void:
	board_state[x][y] = value
	board_components[x][y].color = Color(alive_color if value == 1 else dead_color)

func _resolve_step() -> void:
	var current_state = board_state.duplicate(true)
	
	for i in current_state.size():
		for j in current_state[0].size():
			_set_cell(i, j, _resolve_cell(i, j, current_state))
			
	
func _resolve_cell(x: int, y: int, array: Array) -> int:
	var cell_value: int = _get_neighboring_cells(x, y, array)
	var new_state: int = 0
	
	if array[x][y] == 1:
		if cell_value < 2:
			new_state = 0
		elif cell_value <= 3:
			new_state = 1
		elif cell_value > 3:
			new_state = 0
	else:
		if cell_value == 3:
			new_state = 1
	
	return new_state

func _get_neighboring_cells(x: int, y: int, array: Array) -> int:
	var sum: int = 0
	
	for i in range(-1, 2):
		for j in range(-1, 2):
			if i == 0 and j == 0:
				continue
				
			if _is_valid(x + i, y + j, array):
				sum += array[x + i][y + j]
				
	return sum

func _is_valid(x: int, y: int, array: Array) -> bool:
	return x in range(0, array.size()) and y in range(0, array[0].size())

func _input(_event):
	if Input.is_action_just_pressed("pause"):
		_toggle_timer()
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_freehand(_event.global_position.x, _event.global_position.y)

func _toggle_timer():
	var timer: Timer = $Timer
	if timer.is_stopped():
		timer.start()
	else:
		timer.stop()

func _freehand(global_x, global_y):
	var translated_x = int(global_x / cell_size)
	var translated_y = int(global_y / cell_size)
	
	if _is_valid(translated_x, translated_y, board_state):
		_set_cell(translated_x, translated_y, 1)
