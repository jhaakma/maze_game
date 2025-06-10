extends SceneTree

func _init():
    var MazeGenerator := preload("res://MazeGenerator/maze_generator.gd")
    var MazeData := preload("res://MazeGenerator/MazeData.gd")

    # Use a fixed random seed for deterministic output
    seed(1)

    var gen = MazeGenerator.new()
    get_root().add_child(gen)
    await gen.ready

    var data = MazeData.new()
    gen.room_count = 10
    gen.bounds_min = Vector2i(-5, -5)
    gen.bounds_max = Vector2i(5, 5)
    gen.generate_maze(data, Vector2i.ZERO)

    if data.maze.size() > gen.room_count + 1:
        push_error("Maze has more rooms than expected")
        quit(1)

    var exit_pos
    for pos in data.maze.keys():
        if data.maze[pos] == gen.room_exit:
            exit_pos = pos
            break

    if exit_pos == null:
        push_error("Maze has no exit room")
        quit(1)
    elif exit_pos == Vector2i.ZERO:
        push_error("Exit room cannot be at the start position")
        quit(1)

    print("MazeGenerator test passed")
    quit()
