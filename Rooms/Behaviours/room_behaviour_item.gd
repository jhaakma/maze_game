extends RoomBehaviour

func on_enter(game: MazeGame) -> void:
    # Override this method to define what happens when the player enters the room
    print("Player has entered the item room at position: ", game.player.position)
