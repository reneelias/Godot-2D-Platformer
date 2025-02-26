extends Node

class_name PlayerRaycasts

@onready var crouchRaycast = $CrouchRaycast
@onready var wallRaycastLeftTop = $WallRaycast_LeftTop
@onready var wallRaycastLeftBottom = $WallRaycast_LeftBottom
@onready var wallRaycastRightTop = $WallRaycast_RightTop
@onready var wallRaycastRightBottom = $WallRaycast_RightBottom

## true if crouchRaycast detects collision
var crouchRaycastCollision : bool = false

var wallCollision : bool :
	get:
		return rightWallCollision or leftWallCollision

var rightWallCollision : bool :
	get:
		return wallRaycastRightTop.is_colliding() or wallRaycastRightBottom.is_colliding()

var leftWallCollision : bool :
	get:
		return wallRaycastLeftTop.is_colliding() or wallRaycastLeftBottom.is_colliding()

var wallCollisionNormal : Vector2:
	get:
		if rightWallCollision:
			return Vector2.LEFT
		elif leftWallCollision:
			return Vector2.RIGHT
		else:
			return Vector2.ZERO

func _physics_process(delta):
	crouchRaycastCollision = crouchRaycast.is_colliding()
