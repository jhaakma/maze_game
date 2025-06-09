extends RoomBehaviour

func on_enter(player: Player) -> void:
    # Override this method to define what happens when the player enters the room
    print("Player has entered the item room at position: ", player.position)
