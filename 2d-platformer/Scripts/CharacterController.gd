extends CharacterBody2D
class_name CharacterController

@export var gravityScale := 9.81
@export var moveSpeed := 5.0
@export var jumpSpeed := 100
@export var friction := .025
@export var inAirDamp := .5
@export var jumpSpeedFrames := 10
var jumpSpeedFramesCount := 0
var startPos : Vector2

@export var jumpSpeedScaler := .125
# const JUMP_SPEED_SCALER = .125


func _ready():
    startPos = global_position

func _physics_process(delta):
    movement()

func movement():
    velocity += Vector2(0, gravityScale)

    var moveSpeedVec := Vector2(moveSpeed, 0)
    if Input.is_key_pressed(KEY_A):
        velocity -= moveSpeedVec * (inAirDamp if (not is_on_floor()) else 1.0)
    if Input.is_key_pressed(KEY_D):
        velocity += moveSpeedVec * (inAirDamp if (not is_on_floor()) else 1.0)
    if Input.is_key_pressed(KEY_SPACE):
        if is_on_floor():
            jumpSpeedFramesCount = 0
            velocity -= Vector2(0, jumpSpeed)
        elif jumpSpeedFramesCount < jumpSpeedFrames:
            jumpSpeedFramesCount += 1
            velocity -= Vector2(0, jumpSpeed * jumpSpeedScaler * cos(float(jumpSpeedFramesCount)/jumpSpeedFrames * PI/2))
            
    if is_on_floor():
        velocity -= Vector2(velocity.x * friction, 0)

    if Input.is_key_pressed(KEY_R):
        global_position = startPos
        velocity = Vector2.ZERO
        
    move_and_slide()