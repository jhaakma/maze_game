extends Camera2D

func update_camera_position(pos: Vector2i) -> void:
    # Update the camera position to center on the given position
    print("Updating camera position to: ", pos)
    global_position = Vector2(pos * 32.0)