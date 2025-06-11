extends Node

class_name MatchstickManager

signal illumination_changed

@export var player: Player
@export var matchstick_radius: int = 8
@export var matchstick_fade_up_time: float = 0.1
@export var matchstick_fade_down_time: float = 1.5
@export var matchstick_hold_time: float = 2.0

var matchsticks: Array[Matchstick] = []

func use_matchstick() -> void:
    if player == null:
        return
    var matchstick = Matchstick.new()
    add_child(matchstick)
    matchstick.configure(
        player.vision_radius,
        matchstick_radius,
        matchstick_fade_up_time,
        matchstick_fade_down_time,
        matchstick_hold_time
    )
    matchstick.illumination_changed.connect(_on_matchstick_changed)
    matchstick.matchstick_out.connect(_on_matchstick_out.bind(matchstick))
    matchstick.use(player.position)
    matchsticks.append(matchstick)
    illumination_changed.emit()

func _on_matchstick_changed() -> void:
    illumination_changed.emit()

func _on_matchstick_out(matchstick: Matchstick) -> void:
    if matchsticks.has(matchstick):
        matchsticks.erase(matchstick)
        matchstick.queue_free()
        illumination_changed.emit()

func is_matchstick_active() -> bool:
    for m in matchsticks:
        if m.is_active():
            return true
    return false

func get_illumination_origin(default_origin: Vector2i) -> Vector2i:
    var reversed_matchsticks = matchsticks.duplicate()
    reversed_matchsticks.reverse()
    for m in reversed_matchsticks:
        if m.is_active():
            return m.get_origin(default_origin)
    return default_origin

func get_illuminated_radius() -> float:
    var reversed_matchsticks = matchsticks.duplicate()
    reversed_matchsticks.reverse()
    for m in reversed_matchsticks:
        if m.is_active():
            return m.get_radius()
    return 0.0

func clear_matchsticks() -> void:
    for m in matchsticks:
        m.queue_free()
    matchsticks.clear()

