extends Room
class_name RoomEmpty

func _init() -> void:
    color = Color.GRAY  # Default color for empty rooms

func on_enter(player: Node) -> void:
    # Override in subclasses or set via script for custom behavior
    print("Player has entered the room at position: ", player.position)