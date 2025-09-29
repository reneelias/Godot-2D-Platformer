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
@export var usesGravity := false;
@export var gravityScale := 9.81
@export var velocity := Vector2.ZERO
@export var usesLifespan := false
@export var lifetime := 3.0
var lifeStarted : float


func _ready():
	if usesLifespan:
		lifeStarted = Time.get_ticks_msec()

func _physics_process(delta):
	rotate(spinSpeed * delta * (-1 if invertSpin else 1))
	if pathFollow and followsPath:
		pathFollow.progress += delta * pathFollowSpeed
		global_position = pathFollow.global_position

	if usesGravity:
		velocity.y += gravityScale * delta
		position += velocity
		
	if usesLifespan and Time.get_ticks_msec() - lifeStarted >= lifetime * 1000:
		queue_free()
	

func onBodyEntered(body: Node):
	var player = body as CharacterController
	if player:
		player.death()
