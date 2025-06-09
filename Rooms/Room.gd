extends Resource
class_name Room

var color: Color = Color.GRAY

func on_enter(player: Node) -> void:
    # Override in subclasses or set via script for custom behavior
    print("Player has entered the room at position: ", player.position)