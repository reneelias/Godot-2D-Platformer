extends Area2D
class_name KillArea

func onBodyEntered(body: Node):
    var player = body as CharacterController
    if player:
        player.death()