extends CharacterBody2D
class_name CharacterController

@export_group("References")
@export var sprite2D : Sprite2D
@export var animPlayer : AnimationPlayer
@export var raycasts : PlayerRaycasts

@export_category("Movement Physics")
@export var gravityScale := 9.81
@export var moveSpeed := 5.0
@export var jumpSpeed := 100.0
## The higher the number, the less friction affects the player
@export var frictionSpeedRetention := .25
## Ratio of speed when player is in the air compared to when on the ground
@export var inAirSpeedScale := .5
@export var jumpSpeedFrames := 10
## How much velocity scaled down by when turning
@export var turnSpeedScaler := .5
const JUMP_FRAMES = 9
const WALL_JUMP_FRAMES = 6
var jumpSpeedFramesCount := 0
@export var maxVelX := 250.0 
@export var coyoteFrames := 5
var coyoteFramesCount := 0
var startPos : Vector2
## Used for scaling extended jump frames speed
@export var jumpSpeedScaler := .125
## Modifier for slideFrictionMod. This is used to increase the slide friction over time.
var slideFrictionModMod := 1.0
var inputVelocity := Vector2.ZERO

@export_subgroup("Crouch and Slide")
## Used to decrease friction when the player is sliding
@export var slideFrictionMod := 1.3
## The speed threshold for the player to crouch
@export var crouchSpeedThreshold := 25.0
## The movement speed scaler for the player when crouching
@export var crouchSpeedScaler := .125
## The jump speed scaler for the player when crouching
@export var crouchJumpScaler := .25

@export_subgroup("Wall Jumping")
@export var wallJumpSpeed := 200.0
@export var wallHugSpeed := 100.0
@export var wallCoyoteFrames := 5
@export var wallJumpAngle := 50.0
var wallCoyoteFramesCount := 0

@export_category("Death")
@export var deathTime := 1.0

var currCheckpoint : Node2D


@export_category("Player State")
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
	WALL_HUG,
	CROUCHED,
	SLIDING,
	DEATH
}
@export var playerState := PlayerState.IDLE

var playerStateAnimDict : Dictionary = {
	PlayerState.HUNCHED_OVER: "HunchedOver",
	PlayerState.IDLE: "Idle",
	PlayerState.RUN: "Run",
	PlayerState.JUMP: "Jump",
	PlayerState.FALL: "Fall",
	PlayerState.WALL_HUG: "WallHug",
	PlayerState.CROUCHED: "Crouch",
	PlayerState.SLIDING: "Slide"
}

func _ready():
	startPos = global_position
	if playerState == PlayerState.HUNCHED_OVER:
		animPlayer.play("HunchedOver")
	raycasts.horizontal_squish.connect(Callable(self, "horizontalSquish"))

func _physics_process(delta):
	match playerMode:
		PlayerMode.PLAYING:
			_updatePlaying(delta)
		PlayerMode.CINEMATIC:
			pass
		PlayerMode.DIALOGUE:
			pass

func _updatePlaying(delta):
	match playerState:
		PlayerState.DEATH:
			_updateDeath()
		_:
			_movement()
			_updatePlayerState()

func _updatePlayerState():
	if Input.is_action_pressed("Down") or ((playerState == PlayerState.CROUCHED or playerState == PlayerState.SLIDING) and raycasts.crouchRaycastCollision):
		if abs(velocity.x) < crouchSpeedThreshold:
			setPlayerState(PlayerState.CROUCHED)
		else:
			if playerState != PlayerState.SLIDING:
				slideFrictionModMod = 1.0
			else:
				slideFrictionModMod += .0025
			setPlayerState(PlayerState.SLIDING)
	elif is_on_floor():
		if inputVelocity.x != 0:
			setPlayerState(PlayerState.RUN)
		elif playerState != PlayerState.HUNCHED_OVER:
			setPlayerState(PlayerState.IDLE)
	elif is_on_wall() and get_wall_normal().x == -inputVelocity.normalized().x and velocity.y > 0:
		setPlayerState(PlayerState.WALL_HUG)
	elif not is_on_floor() and velocity.y > wallHugSpeed - 1 and (playerState != PlayerState.WALL_HUG or (playerState == PlayerState.WALL_HUG and !is_on_wall())):
		setPlayerState(PlayerState.FALL)

