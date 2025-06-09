extends Room

class_name RoomExit

func _init() -> void:
    color = Color.RED

func on_enter(_player: Node) -> void:
    print("Player has exited the maze!")
