extends Node

class_name InputHandler

@export var player: Player
@export var game: MazeGame
@export var matchstick_manager: Node

func _unhandled_input(event) -> void:
    var moved := false
    if event.is_action_pressed("move_left"):
        player.try_move(Vector2i.LEFT, game)
        moved = true
    elif event.is_action_pressed("move_right"):
        player.try_move(Vector2i.RIGHT, game)
        moved = true
    elif event.is_action_pressed("move_up"):
        player.try_move(Vector2i.UP, game)
        moved = true
    elif event.is_action_pressed("move_down"):
        player.try_move(Vector2i.DOWN, game)
        moved = true
    elif event.is_action_pressed("ui_accept"):
        matchstick_manager.use_matchstick()
    # Visual updates happen via signals