func _movement():
	velocity += Vector2(0, gravityScale)
	inputVelocity = Vector2.ZERO

	var moveSpeedVec := Vector2(moveSpeed, 0)
	
	if playerState != PlayerState.SLIDING:
		inputVelocity += moveSpeedVec * Input.get_axis("MoveLeft", "MoveRight") * (inAirSpeedScale if (not is_on_floor()) else 1.0)

	if playerState == PlayerState.CROUCHED:
		if !is_on_floor():
			inputVelocity *= .125
		else:
			inputVelocity = Vector2.ZERO

	if is_on_floor() and inputVelocity.length() == 0:
		velocity.x *= frictionSpeedRetention * (1.0 if playerState != PlayerState.SLIDING else slideFrictionMod / slideFrictionModMod)
	
	if inputVelocity.x != 0 and velocity.x != 0 and abs(inputVelocity.x)/inputVelocity.x != abs(velocity.x)/velocity.x and is_on_floor():
		velocity.x = moveSpeed * Input.get_axis("MoveLeft", "MoveRight") * (inAirSpeedScale if (not is_on_floor()) else 1.0) * turnSpeedScaler
	else:
		velocity += inputVelocity

	if abs(velocity.x) > maxVelX:
		velocity.x = maxVelX if velocity.x > 0 else -maxVelX
	
	if inputVelocity.x != 0:
		sprite2D.flip_h = inputVelocity.x < 0

	_updateJump()
			
	if playerState == PlayerState.WALL_HUG and velocity.y > 0:
		velocity.y = min(velocity.y, wallHugSpeed)
		
	if Input.is_key_pressed(KEY_R):
		global_position = startPos
		velocity = Vector2.ZERO

	move_and_slide()

func _updateJump():
	if is_on_floor():
		coyoteFramesCount = 0
	elif coyoteFramesCount < coyoteFrames:
		coyoteFramesCount += 1
		
	if (is_on_wall() and get_wall_normal().x == -inputVelocity.normalized().x) or playerState == PlayerState.WALL_HUG:
		wallCoyoteFramesCount = 0
	elif wallCoyoteFramesCount < wallCoyoteFrames:
		wallCoyoteFramesCount += 1
	
	if Input.is_action_just_pressed("Jump"):
		if (is_on_floor() or coyoteFramesCount < coyoteFrames) and playerState != PlayerState.JUMP:
			jumpSpeedFramesCount = 0
			jumpSpeedFrames = JUMP_FRAMES
			velocity -= Vector2(0, jumpSpeed)
			if playerState != PlayerState.CROUCHED:
				setPlayerState(PlayerState.JUMP)
		elif (is_on_wall() and get_wall_normal().x == -inputVelocity.normalized().x) or playerState == PlayerState.WALL_HUG or wallCoyoteFramesCount < wallCoyoteFrames:
			jumpSpeedFramesCount = 0
			jumpSpeedFrames = WALL_JUMP_FRAMES
			var wallJumpVec = get_wall_normal()
			wallJumpVec = wallJumpVec.rotated(deg_to_rad(wallJumpAngle) * wallJumpVec.x)
			wallJumpVec.y = -abs(wallJumpVec.y)
			velocity = wallJumpVec * wallJumpSpeed
			wallCoyoteFramesCount = wallCoyoteFrames
			setPlayerState(PlayerState.JUMP, "" if get_wall_normal().x == -inputVelocity.normalized().x  else "WallJump")
	elif Input.is_action_pressed("Jump") and (playerState == PlayerState.JUMP or playerState == PlayerState.CROUCHED) and jumpSpeedFramesCount < jumpSpeedFrames:
		jumpSpeedFramesCount += 1
		if playerState == PlayerState.CROUCHED and !Input.is_action_pressed("Down") and !raycasts.crouchRaycastCollision:
			setPlayerState(PlayerState.JUMP)
		var jumpSpeedScalerMod := crouchJumpScaler if playerState == PlayerState.CROUCHED else 1.0
		velocity -= Vector2(0, jumpSpeed * jumpSpeedScaler * jumpSpeedScalerMod * cos(float(jumpSpeedFramesCount)/jumpSpeedFrames * PI/2))

func setPlayerState(state : PlayerState, animName : String = ""):
	playerState = state
	
	if animName != "":
		animPlayer.play(animName)
	else:
		animPlayer.play(playerStateAnimDict[state])

func squishBodyEntered(body):
	if body.name != "Player":
		print(body.name)
		death()

func horizontalSquish():
	return
	print("squish")
	velocity = Vector2.ZERO
	global_position = startPos

func death():
	if playerState == PlayerState.DEATH:
		return

	setPlayerState(PlayerState.DEATH, "Fall")
	animPlayer.speed_scale = 0.0
	velocity = Vector2.ZERO
	sprite2D.modulate = Color.RED

	await get_tree().create_timer(deathTime).timeout
	global_position = startPos
	setPlayerState(PlayerState.IDLE)
	animPlayer.speed_scale = 1.0
	sprite2D.modulate = Color.WHITE
	rotation = 0

func checkpointEntered(checkpoint : Node2D):
	print("CharacterController: Checkpoint Entered")
	if !currCheckpoint:
		startPos = checkpoint.position
		currCheckpoint = checkpoint
		return

	var checkpointLastTwoChars = checkpoint.name.substr(checkpoint.name.length() - 2, 2)
	var currCheckpointLastTwoChars = currCheckpoint.name.substr(currCheckpoint.name.length() - 2, 2)
	if int(checkpointLastTwoChars) < int(currCheckpointLastTwoChars):
		startPos = checkpoint.position
		currCheckpoint = checkpoint


func _updateDeath():
	pass
	# rotate(deg_to_rad(5))
