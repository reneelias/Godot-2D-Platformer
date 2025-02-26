extends Node

class_name PlayerRaycasts

@export_group("References")
@export var _crouchRaycast : RayCast2D
## true if _crouchRaycast detects collision
var crouchRaycastCollision : bool = false


func _physics_process(delta):
    crouchRaycastCollision = _crouchRaycast.is_colliding()
