extends Node

@export var circle_scene : PackedScene
@export var cross_scene : PackedScene

signal next_player
signal end_state

var temp_marker
var player_panel_pos : Vector2i
var active_player : marker
var winner : int
var board_size : int = 0
var cell_size : int = 0
var grid_pos : Vector2i
var grid : Array
enum marker {CIRCLE = 1, CROSS = -1}
var row_sum : int
var col_sum : int
var diagonal_sum1 : int
var diagonal_sum2 : int
var num_moves : int
var max_moves : int = 9

# Called when the node enters the scene tree for the first time.
func _ready():
	board_size = $Board.texture.get_width()
	cell_size = board_size / 3
	player_panel_pos = $SidePanel/NextPlayerPanel.get_screen_position()
	
	new_game()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# check if mouse is on game board
		if event.position.x < board_size:	
			# convert mouse position to grid position
			grid_pos = Vector2i(event.position/cell_size)		
			if grid[grid_pos.y][grid_pos.x] == 0:
				grid[grid_pos.y][grid_pos.x] = active_player
				create_marker(active_player, grid_pos * cell_size + Vector2i(cell_size/2, cell_size/2))
				num_moves += 1

				if check_for_win() != 0:
					emit_signal("end_state", winner)
					game_over()
				elif num_moves >= max_moves:
					emit_signal("end_state", winner)
					game_over()
				active_player *= -1
				
				# clear the next player panel
				temp_marker.queue_free()
				create_marker(active_player, player_panel_pos + Vector2i(cell_size/2, cell_size/2), true)
				print(grid)

func new_game():
	active_player = marker.values()[ randi() % marker.size() ]
	
	# reset board state
	grid = [
			[0, 0, 0],
			[0, 0, 0],
			[0, 0, 0]			
			]
	row_sum = 0
	col_sum = 0
	diagonal_sum1 = 0
	diagonal_sum2 = 0
	
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	
	create_marker(active_player, player_panel_pos + Vector2i(cell_size/2, cell_size/2), true)
	emit_signal("next_player", active_player)
	winner = 0
	num_moves = 0
	$GameOverScreen.hide()
	get_tree().paused = false

func create_marker(player, position, temp=false):
	if player == marker.CIRCLE:
		var circle = circle_scene.instantiate()
		circle.position = position
		add_child(circle)
		if temp: 
			temp_marker = circle
	else:
		var cross = cross_scene.instantiate()
		cross.position = position
		add_child(cross)
		if temp: 
			temp_marker = cross

func check_for_win():
	# sum up each possible scoring row, column, diagonal
	diagonal_sum1 = grid[0][0] + grid[1][1] + grid[2][2]
	diagonal_sum2 = grid[0][2] + grid[1][1] + grid[2][0]
	
	for i in len(grid):
		row_sum = grid[i][0] + grid[i][1] + grid[i][2]
		col_sum = grid[0][i] + grid[1][i] + grid[2][i]
		
		# check for winner
		if row_sum == 3 or col_sum == 3 or diagonal_sum1 == 3 or diagonal_sum2 == 3:
			winner = marker.CIRCLE
			break
		elif row_sum == -3 or col_sum == -3 or diagonal_sum1 == -3 or diagonal_sum2 == -3: 
			winner = marker.CROSS
			break
			
	return winner
	
func game_over():
	$GameOverScreen.show()
	get_tree().paused = true

func _on_game_over_screen_restart():
	new_game()
