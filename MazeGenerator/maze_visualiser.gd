extends Node2D

@export var cell_size: int = 48
@export var generator: MazeGenerator
@export var fully_lit_alpha: float = 1.0
@export var dim_alpha: float = 0.1
@export var base_illuminated_radius: int = 1
@export var matchstick_radius: int = 5
@export var matchstick_fade_up_time: float = 0.05
@export var matchstick_fade_down_time: float = 0.5 # seconds
@export var matchstick_hold_time: float = 3.0 # seconds to wait at max brightness before fading down


var maze: Dictionary[Vector2i, MazeGenerator.RoomData] = {}
var player_pos: Vector2i = Vector2i.ZERO
var illuminated_radius: float = 1.0 # Use float for tweening
var _matchstick_active := false

func _ready() -> void:
    illuminated_radius = float(base_illuminated_radius)
    if generator == null:
        push_error("MazeVisualizer: No MazeGenerator assigned.")
    else:
        _generate_and_draw_maze()

func _generate_and_draw_maze() -> void:
    if generator == null:
        push_error("MazeVisualizer: No MazeGenerator assigned.")
        return
    maze = generator.generate_maze()
    print("Maze generated with ", maze.size(), " rooms (room_count=", generator.room_count, ", branch_chance=", generator.branch_chance, ", max_walkers=", generator.max_walkers, ")")
    queue_redraw()

func _unhandled_input(event):
    if event.is_action_pressed("ui_accept"): # Or any action you like
        use_matchstick()

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

func _draw() -> void:
    if maze.is_empty():
        push_warning("MazeVisualizer: Maze is empty, call _generate_and_draw_maze() first.")
        return
    print("Drawing maze with ", maze.size(), " rooms")
    var distances = get_maze_distances(player_pos)
    for pos in maze.keys():
        var room = maze[pos]
        var dist = distances.get(pos, null)
        var alpha := dim_alpha
        if dist == null or dist > int(illuminated_radius):
            alpha = dim_alpha
        else:
            var t := float(dist) / illuminated_radius
            alpha = lerp(fully_lit_alpha, dim_alpha, t)
        var base_color = _get_room_color(room.type)
        var color = Color(base_color.r, base_color.g, base_color.b, alpha)
        draw_rect(Rect2(pos * cell_size, Vector2(cell_size, cell_size)), color)
        draw_rect(Rect2(pos * cell_size, Vector2(cell_size, cell_size)), Color(0,0,0,alpha), false, 2.0)
    # Player marker:
    draw_rect(Rect2(player_pos * cell_size, Vector2(cell_size, cell_size)), Color(1, 1, 0, 1.0), false, 4.0)
    # Player marker
    draw_rect(Rect2(player_pos * cell_size, Vector2(cell_size, cell_size)), Color(1, 1, 0, 1.0), false, 4.0)

func use_matchstick():
    if _matchstick_active:
        return
    _matchstick_active = true
    await _burst_and_fade_matchstick()

func _burst_and_fade_matchstick() -> void:
    # Fade up to matchstick brightness
    await _tween_radius(float(illuminated_radius), float(matchstick_radius), matchstick_fade_up_time)
    # Hold at max brightness
    if matchstick_hold_time > 0.0:
        await get_tree().create_timer(matchstick_hold_time).timeout
    # Fade down to base
    await _tween_radius(float(matchstick_radius), float(base_illuminated_radius), matchstick_fade_down_time)
    illuminated_radius = float(base_illuminated_radius)
    _matchstick_active = false
    queue_redraw()

func _tween_radius(from: float, to: float, duration: float) -> void:
    var t := 0.0
    while t < duration:
        await get_tree().process_frame
        t += get_process_delta_time()
        var ratio: float = clamp(t / duration, 0, 1)
        illuminated_radius = lerp(from, to, ratio)
        queue_redraw()


func _get_room_color(room_type: MazeGenerator.RoomType) -> Color:
    var color: Color
    match room_type:
        MazeGenerator.RoomType.START:
            color = Color.LIME_GREEN
        MazeGenerator.RoomType.EXIT:
            color = Color.RED
        MazeGenerator.RoomType.ITEM:
            color = Color.DODGER_BLUE
        MazeGenerator.RoomType.COMBAT:
            color = Color.ORANGE
        MazeGenerator.RoomType.EVENT:
            color = Color.PURPLE
        MazeGenerator.RoomType.EMPTY:
            color = Color.LIGHT_GRAY
        _:
            color = Color.GRAY
    # if matchstick is active, use a yellow tint
    if _matchstick_active:
        color = color.lerp(Color.YELLOW, 0.5)
    return color

# Call this function (from an EditorPlugin or a custom UI button) to regenerate the maze after you tweak the generator's properties.
func regenerate() -> void:
    _generate_and_draw_maze()

