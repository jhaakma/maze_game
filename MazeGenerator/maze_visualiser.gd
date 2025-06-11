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
    var player_origin = player.position
    var matchsticks = controller.matchstick_manager.matchsticks
    var matchstick_data = []
    for m in matchsticks:
        if m.is_active():
            var origin = m.get_origin(player_origin)
            var radius = m.get_radius()
            var distances = controller.maze_data.get_distances(origin)
            matchstick_data.append({
                "distances": distances,
                "radius": radius
            })

    for pos in maze.keys():
        var room = maze[pos]

        # Player memory illumination
        var memory_level = player.memorised_rooms.get(pos, 0.0)
        var player_alpha := dim_alpha
        if memory_level:
            player_alpha = fully_lit_alpha * memory_level

        # Matchstick illumination: take the brightest from all active matchsticks
        var matchstick_alpha := dim_alpha
        for m in matchstick_data:
            var dist = m["distances"].get(pos, null)
            if dist != null and dist <= int(m["radius"]):
                var t2: float = float(dist) / m["radius"]
                var this_alpha = lerp(fully_lit_alpha, dim_alpha, t2)
                matchstick_alpha = max(matchstick_alpha, this_alpha)

        # Blend: take the brightest
        var alpha = max(player_alpha, matchstick_alpha)
        if player.position == pos:
            alpha = 1.0  # Always fully lit at player positiona
        var color = Color(room.color.r, room.color.g, room.color.b, alpha)
        draw_rect(Rect2(pos * cell_size, Vector2(cell_size, cell_size)), color)
        draw_rect(Rect2(pos * cell_size, Vector2(cell_size, cell_size)), Color(0,0,0,alpha), false, 2.0)

        # Draw room icon if available, with alpha
        if room.icon:
            var icon = room.icon_visited if room.visited and room.icon_visited else room.icon
            var icon_size = Vector2(cell_size, cell_size) * 0.8
            var icon_pos = Vector2(pos) * cell_size + (Vector2(cell_size, cell_size) - icon_size) / 2.0
            var icon_color = Color(1, 1, 1, alpha)  # White with the same alpha
            draw_texture_rect(icon, Rect2(icon_pos, icon_size), false, icon_color)

        # Draw entity icons
        for ent in room.entities:
            if ent.icon:
                var ent_icon = ent.icon
                var ent_icon_size = Vector2(cell_size, cell_size) * 0.8
                var ent_icon_pos = Vector2(pos) * cell_size + (Vector2(cell_size, cell_size) - ent_icon_size) / 2.0
                var ent_icon_color = Color(1, 1, 1, alpha)  # White with the same alpha
                draw_texture_rect(ent_icon, Rect2(ent_icon_pos, ent_icon_size), false, ent_icon_color)



    # Draw player at their current position
    draw_rect(Rect2(player.position * cell_size, Vector2(cell_size, cell_size)), Color(1, 1, 0, 1.0), false, 4.0)

func _get_room_color(room: Room) -> Color:
    var color = room.color
    return color


# Call this function (from an EditorPlugin or a custom UI button) to regenerate the maze.
func regenerate() -> void:
    if controller:
        controller.generate_maze()
        queue_redraw()
