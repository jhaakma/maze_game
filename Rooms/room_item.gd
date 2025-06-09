extends Room
class_name RoomItem

func _init() -> void:
    color = Color.GRAY

func on_enter(player: Node) -> void:
    # Override in subclasses or set via script for custom behavior
    print("Player has entered an item room at position: ", player.position)