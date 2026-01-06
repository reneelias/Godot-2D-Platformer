extends Node2D

@export var animator : AnimationPlayer
@export var opened := false

func _ready():
	if opened:
		activate()
	else:
		deactivate()

func activate():
	opened = true
	animator.play("Open")

func deactivate():
	opened = false
	animator.play("Close")
