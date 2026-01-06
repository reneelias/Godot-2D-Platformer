extends Area2D
class_name Button_Machine

@export_group("References")
@export var sprite : Sprite2D
@export var text : RichTextLabel
@export var light : PointLight2D

@export_category("Settings")
@export var color_activated : Color
@export var color_deactivated : Color
@export var activated := false

func _ready():
	text.modulate.a = 0
	if activated:
		light.color = color_activated
		sprite.frame = 0
	else:
		light.color = color_deactivated
		sprite.frame = 1


func _on_body_entered(body: Node2D):
	var player = body as CharacterController
	if player:
		text.modulate.a = 1

func _on_body_exited(body: Node2D):
	var player = body as CharacterController
	if player:
		text.modulate.a = 0
