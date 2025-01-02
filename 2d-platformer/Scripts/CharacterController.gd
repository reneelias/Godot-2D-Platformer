extends CharacterBody2D
class_name CharacterController

@export_group("References")
@export var sprite2D : Sprite2D
@export var animPlayer : AnimationPlayer

@export_category("Physics")
@export var gravityScale := 9.81
@export var moveSpeed := 5.0
@export var jumpSpeed := 100.0
@export var friction := .025
@export var inAirDamp := .5
@export var jumpSpeedFrames := 10
const JUMP_FRAMES = 9
const WALL_JUMP_FRAMES = 6
var jumpSpeedFramesCount := 0
@export var maxVelX := 250.0 
@export var coyoteFrames := 5
var coyoteFramesCount := 0
var startPos : Vector2
## Used for scaling extended jump frames speed
@export var jumpSpeedScaler := .125
# const JUMP_SPEED_SCALER = .125
@export var wallJumpSpeed := 200.0
@export var wallHugSpeed := 100.0
@export var wallCoyoteFrames := 5
var wallCoyoteFramesCount := 0
var inputVelocity := Vector2.ZERO
var touchingWall := false

enum PlayerMode{
	PLAYING,
	CINEMATIC,
	DIALOGUE
}
@export var playerMode := PlayerMode.PLAYING

enum PlayerState {
	HUNCHED_OVER,
	IDLE,
	RUN,
	JUMP,
	FALL,
	WALL_HUG
}
@export var playerState := PlayerState.IDLE

var playerStateAnimDict : Dictionary = {
	PlayerState.HUNCHED_OVER: "HunchedOver",
	PlayerState.IDLE: "Idle",
	PlayerState.RUN: "Run",
	PlayerState.JUMP: "Jump",
	PlayerState.FALL: "Fall",
	PlayerState.WALL_HUG: "WallHug"
}

func _ready():
	startPos = global_position
	if playerState == PlayerState.HUNCHED_OVER:
		animPlayer.play("HunchedOver")

func _physics_process(delta):
	match playerMode:
		PlayerMode.PLAYING:
			movement()
			updatePlayerState()
		PlayerMode.CINEMATIC:
			pass
		PlayerMode.DIALOGUE:
			pass

func updatePlayerState():
	if is_on_floor():
		if inputVelocity.x != 0:
			setPlayerState(PlayerState.RUN)
		elif playerState != PlayerState.HUNCHED_OVER:
			setPlayerState(PlayerState.IDLE)
	# elif is_on_wall() and get_wall_normal().x == -inputVelocity.normalized().x:
	elif is_on_wall() and get_wall_normal().x == -inputVelocity.normalized().x and velocity.y > 0:
		setPlayerState(PlayerState.WALL_HUG)
	# elif not is_on_floor() and playerState != PlayerState.WALL_HUG or wallCoyoteFrames >= wallCoyoteFramesCount:
	elif not is_on_floor() and velocity.y > wallHugSpeed - 1 and (playerState != PlayerState.WALL_HUG or (playerState == PlayerState.WALL_HUG and !is_on_wall())):
		setPlayerState(PlayerState.FALL)

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
		sprite2D.flip_h = inputVelocity.x < 0
	

	updateJump()
			
	if playerState == PlayerState.WALL_HUG and velocity.y > 0:
		velocity.y = min(velocity.y, wallHugSpeed)
		
	if Input.is_key_pressed(KEY_R):
		global_position = startPos
		velocity = Vector2.ZERO
	
	move_and_slide()

func updateJump():
	if is_on_floor():
		coyoteFramesCount = 0
	elif coyoteFramesCount < coyoteFrames:
		coyoteFramesCount += 1
		
	# if is_on_wall() and (!touchingWall or get_wall_normal().x == -inputVelocity.normalized().x):
	if (is_on_wall() and get_wall_normal().x == -inputVelocity.normalized().x) or playerState == PlayerState.WALL_HUG:
		wallCoyoteFramesCount = 0
	elif wallCoyoteFramesCount < wallCoyoteFrames:
		wallCoyoteFramesCount += 1

	touchingWall = is_on_wall()
	
	if Input.is_action_just_pressed("Jump"):
		if (is_on_floor() or coyoteFramesCount < coyoteFrames) and playerState != PlayerState.JUMP:
			jumpSpeedFramesCount = 0
			jumpSpeedFrames = JUMP_FRAMES
			velocity -= Vector2(0, jumpSpeed)
			setPlayerState(PlayerState.JUMP)
		elif (is_on_wall() and get_wall_normal().x == -inputVelocity.normalized().x) or playerState == PlayerState.WALL_HUG or wallCoyoteFramesCount < wallCoyoteFrames:
			jumpSpeedFramesCount = 0
			jumpSpeedFrames = WALL_JUMP_FRAMES
			var wallJumpVec = get_wall_normal()
			#
			#	Remove wallJumpAngle later if unnecessary
			#
			var wallJumpAngle = 50 if (get_wall_normal().x == -inputVelocity.normalized().x or playerState == PlayerState.WALL_HUG) else 70
			wallJumpAngle = 50
			print("Wall Jump Angle: ", wallJumpAngle)
			wallJumpVec = wallJumpVec.rotated(deg_to_rad(wallJumpAngle) * wallJumpVec.x)
			wallJumpVec.y = -abs(wallJumpVec.y)
			#
			#	Remove wallJumpScaler later if unnecessary
			#
			var wallJumpScaler = 1.0 if (get_wall_normal().x == -inputVelocity.normalized().x or playerState == PlayerState.WALL_HUG) else .75
			wallJumpScaler = 1.0
			print("wallJumpScaler: ", wallJumpScaler)
			velocity = wallJumpVec * wallJumpSpeed * wallJumpScaler
			wallCoyoteFramesCount = wallCoyoteFrames
			setPlayerState(PlayerState.JUMP, "" if get_wall_normal().x == -inputVelocity.normalized().x  else "WallJump")
	# elif Input.is_action_pressed("Jump") and (playerState == PlayerState.JUMP or playerState == PlayerState.WALL_HUG) and jumpSpeedFramesCount < jumpSpeedFrames:
	elif Input.is_action_pressed("Jump") and playerState == PlayerState.JUMP and jumpSpeedFramesCount < jumpSpeedFrames:
		jumpSpeedFramesCount += 1
		velocity -= Vector2(0, jumpSpeed * jumpSpeedScaler * cos(float(jumpSpeedFramesCount)/jumpSpeedFrames * PI/2))

func setPlayerState(state : PlayerState, animName : String = ""):
	playerState = state
	if animName != "":
		animPlayer.play(animName)
	else:
		animPlayer.play(playerStateAnimDict[state])