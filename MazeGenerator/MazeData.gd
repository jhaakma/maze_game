extends Resource

class_name MazeData

var maze: Dictionary[Vector2i, Room] = {}


func get_distances(from: Vector2i) -> Dictionary[Vector2i, int]:
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
