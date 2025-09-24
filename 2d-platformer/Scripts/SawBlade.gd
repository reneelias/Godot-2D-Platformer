extends Area2D
class_name SawBlade

@export_category("References")
@export var pathFollow : PathFollow2D
@export var sprite2D : Sprite2D

@export_category("Settings")
@export var spinSpeed := -15.0
@export var invertSpin := false
@export var followsPath := true
@export var pathFollowSpeed := 70.0


func _physics_process(delta):
	rotate(spinSpeed * delta * (-1 if invertSpin else 1))
	if pathFollow and followsPath:
		pathFollow.progress += delta * pathFollowSpeed
		global_position = pathFollow.global_position

func onBodyEntered(body: Node):
	var player = body as CharacterController
	if player:
		player.death()
