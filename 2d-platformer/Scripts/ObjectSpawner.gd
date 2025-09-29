extends Node2D

@export var objectScene : PackedScene
@export var spawnInterval := 2.0
@export var spawnTimeOffset := 0.0
@export var objectParent : Node2D
@export var offsetPosition := Vector2.ZERO

var lastSpawned : float
var spawnedInitial := false

@export_category("Object Type")
enum ObjectType {NODE2D, SAW_BLADE, CRATE}
@export var objectType := ObjectType.NODE2D

@export_group("Saw Blade")
@export var sb_spinSpeed := -15.0
@export var sb_invertSpin := false
@export var sb_usesGravity := true;
@export var sb_gravityScale := 9.81
@export var sb_velocity := Vector2.ZERO
@export var sb_usesLifespan := true
@export var sb_lifetime := 3.0

func _ready():
    await get_tree().create_timer(spawnTimeOffset).timeout
    spawnObject()
    lastSpawned = Time.get_ticks_msec()
    spawnedInitial = true

func spawnObject():
    var object = objectScene.instantiate() as Node2D
    if objectParent:
        objectParent.add_child(object)
    else:
        add_child(object)
    object.global_position = global_position + offsetPosition

    match objectType:
        ObjectType.SAW_BLADE:
            var sawBlade = object as SawBlade
            sawBlade.spinSpeed = sb_spinSpeed
            sawBlade.invertSpin = sb_invertSpin
            sawBlade.usesGravity = sb_usesGravity
            sawBlade.gravityScale = sb_gravityScale
            sawBlade.velocity = sb_velocity
            sawBlade.usesLifespan = sb_usesLifespan
            sawBlade.lifetime = sb_lifetime
            if sb_usesLifespan:
                sawBlade.lifeStarted = Time.get_ticks_msec()

func _physics_process(delta):
    if !spawnedInitial:
        return

    if Time.get_ticks_msec() - lastSpawned >= spawnInterval * 1000:
        spawnObject()
        lastSpawned = Time.get_ticks_msec()