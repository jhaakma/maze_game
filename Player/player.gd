extends Node

class_name Player

signal memory_updated

@export var position: Vector2i = Vector2i.ZERO
@export var memory_loss_per_move: float = 0.1  # Amount of memory lost per move
@export var forget_interval: float = 0.2  # Time in seconds to forget a room
@export var memory_loss_per_second: float = 0.05  # Amount of memory lost per second
@export var vision_radius: int = 3  # How far the player can see
# key: position, value: memory level (0-1)
var memorised_rooms: Dictionary[Vector2i, float] = {}

var forget_timer: Timer

func _ready():
    memorised_rooms.clear()
    memorised_rooms[position] = 1.0
    forget_timer = Timer.new()
    forget_timer.wait_time = forget_interval
    forget_timer.one_shot = false
    forget_timer.autostart = true
    forget_timer.connect("timeout", _on_forget_timer_timeout)
    add_child(forget_timer)
    forget_timer.start()

func try_move(direction: Vector2i, maze_data: MazeData) -> void:
    var new_pos = position + direction
    if maze_data.maze.has(new_pos):
        position = new_pos
        var room = maze_data.maze[new_pos]
        if room is Room:
            room.on_enter(self)
            learn_rooms(maze_data)
        else:
            print("No valid room at position: ", new_pos)
        forget_rooms()
    else:
        fail_move(new_pos)
    #reset timer duration
    forget_timer.start()

# set memory level from 1.0 to 0.0 based on distance from the player
func learn_rooms(maze_data: MazeData):
    var maze = maze_data.get_distances(position)
    for pos in maze.keys():
        if pos != position:
            var distance = maze[pos]
            var memory_level = 1.0 - (float(distance) / float(vision_radius))
            if memory_level < 0.0:
                memory_level = 0.0
            memorised_rooms[pos] = max(memorised_rooms.get(pos, 0.0), memory_level)


func forget_rooms():
    for pos in memorised_rooms.keys():
        if pos != position:
            memorised_rooms[pos] = max(0.0, memorised_rooms[pos] - memory_loss_per_move)
            if memorised_rooms[pos] <= 0.0:
                memorised_rooms.erase(pos)  # Remove rooms with no memory left

func fail_move(new_pos: Vector2i) -> void:
    print("Cannot move to position: ", new_pos, " - no room exists there.")
    # play a sound or something

#Forget rooms slowly over time
func _on_forget_timer_timeout() -> void:
    for pos in memorised_rooms.keys():
        if pos != position:
            memorised_rooms[pos] = max(0.0, memorised_rooms[pos] - memory_loss_per_second * forget_interval)
            if memorised_rooms[pos] <= 0.0:
                memorised_rooms.erase(pos)  # Remove rooms with no memory left
    print("Memory updated: ", memorised_rooms)
    emit_signal("memory_updated")
