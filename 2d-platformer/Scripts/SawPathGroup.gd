extends Path2D
## SawPathGroup creates a group of SawBlades that follow a path. Set their speed, spin speed, and more.
class_name SawPathGroup


@export_group("References")
@export var sawBlade : PackedScene

@export_category("Settings")
@export var sawCount := 4
## Percent path completion per second
@export var sawSpeed := .1
@export var sawSpinSpeed := -5.0
@export var flipSawHorizontal := false
@export var sawInvertSpin := false
## Offset from the start of the path in percentage
@export var pathStartOffset := 0.0

var saws : Array = []
var sawPaths : Array = []

func _ready():
    var sawsParent = Node2D.new()
    add_child(sawsParent)
    for i in range(sawCount):
        var saw = (sawBlade.instantiate() as SawBlade)
        sawsParent.add_child(saw)
        saws.append(saw)
        saw.spinSpeed = sawSpinSpeed
        saw.invertSpin = sawInvertSpin
        saw.followsPath = false
        saw.sprite2D.flip_h = flipSawHorizontal
        saw.name = "sawBlade_" + ("%02d" % i)
        var pathFollow = PathFollow2D.new()
        add_child(pathFollow)
        pathFollow.progress_ratio = pathStartOffset + (1.0/sawCount) * i  
        sawPaths.append(pathFollow)
    
    $VisibilitySprite.visible = false

func _physics_process(delta):
    for i in range(sawCount):
        var saw = saws[i]
        var pathFollow = sawPaths[i]
        pathFollow.progress_ratio += delta * sawSpeed
        saw.global_position = pathFollow.global_position