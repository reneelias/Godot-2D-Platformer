extends Area2D
class_name Checkpoint

@export var characterSpawn : Sprite2D

func _ready():
	visible = false

func onBodyEntered(body : Node2D):
	if body in get_tree().get_nodes_in_group("Player"):
		(body as CharacterController).checkpointEntered(self)
