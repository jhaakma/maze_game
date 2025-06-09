extends Room

class_name RoomEnter

func _init() -> void:
    color = Color.GREEN

func on_enter(_player: Node) -> void:
    print("Player has entered the enter room at position: ", _player.position)
