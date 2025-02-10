extends Area2D
class_name Checkpoint

func onBodyEntered(body : Node2D):
	print("Checkpoint Entered: " + body.name)
	print(get_tree().get_nodes_in_group("Player").size())
	if body in get_tree().get_nodes_in_group("Player"):
		(body as CharacterController).checkpointEntered(self)

func onAreaEntered(area : Area2D):
	print("Checkpoint Entered: " + area.name)
