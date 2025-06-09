extends Resource
class_name Room

@export var color: Color = Color.GRAY
@export var icon: Texture2D = null
@export var description: String = "A generic room."
@export var behaviour: Script = null
@export var empty: bool = false
@export var spawn_chance: float = 1.0

func on_enter(player: Player) -> void:
    if behaviour:
        var instance = behaviour.new()
        if instance is RoomBehaviour:
            instance.on_enter(player)
        else:
            push_error("Room: Assigned behaviour script is not a RoomBehaviour.")