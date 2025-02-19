extends Area2D

@export var spinSpeed := -15.0
@export var invertSpin := false


func _physics_process(delta):
    rotate(spinSpeed * delta * (-1 if invertSpin else 1))

func onBodyEntered(body: Node):
    var player = body as CharacterController
    if player:
        player.death()
