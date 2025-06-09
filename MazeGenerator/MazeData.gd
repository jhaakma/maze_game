extends Resource

class_name MazeData

# Store rooms in a dictionary indexed by grid position.
var maze: Dictionary = {}

# Local copy of the maze directions so this script has no external dependencies
# when loaded in isolation (e.g. for unit tests).
const DIRECTIONS: Array[Vector2i] = [
    Vector2i(1, 0),
    Vector2i(-1, 0),
    Vector2i(0, 1),
    Vector2i(0, -1),
]


func get_distances(from: Vector2i) -> Dictionary[Vector2i, int]:
    var distances: Dictionary[Vector2i, int] = {}
    var queue: Array[Vector2i] = [from]
    distances[from] = 0
    while queue.size() > 0:
        var current = queue.pop_front()
        var current_dist = distances[current]
        for dir in DIRECTIONS:
            var neighbor = current + dir
            if maze.has(neighbor) and not distances.has(neighbor):
                distances[neighbor] = current_dist + 1
                queue.append(neighbor)
    return distances
