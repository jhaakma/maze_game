extends "res://Entities/Entity.gd"

class_name Enemy

@export var name: String = "Enemy"
@export var icon: Texture2D = null
@export var spawn_chance: float = 0.1

func on_enter(game: MazeGame, room: Room) -> void:
    print("Encountered enemy: %s" % name)
