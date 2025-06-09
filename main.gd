extends Node2D
class_name MazeGame

@export var generator: MazeGenerator
@export var visualiser: Node2D
@export var matchstick_radius: int = 8
@export var matchstick_fade_up_time: float = 0.1
@export var matchstick_fade_down_time: float = 1.5 # seconds
@export var matchstick_hold_time: float = 2.0 # seconds at max brightness
@export var player: Player

var maze_data: MazeData
var matchstick: Matchstick

func _ready() -> void:
    maze_data = MazeData.new()
    matchstick = Matchstick.new()
    add_child(matchstick)
    matchstick.configure(
        player.vision_radius,
        matchstick_radius,
        matchstick_fade_up_time,
        matchstick_fade_down_time,
        matchstick_hold_time
    )
    matchstick.illumination_changed.connect(_on_illumination_changed)
    player.memory_updated.connect(_on_illumination_changed)
    if generator == null:
        push_error("MazeGame: No MazeGenerator assigned.")
    else:
        generate_maze()

func _on_illumination_changed() -> void:
    if visualiser:
        visualiser.queue_redraw()

func _unhandled_input(event) -> void:
    var moved := false
    if event.is_action_pressed("move_left"):
        player.try_move(Vector2i.LEFT, maze_data)
        moved = true
    elif event.is_action_pressed("move_right"):
        player.try_move(Vector2i.RIGHT, maze_data)
        moved = true
    elif event.is_action_pressed("move_up"):
        player.try_move(Vector2i.UP, maze_data)
        moved = true
    elif event.is_action_pressed("move_down"):
        player.try_move(Vector2i.DOWN, maze_data)
        moved = true
    elif event.is_action_pressed("ui_accept"):
        use_matchstick()
    if moved and visualiser:
        visualiser.queue_redraw()

func generate_maze() -> void:
    var start_pos: Vector2i = Vector2i.ZERO
    if generator == null or maze_data == null:
        push_error("MazeGame: No MazeGenerator or MazeData assigned.")
        return
    generator.generate_maze(start_pos)
    if player:
        player.position = start_pos
    if visualiser:
        visualiser.queue_redraw()

func get_maze_distances(from: Vector2i) -> Dictionary[Vector2i, int]:
    if maze_data == null:
        return {}
    return maze_data.get_distances(from)

func use_matchstick() -> void:
    matchstick.use(player.position)

func get_illumination_origin() -> Vector2i:
    return matchstick.get_origin(player.position)

func get_illuminated_radius() -> float:
    return matchstick.get_radius()

func is_matchstick_active() -> bool:
    return matchstick.is_active()
