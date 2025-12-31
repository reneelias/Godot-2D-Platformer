extends Area2D
class_name Button_Machine

@export var text : RichTextLabel

func _ready():
	text.modulate.a = 0



func _on_body_entered(body: Node2D):
	var player = body as CharacterController
	if player:
		text.modulate.a = 1

func _on_body_exited(body: Node2D):
	var player = body as CharacterController
	if player:
		text.modulate.a = 0
