extends Camera2D
class_name CameraController

@export var objectToFollow : Node2D

func _process(delta):
    if objectToFollow:
        global_position = objectToFollow.global_position + offset

