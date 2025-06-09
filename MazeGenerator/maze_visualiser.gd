extends Node2D

## Draws the maze based on the state provided by a controller node.

@export var cell_size: int = 48
@export var controller: MazeGame
@export var fully_lit_alpha: float = 1.0
@export var dim_alpha: float = 0.1

func _ready() -> void:
    if controller == null:
        push_error("MazeVisualiser: No controller assigned.")

func _draw() -> void:
    if controller == null or controller.maze_data == null or controller.player == null:
        return
    var maze: Dictionary = controller.maze_data.maze
    if maze.is_empty():
        return

    var player = controller.player
    var player_origin = controller.player.position
    var player_distances = controller.maze_data.get_distances(player_origin)
    var matchstick_active = controller.is_matchstick_active()
    var matchstick_origin = controller.matchstick.get_origin(player_origin)
    var matchstick_distances = controller.maze_data.get_distances(matchstick_origin) if matchstick_active else {}

    for pos in maze.keys():
        var room = maze[pos]

        # Always fully illuminate visited rooms
        var memory_level = controller.player.memorised_rooms.get(pos, 0.0)
        var player_alpha := dim_alpha
        var player_dist = player_distances.get(pos, null)
        if memory_level:
            player_alpha = fully_lit_alpha * memory_level
        # elif player_dist != null and player_dist <= int(player.vision_radius):
        #     var t: float = float(player_dist) / player.vision_radius
        #     player_alpha = lerp(fully_lit_alpha, dim_alpha, t)

        # Calculate matchstick-based illumination (use animated radius)
        var matchstick_alpha := dim_alpha
        if matchstick_active:
            var matchstick_dist = matchstick_distances.get(pos, null)
            if matchstick_dist != null and matchstick_dist <= int(controller.matchstick.illuminated_radius):
                var t2: float = float(matchstick_dist) / controller.matchstick.illuminated_radius
                matchstick_alpha = lerp(fully_lit_alpha, dim_alpha, t2)

        # Blend: take the brightest, and tint yellow only if matchstick is the brightest
        var alpha = max(player_alpha, matchstick_alpha)

        var color = Color(room.color.r, room.color.g, room.color.b, alpha)
        draw_rect(Rect2(pos * cell_size, Vector2(cell_size, cell_size)), color)
        draw_rect(Rect2(pos * cell_size, Vector2(cell_size, cell_size)), Color(0,0,0,alpha), false, 2.0)

    # Draw player at their current position
    draw_rect(Rect2(controller.player.position * cell_size, Vector2(cell_size, cell_size)), Color(1, 1, 0, 1.0), false, 4.0)

func _get_room_color(room: Room) -> Color:
    var color = room.color
    return color

# Call this function (from an EditorPlugin or a custom UI button) to regenerate the maze.
func regenerate() -> void:
    if controller:
        controller.generate_maze()
        queue_redraw()
