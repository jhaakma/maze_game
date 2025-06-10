extends RoomBehaviour

func on_enter(game: MazeGame) -> void:
    game.generate_maze()
