extends CharacterBody2D
class_name CharacterController

@export_group("References")
@export var animSprite : AnimatedSprite2D

@export_category("Physics")
@export var gravityScale := 9.81
@export var moveSpeed := 5.0
@export var jumpSpeed := 100
@export var friction := .025
@export var inAirDamp := .5
@export var jumpSpeedFrames := 10
@export var maxVelX = 250 
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
    var inputVelocity := Vector2.ZERO

    var moveSpeedVec := Vector2(moveSpeed, 0)
    if Input.is_key_pressed(KEY_A):
        inputVelocity -= moveSpeedVec * (inAirDamp if (not is_on_floor()) else 1.0)
    if Input.is_key_pressed(KEY_D):
        inputVelocity += moveSpeedVec * (inAirDamp if (not is_on_floor()) else 1.0)
        
    if is_on_floor() and inputVelocity.length() == 0:
        velocity -= Vector2(velocity.x * friction, 0)
    
    velocity += inputVelocity
    if abs(velocity.x) > maxVelX:
        velocity.x = maxVelX if velocity.x > 0 else -maxVelX
    
    if inputVelocity.x != 0:
        animSprite.flip_h = inputVelocity.x < 0
    
    if Input.is_key_pressed(KEY_SPACE):
        if is_on_floor():
            jumpSpeedFramesCount = 0
            velocity -= Vector2(0, jumpSpeed)
        elif jumpSpeedFramesCount < jumpSpeedFrames:
            jumpSpeedFramesCount += 1
            velocity -= Vector2(0, jumpSpeed * jumpSpeedScaler * cos(float(jumpSpeedFramesCount)/jumpSpeedFrames * PI/2))
            
    if Input.is_key_pressed(KEY_R):
        global_position = startPos
        velocity = Vector2.ZERO
    
    move_and_slide()