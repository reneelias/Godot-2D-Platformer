extends Node

class_name PlayerRaycasts

@export_group("References")
@export var _crouchRaycast : RayCast2D
@export var _squishRaycastLeft : RayCast2D
@export var _squishRaycastRight : RayCast2D

## true if _crouchRaycast detects collision
var crouchRaycastCollision : bool = false
## true if _squishRaycastLeft detects collision
var squishRaycastLeftCollision : bool = false
## true if _squishRaycastRight detects collision
var squishRaycastRightCollision : bool = false

signal horizontal_squish

func _physics_process(delta):
    crouchRaycastCollision = _crouchRaycast.is_colliding()
    squishRaycastLeftCollision = _squishRaycastLeft.is_colliding()
    squishRaycastRightCollision = _squishRaycastRight.is_colliding()

    # if squishRaycastLeftCollision or squishRaycastRightCollision:
    #     print("squishRaycastLeftCollision: ", squishRaycastLeftCollision)
    #     print("squishRaycastRightCollision: ", squishRaycastRightCollision)
    if squishRaycastLeftCollision and squishRaycastRightCollision:
        emit_signal("horizontal_squish")