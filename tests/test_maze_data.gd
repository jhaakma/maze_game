extends SceneTree

func _init():
    var MazeData := preload("res://MazeGenerator/MazeData.gd")

    var md = MazeData.new()
    md.maze[Vector2i(0, 0)] = true
    md.maze[Vector2i(1, 0)] = true

    var distances = md.get_distances(Vector2i(0, 0))
    if distances.get(Vector2i(0, 0)) != 0:
        push_error("Distance from start should be 0")
        quit(1)
    elif distances.get(Vector2i(1, 0)) != 1:
        push_error("Distance to neighbor should be 1")
        quit(1)
    else:
        print("MazeData test passed")
        quit()
