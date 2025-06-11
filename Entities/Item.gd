extends "res://Entities/Entity.gd"

class_name Item

@export var name: String = "Item"
@export var icon: Texture2D = null
@export var spawn_chance: float = 0.1

func on_enter(game: MazeGame, room: Room) -> void:
    print("Picked up item: %s" % name)
    room.entities.erase(self)
