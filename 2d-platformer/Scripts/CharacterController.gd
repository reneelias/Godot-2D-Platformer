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
var jumpSpeedFramesCount := 0
@export var maxVelX = 250 
@export var coyoteFrames := 5
var coyoteFramesCount := 0
var startPos : Vector2
## Used for scaling extended jump frames speed
@export var jumpSpeedScaler := .125
# const JUMP_SPEED_SCALER = .125
var inputVelocity := Vector2.ZERO

enum PlayerState {
    IDLE,
    RUN,
    JUMP,
    FALL
}
var playerState := PlayerState.IDLE

func _ready():
    startPos = global_position

func _physics_process(delta):
    movement()
    updatePlayerState()

func updatePlayerState():
    if is_on_floor():
        if inputVelocity.x != 0:
            playerState = PlayerState.RUN
        else:
            playerState = PlayerState.IDLE
    elif not is_on_floor() and velocity.y > 0:
        playerState = PlayerState.FALL

func movement():
    velocity += Vector2(0, gravityScale)
    inputVelocity = Vector2.ZERO

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
    
    updateJump()
            
    if Input.is_key_pressed(KEY_R):
        global_position = startPos
        velocity = Vector2.ZERO
    
    move_and_slide()

func updateJump():
    if is_on_floor():
        coyoteFramesCount = 0
    else:
        coyoteFramesCount += 1

    if Input.is_key_pressed(KEY_SPACE):
        if is_on_floor() or (coyoteFramesCount < coyoteFrames and playerState != PlayerState.JUMP):
            jumpSpeedFramesCount = 0
            velocity -= Vector2(0, jumpSpeed)
            playerState = PlayerState.JUMP
        elif jumpSpeedFramesCount < jumpSpeedFrames:
            jumpSpeedFramesCount += 1
            velocity -= Vector2(0, jumpSpeed * jumpSpeedScaler * cos(float(jumpSpeedFramesCount)/jumpSpeedFrames * PI/2))