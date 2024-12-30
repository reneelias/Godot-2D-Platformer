extends Sprite2D

@export var pointLight : PointLight2D
@export var flashes := false
@export var flashMinTime := .1
@export var flashMaxTime := .5
var flashTime := 0.0
var flashDuration := 0.0

func _ready():
    flashTime = Time.get_ticks_msec()
    flashDuration = randf_range(flashMinTime, flashMaxTime)

func _process(delta):
    updateFlashing()
    

func updateFlashing():
    if not flashes:
        return
        
    if Time.get_ticks_msec() - flashTime > flashDuration * 1000:
        pointLight.enabled = !pointLight.enabled
        flashTime = Time.get_ticks_msec()
        flashDuration = randf_range(flashMinTime, flashMaxTime)