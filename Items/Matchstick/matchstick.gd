extends Node

class_name Matchstick

signal illumination_changed

var active: bool = false
var origin: Vector2i = Vector2i.ZERO
var illuminated_radius: float = 1.0

var base_radius: int = 3
var burst_radius: int = 8
var fade_up_time: float = 0.1
var fade_down_time: float = 1.5
var hold_time: float = 2.0

func configure(base_radius_: int, burst_radius_: int, fade_up: float, fade_down: float, hold: float) -> void:
    base_radius = base_radius_
    burst_radius = burst_radius_
    fade_up_time = fade_up
    fade_down_time = fade_down
    hold_time = hold
    illuminated_radius = float(base_radius)

func use(origin_: Vector2i) -> void:
    if active:
        return
    active = true
    origin = origin_
    _burst_and_fade()

func _burst_and_fade() -> void:
    await _tween_radius(float(illuminated_radius), float(burst_radius), fade_up_time)
    if hold_time > 0.0:
        await get_tree().create_timer(hold_time).timeout
    await _tween_radius(float(burst_radius), float(base_radius), fade_down_time)
    illuminated_radius = float(base_radius)
    active = false
    origin = Vector2i.ZERO
    illumination_changed.emit()

func _tween_radius(from: float, to: float, duration: float) -> void:
    var t := 0.0
    while t < duration:
        await get_tree().process_frame
        t += get_process_delta_time()
        var ratio: float = clamp(t / duration, 0, 1)
        illuminated_radius = lerp(from, to, ratio)
        illumination_changed.emit()

func is_active() -> bool:
    return active

func get_origin(default_origin: Vector2i) -> Vector2i:
    return origin if active else default_origin

func get_radius() -> float:
    return illuminated_radius