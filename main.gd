extends Node2D
class_name MazeGame

@export var generator: MazeGenerator
@export var visualiser: Node2D
@export var base_illuminated_radius: int = 1
@export var matchstick_radius: int = 5
@export var matchstick_fade_up_time: float = 0.05
@export var matchstick_fade_down_time: float = 0.5 # seconds
@export var matchstick_hold_time: float = 3.0 # seconds at max brightness

var maze: Dictionary[Vector2i, MazeGenerator.RoomData] = {}
var player_pos: Vector2i = Vector2i.ZERO
var illuminated_radius: float = 1.0
var _matchstick_active := false

func _ready() -> void:
    illuminated_radius = float(base_illuminated_radius)
    if generator == null:
        push_error("MazeGame: No MazeGenerator assigned.")
    else:
        generate_maze()

func _unhandled_input(event) -> void:
    if event.is_action_pressed("ui_accept"):
        use_matchstick()

func generate_maze() -> void:
    if generator == null:
        push_error("MazeGame: No MazeGenerator assigned.")
        return
    maze = generator.generate_maze()
    player_pos = Vector2i.ZERO
    if visualiser:
        visualiser.queue_redraw()

func get_maze_distances(from: Vector2i) -> Dictionary[Vector2i, int]:
    var distances: Dictionary[Vector2i, int] = {}
    var queue: Array[Vector2i] = [from]
    distances[from] = 0
    while queue.size() > 0:
        var current = queue.pop_front()
        var current_dist = distances[current]
        for dir in MazeGenerator.DIRECTIONS:
            var neighbor = current + dir
            if maze.has(neighbor) and not distances.has(neighbor):
                distances[neighbor] = current_dist + 1
                queue.append(neighbor)
    return distances

func use_matchstick() -> void:
    if _matchstick_active:
        return
    _matchstick_active = true
    await _burst_and_fade_matchstick()

func _burst_and_fade_matchstick() -> void:
    await _tween_radius(float(illuminated_radius), float(matchstick_radius), matchstick_fade_up_time)
    if matchstick_hold_time > 0.0:
        await get_tree().create_timer(matchstick_hold_time).timeout
    await _tween_radius(float(matchstick_radius), float(base_illuminated_radius), matchstick_fade_down_time)
    illuminated_radius = float(base_illuminated_radius)
    _matchstick_active = false
    if visualiser:
        visualiser.queue_redraw()

func _tween_radius(from: float, to: float, duration: float) -> void:
    var t := 0.0
    while t < duration:
        await get_tree().process_frame
        t += get_process_delta_time()
        var ratio: float = clamp(t / duration, 0, 1)
        illuminated_radius = lerp(from, to, ratio)
        if visualiser:
            visualiser.queue_redraw()

func is_matchstick_active() -> bool:
    return _matchstick_active
