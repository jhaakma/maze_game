extends Node2D

## Draws the maze based on the state provided by a controller node.

@export var cell_size: int = 48
@export var controller: Node
@export var fully_lit_alpha: float = 1.0
@export var dim_alpha: float = 0.1

func _ready() -> void:
    if controller == null:
        push_error("MazeVisualiser: No controller assigned.")

func _draw() -> void:
    if controller == null:
        return
    var maze: Dictionary = controller.maze
    if maze.is_empty():
        return
    var distances = controller.get_maze_distances(controller.player_pos)
    for pos in maze.keys():
        var room = maze[pos]
        var dist = distances.get(pos, null)
        var alpha := dim_alpha
        if dist != null and dist <= int(controller.illuminated_radius):
            var t := float(dist) / controller.illuminated_radius
            alpha = lerp(fully_lit_alpha, dim_alpha, t)
        var base_color = _get_room_color(room.type, controller.is_matchstick_active())
        var color = Color(base_color.r, base_color.g, base_color.b, alpha)
        draw_rect(Rect2(pos * cell_size, Vector2(cell_size, cell_size)), color)
        draw_rect(Rect2(pos * cell_size, Vector2(cell_size, cell_size)), Color(0,0,0,alpha), false, 2.0)
    draw_rect(Rect2(controller.player_pos * cell_size, Vector2(cell_size, cell_size)), Color(1, 1, 0, 1.0), false, 4.0)

func _get_room_color(room_type: MazeGenerator.RoomType, matchstick_active: bool) -> Color:
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
    if matchstick_active:
        color = color.lerp(Color.YELLOW, 0.5)
    return color

# Call this function (from an EditorPlugin or a custom UI button) to regenerate the maze.
func regenerate() -> void:
    if controller:
        controller.generate_maze()
        queue_redraw()

