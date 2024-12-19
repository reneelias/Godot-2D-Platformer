extends CharacterBody2D

@export var gravityScale := 9.81
@export var moveSpeed := 5.0
@export var jumpSpeed := 100
@export var friction := .025
@export var inAirDamp := .5
var startPos : Vector2

func _ready():
    startPos = global_position

func _physics_process(delta):
    velocity += Vector2(0, gravityScale)

    var moveSpeedVec := Vector2(moveSpeed, 0)
    if Input.is_key_pressed(KEY_A):
        velocity -= moveSpeedVec * (inAirDamp if (not is_on_floor()) else 1.0)
    if Input.is_key_pressed(KEY_D):
        velocity += moveSpeedVec * (inAirDamp if (not is_on_floor()) else 1.0)
    if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
        print("jumping")
        velocity -= Vector2(0, jumpSpeed)

    if is_on_floor():
        velocity -= Vector2(velocity.x * friction, 0)

    if Input.is_key_pressed(KEY_R):
        global_position = startPos
        velocity = Vector2.ZERO
        
    move_and_slide()