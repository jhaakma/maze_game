extends Resource
class_name Room

@export var color: Color = Color.GRAY
@export var icon: Texture2D = null
@export var icon_visited: Texture2D = null
@export var description: String = "A generic room."
@export var behaviour: Script = null
@export var empty: bool = false
@export var spawn_chance: float = 1.0

var visited: bool = false

func on_enter(game: MazeGame) -> void:
    visited = true
    if behaviour:
        var instance = behaviour.new()
        if instance is RoomBehaviour:
            instance.on_enter(game)
        else:
            push_error("Room: Assigned behaviour script is not a RoomBehaviour.")
