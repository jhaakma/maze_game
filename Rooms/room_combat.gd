extends Room
class_name RoomCombat

func _init() -> void:
    color = Color.ORANGE  # Default color for empty rooms

func on_enter(player: Node) -> void:
    # Override in subclasses or set via script for custom behavior
    print("Player has entered a combat room at position: ", player.position)