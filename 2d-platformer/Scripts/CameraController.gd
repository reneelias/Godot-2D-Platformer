extends Camera2D
class_name CameraController

@export var objectToFollow : Node2D

func _process(delta):
	if objectToFollow:
		var half_width = get_viewport_rect().size.x / 2 / zoom.x
		var half_height = get_viewport_rect().size.y / 2 / zoom.y
		var min_x = limit_left + half_width
		var max_x = limit_right - half_width
		var min_y = limit_top + half_height
		var max_y = limit_bottom - half_height

		global_position = Vector2(clamp(objectToFollow.global_position.x + offset.x, min_x, max_x), clamp(objectToFollow.global_position.y + offset.y, min_y, max_y))
		
