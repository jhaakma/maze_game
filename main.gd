extends Node2D
class_name MazeGame

@onready var camera: Camera2D = $Camera2D

@export var generator: MazeGenerator
@export var visualiser: Node2D
@export var player: Player
@export var input_handler: InputHandler
@export var matchstick_manager: MatchstickManager

var maze_data: MazeData

func _ready() -> void:
    maze_data = MazeData.new()
    # No longer create a single matchstick here
    player.memory_updated.connect(_on_illumination_changed)
    player.position_changed.connect(_on_player_position_changed)
    matchstick_manager.illumination_changed.connect(_on_illumination_changed)
    input_handler.player = player
    input_handler.game = self
    input_handler.matchstick_manager = matchstick_manager
    generator.maze_generated.connect(_on_maze_generated)
    if generator == null:
        push_error("MazeGame: No MazeGenerator assigned.")
    else:
        generate_maze()

func _on_illumination_changed() -> void:
    if visualiser:
        visualiser.queue_redraw()

func _on_maze_generated() -> void:
    if visualiser:
        visualiser.queue_redraw()

#update camera position
func _on_player_position_changed(new_position: Vector2i) -> void:
    camera.update_camera_position(new_position)
    if visualiser:
        visualiser.queue_redraw()


func generate_maze() -> void:
    matchstick_manager.clear_matchsticks()
    if player:
        player.clear_memory()

    var start_pos: Vector2i = Vector2i.ZERO
    if generator == null or maze_data == null:
        push_error("MazeGame: No MazeGenerator or MazeData assigned.")
        return
    generator.generate_maze(maze_data, start_pos)
    if player:
        player.position = start_pos
        player.learn_rooms(maze_data)
    if visualiser:
        visualiser.queue_redraw()

func get_maze_distances(from: Vector2i) -> Dictionary[Vector2i, int]:
    if maze_data == null:
        return {}
    return maze_data.get_distances(from)

func use_matchstick() -> void:
    matchstick_manager.use_matchstick()

func is_matchstick_active() -> bool:
    return matchstick_manager.is_matchstick_active()

func get_illumination_origin() -> Vector2i:
    return matchstick_manager.get_illumination_origin(player.position)

func get_illuminated_radius() -> float:
    return matchstick_manager.get_illuminated_radius()
