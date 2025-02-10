extends Area2D
class_name Checkpoint

func onBodyEntered(body : Node2D):
	if body in get_tree().get_nodes_in_group("Player"):
		(body as CharacterController).checkpointEntered(self)
