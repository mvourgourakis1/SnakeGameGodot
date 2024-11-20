# Snake Game Main Script (game.gd)
extends Node2D

const GRID_SIZE = 20
const GRID_WIDTH = 20
const GRID_HEIGHT = 20

var snake = []
var direction = Vector2.RIGHT
var food_pos = Vector2.ZERO
var score = 0
var game_over = false

@onready var snake_head = $SnakeHead
@onready var food = $Food
@onready var score_label = $ScoreLabel

func _ready():
	randomize()
	reset_game()

func _process(delta):
	if game_over:
		return
	
	# Handle input for direction changes
	if Input.is_action_just_pressed("ui_right") and direction != Vector2.LEFT:
		direction = Vector2.RIGHT
	elif Input.is_action_just_pressed("ui_left") and direction != Vector2.RIGHT:
		direction = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_up") and direction != Vector2.DOWN:
		direction = Vector2.UP
	elif Input.is_action_just_pressed("ui_down") and direction != Vector2.UP:
		direction = Vector2.DOWN
	
	# Move snake every frame
	move_snake()
	check_collision()

func move_snake():
	# Add new head position
	var new_head = snake[0] + direction
	snake.push_front(new_head)
	
	# Remove tail if not eating food
	if new_head == food_pos:
		score += 1
		score_label.text = "Score: " + str(score)
		spawn_food()
	else:
		snake.pop_back()
	
	# Update snake segments
	update_snake_graphics()

func spawn_food():
	while true:
		food_pos = Vector2(
			randi() % GRID_WIDTH,
			randi() % GRID_HEIGHT
		)
		if not food_pos in snake:
			food.position = food_pos * GRID_SIZE
			break

func check_collision():
	var head = snake[0]
	
	# Wall collision
	if (head.x < 0 or head.x >= GRID_WIDTH or 
		head.y < 0 or head.y >= GRID_HEIGHT):
		game_over = true
		$GameOverLabel.visible = true
	
	# Self collision
	for i in range(1, snake.size()):
		if head == snake[i]:
			game_over = true
			$GameOverLabel.visible = true
			break

func update_snake_graphics():
	# Clear existing snake graphics
	for child in $Snake.get_children():
		child.queue_free()
	
	# Draw snake segments
	for segment in snake:
		var rect = ColorRect.new()
		rect.rect_size = Vector2(GRID_SIZE, GRID_SIZE)
		rect.rect_position = segment * GRID_SIZE
		rect.color = Color.GREEN if segment == snake[0] else Color.DARK_GREEN
		$Snake.add_child(rect)

func reset_game():
	# Reset game state
	snake = [Vector2(5, 5), Vector2(4, 5), Vector2(3, 5)]
	direction = Vector2.RIGHT
	score = 0
	game_over = false
	score_label.text = "Score: 0"
	$GameOverLabel.visible = false
	
	# Initial food spawn
	spawn_food()
	update_snake_graphics()

func _input(event):
	if game_over and event.is_action_pressed("ui_accept"):
		reset_game()
