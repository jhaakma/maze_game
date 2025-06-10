extends Node

class_name MazeGenerator

enum RoomType { START, EXIT, ITEM, COMBAT, EVENT, EMPTY }

@onready var room_enter: Room = preload("res://Rooms/room_enter.tres")
@onready var room_exit: Room = preload("res://Rooms/room_exit.tres")
@onready var room_empty: Room = preload("res://Rooms/room_empty.tres")

@export var room_count: int = 20
@export var branch_chance: float = 0.3
@export var max_walkers: int = 5
@export var bounds_min: Vector2i = Vector2i(-5, -5)
@export var bounds_max: Vector2i = Vector2i(5, 5)
@export var same_direction_chance: float = 0.65
## The MazeData resource that will be populated when generating a maze.
##
## The generator previously required a full `MazeGame` controller in order to
## access its `maze_data` field.  For unit tests and other tools we only need a
## `MazeData` instance, so this property stores the data directly.
@export var maze_data: MazeData
@export var room_types: Array[Room] = []


const DIRECTIONS: Array[Vector2i] = [
    Vector2i(1, 0),
    Vector2i(-1, 0),
    Vector2i(0, 1),
    Vector2i(0, -1)
]

class Walker:
    var pos: Vector2i
    var dir: Vector2i
    func _init(_pos: Vector2i, _dir: Vector2i) -> void:
        pos = _pos
        dir = _dir

func can_place_corridor(next_pos: Vector2i, source_pos: Vector2i) -> bool:
    var adjacent_count := 0
    for dir in DIRECTIONS:
        var check_pos = next_pos + dir
        if check_pos == source_pos:
            continue
        if maze_data.maze.has(check_pos):
            adjacent_count += 1
    # Only place if adjacent to exactly 0 (dead end) or 1 existing room (the parent)
    return adjacent_count == 0

func generate_maze(data: MazeData, start_pos: Vector2i = Vector2i(0, 0)):
    maze_data = data
    maze_data.maze.clear()
    var walkers: Array[Walker] = []
    var start_dir: Vector2i = DIRECTIONS[randi() % DIRECTIONS.size()]
    walkers.append(Walker.new(start_pos, start_dir))

    while maze_data.maze.size() < room_count and walkers.size() > 0:
        var i: int = randi() % walkers.size()
        var walker: Walker = walkers[i]

        # Find all valid directions for this walker
        var valid_dirs: Array[Vector2i] = []
        for dir in DIRECTIONS:
            var next_pos: Vector2i = walker.pos + dir
            if (
                next_pos.x < bounds_min.x or next_pos.x > bounds_max.x
                or next_pos.y < bounds_min.y or next_pos.y > bounds_max.y
                or maze_data.maze.has(next_pos)
                or not can_place_corridor(next_pos, walker.pos)
            ):
                continue
            valid_dirs.append(dir)

        if valid_dirs.is_empty():
            # Nowhere left to go, remove this walker
            walkers.remove_at(i)
            continue

        # Choose direction: same as before (with chance) or random valid direction
        var dir: Vector2i
        if randf() < same_direction_chance and valid_dirs.has(walker.dir):
            dir = walker.dir
        else:
            dir = valid_dirs[randi() % valid_dirs.size()]
            walker.dir = dir

        var next_position: Vector2i = walker.pos + dir
        maze_data.maze[next_position] = room_empty
        walkers.append(Walker.new(next_position, dir))
        walker.pos = next_position

        # Branch
        if walkers.size() < max_walkers and randf() < branch_chance:
            var clone_idx = randi() % walkers.size()
            var clone_walker = walkers[clone_idx]
            walkers.append(Walker.new(clone_walker.pos, clone_walker.dir))

        # Only remove a walker if it has no valid moves, handled at the start of loop

    # At this point, all rooms are EMPTY except the START room.
    # Find furthest room for EXIT (structure only)
    var furthest_pos = find_furthest_room(start_pos)
    # Assign special room types in a separate pass
    assign_room_types(start_pos, furthest_pos)


func find_furthest_room(start_pos: Vector2i) -> Vector2i:
    var visited: Dictionary[Vector2i, int] = {}
    var queue: Array[Vector2i] = [start_pos]
    visited[start_pos] = 0
    var furthest_pos: Vector2i = start_pos
    var max_distance: int = 0

    while queue.size() > 0:
        var current: Vector2i = queue.pop_front()
        var dist: int = visited[current]
        if dist > max_distance:
            max_distance = dist
            furthest_pos = current
        for dir in DIRECTIONS:
            var neighbor: Vector2i = current + dir
            if maze_data.maze.has(neighbor) and not visited.has(neighbor):
                visited[neighbor] = dist + 1
                queue.append(neighbor)
    return furthest_pos

func assign_room_types(start_pos: Vector2i, exit_pos: Vector2i) -> void:
    # Set START and EXIT
    maze_data.maze[start_pos] = room_enter
    maze_data.maze[exit_pos] = room_exit

    # Example: Assign one ITEM room and one COMBAT room at random (expand as needed)
    var candidates := []
    for pos in maze_data.maze.keys():
        if maze_data.maze[pos].empty:
            candidates.append(pos)

    if room_types.is_empty():
        return

    # for each empty room, try to spawn a room type
    for pos in candidates:
        #pick a random room type
        var new_room: Room = room_types[randi() % room_types.size()]
        #Check spawn chance
        if randf() < new_room.spawn_chance:
            print("Placing room at ", pos, " with type: ", new_room.description)
            maze_data.maze[pos] = new_room
